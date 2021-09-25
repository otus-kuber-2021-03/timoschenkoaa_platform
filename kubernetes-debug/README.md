Установил kubectl debug из оф репозитория
Установил daemonset манифеста:

$ kubectl apply -f https://raw.githubusercontent.com/aylei/kubectl-debug/master/scripts/agent_daemonset.yml

На тестовом поде  выполнил strace:
$ kubectl debug nginx --image alpine:latest -it target nginx -- /bin/sh
Проблем не обнаружено

# strace -p32 -c
strace: Process 32 attached
^Cstrace: Process 32 detached
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 27.38    0.000201         100         2           stat
 17.71    0.000130          65         2           writev
 11.72    0.000086          28         3           epoll_wait
 11.58    0.000085          42         2           openat
 10.08    0.000074          37         2           write
  6.95    0.000051          25         2           close
  5.18    0.000038          19         2           fstat
  4.77    0.000035          17         2           recvfrom
  2.45    0.000018          18         1           accept4
  1.23    0.000009           9         1           setsockopt
  0.95    0.000007           7         1           epoll_ctl
------ ----------- ----------- --------- --------- ----------------
100.00    0.000734          36        20           total
Установили netperf-operator
запустили тестовое приложение
Kind: Netperf
Metadata: ...
Spec: ...
Status:
 Client Pod: netperf-client-43410aa6449b
 Server Pod: netperf-server-43410aa6449b
 Speed Bits Per Sec: 915.42
 Status: Done
Events: <none>
Позапускали iptables-tailer по инструкции