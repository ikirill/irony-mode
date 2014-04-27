(load (concat (file-name-directory (or load-file-name
                                       buffer-file-name))
              "test-config"))

(ert-deftest irony/buffer-size-in-bytes ()
  (with-temp-buffer
    ;; this smiley takes 3 bytes apparently
    (insert "☺")
    (should (equal 3 (irony-buffer-size-in-bytes)))
    (erase-buffer)
    (insert "☺\n")
    (should (equal 4 (irony-buffer-size-in-bytes)))
    (erase-buffer)
    (insert "\t")
    (should (equal 1 (irony-buffer-size-in-bytes)))))

(ert-deftest irony/split-command-line/just-spaces ()
  (let ((cmd-line "clang -Wall -Wextra"))
    (should (equal
             '("clang" "-Wall" "-Wextra")
             (irony-split-command-line cmd-line)))))

(ert-deftest irony/split-command-line/start-with-space ()
  (let ((cmd-line " clang -Wall -Wextra"))
    (should (equal
             '("clang" "-Wall" "-Wextra")
             (irony-split-command-line cmd-line)))))

(ert-deftest irony/split-command-line/end-with-space ()
  (let ((cmd-line "clang -Wall -Wextra "))
    (should (equal
             '("clang" "-Wall" "-Wextra")
             (irony-split-command-line cmd-line)))))

(ert-deftest irony/split-command-line/space-everywhere ()
  (let ((cmd-line "    \t  clang   \t  -Wall \t  -Wextra\t"))
    (should (equal
             '("clang" "-Wall" "-Wextra")
             (irony-split-command-line cmd-line)))))

(ert-deftest irony/split-command-line/with-quotes ()
  (let ((cmd-line "clang -Wall -Wextra \"-I/tmp/dir with spaces\""))
    (should (equal
             '("clang" "-Wall" "-Wextra" "-I/tmp/dir with spaces")
             (irony-split-command-line cmd-line)))))

(ert-deftest irony/split-command-line/with-quotes ()
  "Test if files are removed from the arguments list.

https://github.com/Sarcasm/irony-mode/issues/101"
  (let ((cmd-line "g++ -DFOO=\\\"\\\""))
    (should (equal
             '("g++" "-DFOO=\"\"")
             (irony-split-command-line cmd-line)))))

(ert-deftest irony/split-command-line/start-with-quotes ()
  (let ((cmd-line "\"cl ang\" -Wall -Wextra \"-I/tmp/dir with spaces\""))
    (should (equal
             '("cl ang" "-Wall" "-Wextra" "-I/tmp/dir with spaces")
             (irony-split-command-line cmd-line)))))

(ert-deftest irony/split-command-line/quotes-in-word ()
  (let ((cmd-line "clang -Wall -Wextra -I\"/tmp/dir with spaces\""))
    (should (equal
             '("clang" "-Wall" "-Wextra" "-I/tmp/dir with spaces")
             (irony-split-command-line cmd-line)))))

(ert-deftest irony/split-command-line/ill-end-quote ()
  :expected-result :failed
  (let ((cmd-line "clang -Wall -Wextra\""))
    (should (equal
             '("clang" "-Wall" "-Wextra" "-I/tmp/dir with spaces")
             (irony-split-command-line cmd-line)))))

(ert-deftest irony/split-command-line/backslash-1 ()
  (let ((cmd-line "clang\\ -Wall"))
    (should (equal
             '("clang -Wall")
             (irony-split-command-line cmd-line)))))

(ert-deftest irony/split-command-line/backslash-2 ()
  (let ((cmd-line "\\\\\\ clang\\ -Wall\\"))
    (should (equal
             '("\\ clang -Wall\\")
             (irony-split-command-line cmd-line)))))

;; TODO: restore functionality
;; (ert-deftest irony/include-directories-1 ()
;;   (let ((irony-compile-flags '("-Iinclude" "-I/tmp/foo"))
;;         (irony-compile-flags-work-dir "/tmp/blah/"))
;;     (should (equal
;;              '("/tmp/blah/include" "/tmp/foo")
;;              (irony-user-search-paths)))))

;; (ert-deftest irony/include-directories-2 ()
;;   (let ((irony-compile-flags '("-Wextra" "-Iinclude" "-I" "foo" "-Wall"))
;;         (irony-compile-flags-work-dir "/tmp/blah/"))
;;     (should (equal
;;              '("/tmp/blah/include"
;;                "/tmp/blah/foo")
;;              (irony-user-search-paths)))))

;; (ert-deftest irony/extract-working-dir-flag/none-present ()
;;   (let ((compile-flags '("-Wall")))
;;     (should
;;      (not (irony-extract-working-dir-flag compile-flags)))))

;; (ert-deftest irony/extract-working-dir-flag/present-1 ()
;;   (let ((compile-flags '("-working-directory" "/tmp/lol")))
;;     (should (equal "/tmp/lol"
;;                    (irony-extract-working-dir-flag compile-flags)))))

;; (ert-deftest irony/extract-working-dir-flag/present-2 ()
;;   (let ((compile-flags '("-Wall" "-working-directory=/tmp/lol" "-Wshadow")))
;;     (should (equal "/tmp/lol"
;;                    (irony-extract-working-dir-flag compile-flags)))))