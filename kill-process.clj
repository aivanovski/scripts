#!/usr/bin/env bb

; Shows list of process with Rofi and kills selected

(require '[clojure.java.shell :refer [sh]]
         '[clojure.string :as str])

(defn run [command]
  (let [result (sh "bash" "-c" command)]
    (if (contains? result :out)
      (:out result)
      (do 
        (println (str "Error has occured: " (get result :err)))
        (System/exit 0)))))

(def data (str/split (str/trim (run "ps --user \"$(id -u)\" -o pid,time,cmd | rofi -dmenu -i | xargs -r echo")) #" "))
(def pid (if (> (count data) 2) (nth data 0) nil))

(if (and (some? pid) (not= pid "PID"))
  (do 
    (println (format "Killing process %s" pid))
    (run (format "kill -9 %s" pid)
    nil)))
