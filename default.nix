{ lib, python3Packages, poetry2nix }:
python3Packages.buildPythonApplication {
  name = "nixgcmgr";
  version = "0.1.0";

  src = poetry2nix.cleanPythonSources {
    src = ./.;
  };

  propagatedBuildInputs = with python3Packages; [

  ];

  # There are no tests for now
  doCheck = false;

  meta = with lib; {
    mainProgram = "nixgcmgr";
    homepage = "https://github.com/nyantec/nixgcmgr";
    description = "A tool to manage Nix GC root symlinks";
    maintainers = with maintainers; [
      vikanezrimaya
    ];
    license = licenses.miros;
    platforms = platforms.linux;
  };
}
