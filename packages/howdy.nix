{ stdenv, fetchurl, bzip2, python3 }:
let
  data = {
    "dlib_face_recognition_resnet_model_v1.dat" = fetchurl {
      url =
        "https://github.com/davisking/dlib-models/raw/master/dlib_face_recognition_resnet_model_v1.dat.bz2";
      sha256 = "0fjm265l1fz5zdzx5n5yphl0v0vfajyw50ffamc4cd74848gdcdb";
    };
    "mmod_human_face_detector.dat" = fetchurl {
      url =
        "https://github.com/davisking/dlib-models/raw/master/mmod_human_face_detector.dat.bz2";
      sha256 = "117wv582nsn585am2n9mg5q830qnn8skjr1yxgaiihcjy109x7nv";
    };
    "shape_predictor_5_face_landmarks.dat" = fetchurl {
      url =
        "https://github.com/davisking/dlib-models/raw/master/shape_predictor_5_face_landmarks.dat.bz2";
      sha256 = "0wm4bbwnja7ik7r28pv00qrl3i1h6811zkgnjfvzv7jwpyz7ny3f";
    };
  };
  pythonInUse = python3.withPackages
    (p: [ p.face_recognition (p.opencv4.override { enableGtk3 = true; }) ]);
  outPath = placeholder "out";
in stdenv.mkDerivation rec {
  pname = "howdy";
  version = "2.5.1";
  nativeBuildInputs = [ bzip2 ];
  src = fetchurl {
    url = "https://github.com/boltgolt/howdy/archive/v${version}.tar.gz";
    sha256 = "10mz8shndkn62d4k5qa7qrpim4xglh0gk137fhcx9ri2fja8sv2r";
  };
  patches = [ ./howdy.patch ];
  buildInputs = [ pythonInUse ];
  postPatch = ''
    substituteInPlace src/pam.py --replace '/usr/bin/python3' ${pythonInUse}/bin/python
  '';

  dontBuild = true;
  installPhase = let
    libDir = "${outPath}/lib/security/howdy";
    inherit (stdenv.lib) mapAttrsToList concatStrings;
  in ''
        mkdir -p ${outPath}/share/licenses/howdy
        install -Dm644 LICENSE ${outPath}/share/licenses/howdy/LICENSE
        mkdir -p ${libDir}
    	cp -r src/* ${libDir}
        rm -rf ${libDir}/pam-config
        rm -f ${libDir}/dlib-data/*
        ${
          concatStrings (mapAttrsToList (n: v: ''
            bzip2 -dc ${v} > ${libDir}/dlib-data/${n}
          '') data)
        }
    	mkdir -p ${outPath}/bin
    	ln -s ${libDir}/cli.py ${outPath}/bin/howdy
    	chmod +x ${outPath}/bin/howdy
    	mkdir -p "${outPath}/share/bash-completion/completions"
    	cp autocomplete/howdy "${outPath}/share/bash-completion/completions/howdy"
      '';
}
