(declare-project
  :name "janet"
  :description "Command line utility for managing TODO list"
  :dependencies [{:repo "https://github.com/joy-framework/tester"}])

(declare-executable
 :name "alas"
 :entry "src/alas.janet")