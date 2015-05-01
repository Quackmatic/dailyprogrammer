; Input via stdin
; Formatted as described in reddit.com/r/dailyprogrammer/comments/20cydp/14042014_challenge_152_hard_minimum_spanning_tree/

(defn with-index [coll]
  (map-indexed vector coll))

(defn get-adjacency []
  (with-index (map with-index
                   (repeatedly (read-string (read-line))
                               #(map read-string (clojure.string/split (read-line) #", *"))))))

(defn vert-from [adj indices bool-func]
  (filter (fn [current-index] (bool-func (some (fn [test-index] (= (first current-index) test-index))
                                               indices)))
          adj))

(defn get-edges [coll]
  (filter (fn [kv] (>= (get kv 1) 0))
          coll))

(defn from-adjacency [adj current]
  (apply concat
         (map (fn [il] (map (fn [vert] (conj vert (first il)))
                            (vert-from (last il) current identity)))
              (vert-from adj current not))))

(defn prim [adj current]
  (if (< (count current) (count adj))
    (let [next-vert (apply min-key
                           (fn [vert] (get vert 1))
                           (get-edges (from-adjacency adj current)))]
      (concat [next-vert]
              (prim adj (conj current (last next-vert)))))
    nil))

(let [tree (prim (get-adjacency) [0])]
  (println (apply + (map (fn [vert] (get vert 1)) tree)))
  (println (let [alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ"]
             (clojure.string/join ","
                                  (map (fn [vert] (str (get alphabet (first vert))
                                                       (get alphabet (last vert))))
                                       tree)))))
