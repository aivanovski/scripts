#!/usr/bin/env bb

; Executes 'adb shell uiautomator dump' and formats the output.
; The result will be printed in standard output

(require '[clojure.java.shell :refer [sh]]
         '[clojure.string :as str]
         '[clojure.data.xml :as xml])

(defn run [command]
  (let [result (sh "bash" "-c" command)]
    (if (contains? result :out) (:out result) nil)))

(def devices (->> (str/split (run "adb devices") #"\n")
                   (filter #(> (count %) 0))
                   (filter #(not (str/includes? % "List")))))
(def device-count (count devices))

(if (= device-count 0)
  ((println "No connected devices")
   (System/exit 1))
  nil)

(if (> device-count 1)
  ((println "More than 1 device connected")
   (System/exit 1))
  nil)

(def run-dump (run "adb shell uiautomator dump"))
(def dump (run "adb shell cat /sdcard/window_dump.xml"))

(def lines (-> (run "adb shell cat /sdcard/window_dump.xml")
               (xml/parse-str)
               (xml/indent-str)
               (str/split #"\n")))

(doseq [line lines]
  (println line))
