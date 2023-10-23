#!/usr/bin/env bb

(require '[clojure.string :as str]
         '[babashka.cli :as cli])

(def info ["Utility that encodes number into passphrase depend on specified phrase."
           "The process of encoding is a simple substition of each digit by corresponding word from the phrase."
           ""
           "USAGE:"
           "    num-encode [OPTION] [OPTION-VALUE]"
           ""
           "OPTIONS:"
           "    -n, --number              The number to transform, for example 01234"
           "    -p, --phrase              The phrase each word of which is used to encode the number."
           "                                  The first word of phrase is assigned index 0."
           "    -h, --help                Print help information"])

(def cli-options
  {:coerce {:phrase :string
            :number :string
            :help :boolean}
   :alias {:p :phrase
           :n :number
           :h :help} })

(def excluded-words #{"the" "and" "for" "but" "nor" "not"})

(defn print-info
  []
  (doseq [line info]
      (println line)))

(defn phrase-to-words
  [phrase]
  (->> (str/split phrase #" ")
       (filter (fn [word]
                 (and
                   (not (empty? word))
                   (> (count word) 2)
                   (not (contains? excluded-words (str/lower-case word))))))))

(defn words-to-vocabulary
  [words]
  (let [word-count (count words)
        vocabulary (zipmap (range 0 word-count) words)]
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
          words (phrase-to-words (:phrase arguments))
          vocabulary (words-to-vocabulary words)
          password (generate-password number vocabulary)]

      (println password))))

(-main *command-line-args*)
