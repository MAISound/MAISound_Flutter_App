# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "C:/Users/dudac/OneDrive/Documentos/JOAO COTUCA/2024/tcc/MAISound_Flutter_App/windows/out/build/x64-Debug/_deps/nuget-src"
  "C:/Users/dudac/OneDrive/Documentos/JOAO COTUCA/2024/tcc/MAISound_Flutter_App/windows/out/build/x64-Debug/_deps/nuget-build"
  "C:/Users/dudac/OneDrive/Documentos/JOAO COTUCA/2024/tcc/maisound_flutter_app/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix"
  "C:/Users/dudac/OneDrive/Documentos/JOAO COTUCA/2024/tcc/maisound_flutter_app/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix/tmp"
  "C:/Users/dudac/OneDrive/Documentos/JOAO COTUCA/2024/tcc/maisound_flutter_app/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix/src/nuget-populate-stamp"
  "C:/Users/dudac/OneDrive/Documentos/JOAO COTUCA/2024/tcc/maisound_flutter_app/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix/src"
  "C:/Users/dudac/OneDrive/Documentos/JOAO COTUCA/2024/tcc/maisound_flutter_app/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix/src/nuget-populate-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "C:/Users/dudac/OneDrive/Documentos/JOAO COTUCA/2024/tcc/maisound_flutter_app/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix/src/nuget-populate-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "C:/Users/dudac/OneDrive/Documentos/JOAO COTUCA/2024/tcc/maisound_flutter_app/windows/out/build/x64-Debug/_deps/nuget-subbuild/nuget-populate-prefix/src/nuget-populate-stamp${cfgdir}") # cfgdir has leading slash
endif()
