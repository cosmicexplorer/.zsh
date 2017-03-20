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

(defun make-read-pipe-sentinel (dir)
  (lambda (_ _)
    (when (and (file-exists-p dir)
               (file-directory-p dir))
      (delete-directory dir t))))

(defun read-from-pipe (fname dir)
  (let ((path (expand-file-name fname))
        (tmpdir (expand-file-name dir)))
    (unless (file-exists-p (expand-file-name fname))
      (throw 'pipe-does-not-exist
             (format "the named pipe at '%s' does not exist"
                     fname)))
    (unless (and (file-exists-p (expand-file-name tmpdir))
                 (file-directory-p (expand-file-name tmpdir)))
      (throw 'tmp-pipe-tmpdir-does-not-exist
             (format "no directory at '%s', or it is a file"
                     tmpdir)))
    (let* ((buf (generate-new-buffer (format "pipe@%s" path)))
           (cat-proc (make-process
                      :name (format "pipe-read@%s" path)
                      :buffer buf
                      :command (list "cat" path)
                      :connection-type 'pipe
                      :filter #'read-pipe-filter
                      :sentinel (make-read-pipe-sentinel tmpdir))))
      (switch-to-buffer buf))))

(provide 'read-pipe)
