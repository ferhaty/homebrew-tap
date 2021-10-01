class Kubescape < Formula
  desc "Kubernetes testing according to Hardening Guidance by to NSA and CISA"
  homepage "https://www.armosec.io/armo-kubescape"
  url "https://github.com/armosec/kubescape/archive/refs/tags/v1.0.88.tar.gz"
  sha256 "5d052f1830dcab6e660ca97dade2bcf1b00410197b767060f84f17fcaf43c7cf"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, big_sur: "8b6cdcd45abc765d1ffd8dfd5e0bedb9ae4bf93a56f69dab81c0f634ccdb2af5"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X github.com/armosec/kubescape/cmd.BuildNumber=v#{version}
      -X github.com/armosec/kubescape/cautils/getter.ArmoBEURL=api.armo.cloud
      -X github.com/armosec/kubescape/cautils/getter.ArmoERURL=report.euprod1.cyberarmorsoft.com
      -X github.com/armosec/kubescape/cautils/getter.ArmoFEURL=portal.armo.cloud
    ].join(" ")

    system "go", "mod", "tidy"
    system "go", "build", *std_go_args(ldflags: ldflags)

    output = Utils.safe_popen_read("#{bin}/kubescape", "completion", "bash")
    (bash_completion/"kubescape").write output
    output = Utils.safe_popen_read("#{bin}/kubescape", "completion", "zsh")
    (zsh_completion/"_kubescape").write output
    output = Utils.safe_popen_read("#{bin}/kubescape", "completion", "fish")
    (fish_completion/"kubescape").write output
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kubescape version")

    scan_cmd = "#{bin}/kubescape scan framework nsa"
    manifest = "https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/master/release/kubernetes-manifests.yaml"
    assert_match "FAILED RESOURCES", shell_output("#{scan_cmd} #{manifest}")
  end
end
