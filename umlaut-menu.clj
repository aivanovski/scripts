#!/usr/bin/env bb

; Launches Rofi menu with list of German Umlaut characters to input

(require '[clojure.java.shell :refer [sh]]
         '[clojure.string :as str])

(def COMMAND "echo '%s' | rofi -sep '|' -dmenu -i | xargs -r echo")
(def INPUT_COMMAND "xdotool key %s")

(defn run [command]
  (let
   [result (:out (sh "bash" "-c" command))]
    (if (not (nil? result))
      (str/trim result)
      (System/exit 0))))

; Uppercase letter codes:
; "2 - Ä" "U00C4",
; "4 - Ö" "U00D6",
; "6 - Ü" "U00DC",

(def data {"1 - ä (a)" "U00E4",
           "2 - ö (o)" "U00F6",
           "3 - ü (u)" "U00FC",
           "4 - ß (s)" "U00DF"})

(def entries (str/join "|" (map #(first %) data)))
(def key (run (format COMMAND entries)))

(if (not (empty? key))
  (let
    [code (get data key)]
    (run (format INPUT_COMMAND code))))
