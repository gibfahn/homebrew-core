class Kubebuilder < Formula
  desc "SDK for building Kubernetes APIs using CRDs"
  homepage "https://github.com/kubernetes-sigs/kubebuilder"
  url "https://github.com/kubernetes-sigs/kubebuilder.git",
      tag:      "v4.3.1",
      revision: "a9ee3909f7686902879bd666b92deec4718d92c9"
  license "Apache-2.0"
  head "https://github.com/kubernetes-sigs/kubebuilder.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d7860e00b9d761d20361903d544cf6f65de0660196837439310e75c21799464b"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "d7860e00b9d761d20361903d544cf6f65de0660196837439310e75c21799464b"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "d7860e00b9d761d20361903d544cf6f65de0660196837439310e75c21799464b"
    sha256 cellar: :any_skip_relocation, sonoma:        "b68410ccb1257390c4f51b61b1a034975024365272c82c49d4a3d7d1294cc266"
    sha256 cellar: :any_skip_relocation, ventura:       "b68410ccb1257390c4f51b61b1a034975024365272c82c49d4a3d7d1294cc266"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "d8260ad68fc4ad2c57f09f0c89a3621c9c578d7f98d327afc172002e001a8b89"
  end

  depends_on "go"

  def install
    goos = Utils.safe_popen_read("#{Formula["go"].bin}/go", "env", "GOOS").chomp
    goarch = Utils.safe_popen_read("#{Formula["go"].bin}/go", "env", "GOARCH").chomp
    ldflags = %W[
      -X main.kubeBuilderVersion=#{version}
      -X main.goos=#{goos}
      -X main.goarch=#{goarch}
      -X main.gitCommit=#{Utils.git_head}
      -X main.buildDate=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd"

    generate_completions_from_executable(bin/"kubebuilder", "completion")
  end

  test do
    mkdir "test" do
      system "go", "mod", "init", "example.com"
      system bin/"kubebuilder", "init",
                 "--plugins", "go.kubebuilder.io/v4",
                 "--project-version", "3",
                 "--skip-go-version-check"
    end

    assert_match <<~EOS, (testpath/"test/PROJECT").read
      domain: my.domain
      layout:
      - go.kubebuilder.io/v4
      projectName: test
      repo: example.com
      version: "3"
    EOS

    assert_match version.to_s, shell_output("#{bin}/kubebuilder version")
  end
end
