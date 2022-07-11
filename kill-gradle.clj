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

(defn parse-pid [line]
  (let [words (filter #(not (empty? %)) (str/split line #" "))
        pid (if (> (count words) 1) (nth words 1) nil)]
    pid))

(defn parse-pids [output query]
  (->> (str/split output #"\n")
       (filter #(not-empty %))
       (filter #(str/includes? % "java"))
       (filter #(str/includes? % query))
       (map parse-pid)
       (filter #(some? %))))

(defn kill-process [pid]
  (run (str "kill -9 " pid)))

(defn main []
  (let [output (run "ps aux | grep gradle")
        gradle-daemons (parse-pids output "GradleDaemon")
        kotlin-daemons (parse-pids output "KotlinCompileDaemon")]

    (do
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
            (kill-process pid)))))))

(main)
