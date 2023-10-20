#!/usr/bin/env bb

(require '[clojure.string :as str]
         '[babashka.cli :as cli])

(def info ["Utility to transform number into passphrase depend on provided vocabulary."
           "The process of transformatio is a simple substition of each digit by corresponding word from vocabulary."
           ""
           "USAGE:"
           "    gen-pass [OPTION] [OPTION-VALUE]"
           ""
           "OPTIONS:"
           "    -n, --number              The number to transform, for example 01234"
           "    -v, --vocabulary          The path to file with list of words separated by new line."
           "                                  The first word is assigned index 0"
           "    -h, --help                Print help information"])

(def cli-options
  {:coerce {:vocabulary :string
            :number :string
            :help :boolean}
   :alias {:v :vocabulary
           :n :number
           :h :help} })

(defn print-info
  []
  (doseq [line info]
      (println line)))

(defn load-vocabulary
  [path]
  (let [content (slurp path)
        lines (->> (str/split content #"\n")
                   (map #(str/trim %))
                   (filter #(not (empty? %))))
        word-count (count lines)
        vocabulary (zipmap (range 0 word-count) lines)]
    vocabulary))

(defn generate-password
  [number vocabulary]
  (let [password (->> number
                      (map #(Integer/parseInt (str %)))
                      (map #(or (get vocabulary %) "UNDEFINED"))
                      (str/join " "))]
    password))

(defn -main
  [args]

  (when (empty? args)
    (print-info)
    (System/exit 1))

  (let [arguments (cli/parse-opts args cli-options)
        print-help (contains? arguments :help)]

    (when print-help
      (print-info)
      (System/exit 1))

    (let [number (:number arguments)
          vocabulaty-path (:vocabulary arguments)
          vocabulary (load-vocabulary vocabulaty-path)
          password (generate-password number vocabulary)]

      (println password))))

(-main *command-line-args*)
