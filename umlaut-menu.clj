#!/usr/bin/env bb

; Launches Rofi menu with list of German Umlaut characters to input

(require '[clojure.java.shell :refer [sh]]
         '[clojure.string :as str])

(def COMMAND "echo '%s' | rofi -sep '|' -dmenu -i | xargs -r echo")
(def INPUT_COMMAND "sleep 1 && xdotool key %s")

(defn run [command]
  (let
   [result (sh "bash" "-c" command)]
    (if (contains? result :out)
      (str/trim (get result :out))
      (System/exit 0))))

(def data {"1 - ä" "U00E4",
           "2 - Ä" "U00C4",
           "3 - ö" "U00F6",
           "4 - Ö" "U00D6",
           "5 - ü" "U00FC",
           "6 - Ü" "U00DC",
           "7 - ß" "U00DF"})

(def entries (str/join "|" (map #(first %) data)))
(def key (run (format COMMAND entries)))

(if (not (empty? key))
  (let
    [code (get data key)]
    (run (format INPUT_COMMAND code))))
