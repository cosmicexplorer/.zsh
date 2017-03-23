;; -*- lexical-binding: t -*-

(defun read-pipe-filter (proc msg)
  (with-current-buffer (process-buffer proc)
    (let* ((win (get-buffer-window (current-buffer) t))
           (at-end (= (window-point win) (point-max))))
      (save-excursion
        (goto-char (point-max))
        (insert msg))
      (when at-end
        (with-selected-window win
          (goto-char (point-max)))))))

(defun read-from-pipe (fname)
  (let ((path (expand-file-name fname)))
    (unless (file-exists-p (expand-file-name fname))
      (throw 'pipe-does-not-exist
             (format "the named pipe at '%s' does not exist"
                     fname)))
    (let* ((buf (generate-new-buffer (format "pipe@%s" path)))
           (cat-proc (make-process
                      :name (format "pipe-read@%s" path)
                      :buffer buf
                      :command (list "cat" path)
                      :connection-type 'pipe
                      :filter #'read-pipe-filter
                      :sentinel #'ignore)))
      (switch-to-buffer buf))))

(provide 'read-pipe)
