#!/usr/bin/env bb

;; Kills Gradle daemons

(require '[clojure.java.shell :refer [sh]]
         '[clojure.string :as str])

(defn run [command]
  (def result (sh "bash" "-c" command))
  (if (contains? result :out)
    (get result :out)
    (do 
      (println (str "Error has occured: " (get result :err)))
      (System/exit 0))))

(defn parse-process-line [line]
  (def line-words (filter #(not (empty? %)) (str/split line #" ")))
  (def pid (nth line-words 1))
  (def command (str/join " " (nthrest line-words 10)))
  (hash-map :pid pid, :command command))

(defn parse-pids [command]
  (def output (run command))
  (->> (str/split output #"\n")
       (filter #(not-empty %))
       (map parse-process-line)
       (filter #(str/includes? (get % :command) "java"))
       (map #(get % :pid))))

(defn kill-process [pid]
  (run (str "kill -9 " pid)))

(def gradle-daemons (parse-pids "ps aux | grep gradle | grep GradleDaemon"))
(def kotlin-daemons (parse-pids "ps aux | grep gradle | grep KotlinCompileDaemon"))

(if (empty? gradle-daemons)
  (println "No Gradle Daemon")
  (do 
    (println (str "Killing Gradle Daemon: " (str/join ", " gradle-daemons)))
    (doseq [pid gradle-daemons]
      (kill-process pid))))

(if (empty? kotlin-daemons)
  (println "No Kotlin Daemon")
  (do 
    (println (str "Killing Kotlin Daemon: " (str/join ", " kotlin-daemons)))
    (doseq [pid kotlin-daemons]
      (kill-process pid))))
