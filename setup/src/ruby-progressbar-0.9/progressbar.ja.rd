=begin
index:eJ

= Ruby/ProgressBar: �ץ��쥹�С���ƥ����Ȥ�ɽ������ Ruby�ѤΥ饤�֥��

�ǽ�������: 2005-05-22 00:28:53


--

Ruby/ProgressBar �ϥץ��쥹�С���ƥ����Ȥ�ɽ������ Ruby��
�Υ饤�֥��Ǥ��������ο�Ľ������ѡ�����ȡ��ץ��쥹�С���
����ӿ���Ĥ���֤Ȥ���ɽ�����ޤ���

�ǿ��Ǥ�
((<URL:http://namazu.org/~satoru/ruby-progressbar/>))
���������ǽ�Ǥ�

== ������

  % irb --simple-prompt -r progressbar
  >> pbar = ProgressBar.new("test", 100)
  => (ProgressBar: 0/100)
  >> 100.times {sleep(0.1); pbar.inc}; pbar.finish
  test:          100% |oooooooooooooooooooooooooooooooooooooooo| Time: 00:00:10
  => nil

  >> pbar = ProgressBar.new("test", 100)
  => (ProgressBar: 0/100)
  >> (1..100).each{|x| sleep(0.1); pbar.set(x)}; pbar.finish
  test:           67% |oooooooooooooooooooooooooo              | ETA:  00:00:03

== API

--- ProgressBar#new (title, total, out = STDERR)
    �ץ��쥹�С��ν�����֤�ɽ������������ ProgressBar����
    �������Ȥ��֤���((|title|)) �Ǹ��Ф���((|total|)) �ǽ�
    ������פ�((|out|)) �ǽ������ IO �����ꤹ�롣

    �ץ��쥹�С���ɽ���ϡ������ɽ�������Ľ�� 1%�ʾ夢��
    ���Ȥ������뤤�� 1�ðʾ�вᤷ�����˹�������ޤ���

--- ProgressBar#inc (step = 1)
    �����Υ����󥿤� ((|step|)) �������ʤ�ơ��ץ��쥹�С�
    ��ɽ���򹹿����롣�С��α�¦�ˤϿ���Ĥ���֤�ɽ�����롣
    �����󥿤� ((|total|)) ��ۤ��ƿʤळ�ȤϤʤ���

--- ProgressBar#set (count)
    �����󥿤��ͤ� ((|count|)) �����ꤷ���ץ��쥹�С���
    ɽ���򹹿����롣�С��α�¦�ˤϿ���Ĥ���֤�ɽ�����롣
    ((|count|)) �˥ޥ��ʥ����ͤ��뤤�� ((|total|)) ����礭
    ���ͤ��Ϥ����㳰��ȯ�����롣

--- ProgressBar#finish
    �ץ��쥹�С�����ߤ����ץ��쥹�С���ɽ���򹹿����롣
    �ץ��쥹�С��α�¦�ˤϷв���֤�ɽ�����롣
    ���ΤȤ����ץ��쥹�С��� 100% �ǽ�λ���롣

--- ProgressBar#halt
    �ץ��쥹�С�����ߤ����ץ��쥹�С���ɽ���򹹿����롣
    �ץ��쥹�С��α�¦�ˤϷв���֤�ɽ�����롣
    ���ΤȤ����ץ��쥹�С��Ϥ��λ����Υѡ�����ơ����ǽ�λ���롣

--- ProgressBar#format=
    �ץ��쥹�С�ɽ���Υե����ޥåȤ����ꤹ�롣
    ̤�ѹ����� "%-14s %3d%% %s %s"

--- ProgressBar#format_arguments=
    �ץ��쥹�С�ɽ���˻Ȥ��ؿ������ꤹ�롣
    ̤�ѹ����� [:title, :percentage, :bar, :stat]
    �ե�����ž�����ˤ� :stat ���Ѥ��� :stat_for_file_transfer
    ��Ȥ���ž���Х��ȿ���ž��®�٤�ɽ���Ǥ��롣

--- ProgressBar#file_transfer_mode
    �ץ��쥹�С�ɽ���� :stat ���Ѥ��� :stat_for_file_transfer
    ��Ȥ���ž���Х��ȿ���ž��®�٤�ɽ�����롣


ReverseProgressBar �Ȥ������饹���󶡤���ޤ�����ǽ��
ProgressBar �Ȥޤä���Ʊ���Ǥ������ץ��쥹�С��οʹ�������
�դˤʤäƤ��ޤ���

== ���»���

��Ľ�������������פ��Ф�����Ȥ��Ʒ׻����뤿�ᡢ��������
�פ������ˤ狼��ʤ������ǤϻȤ��ޤ��󡣤ޤ�����Ľ��ή�줬��
��Ǥʤ��Ȥ��ˤϻĤ���֤ο�����������Ԥ��ޤ���

== ���������

Ruby �Υ饤���󥹤˽��ä��ե꡼���եȥ������Ȥ��Ƹ������ޤ���
������̵�ݾڤǤ���

  * ((<URL:http://namazu.org/~satoru/ruby-progressbar/ruby-progressbar-0.9.tar.gz>))
  * ((<URL:http://cvs.namazu.org/ruby-progressbar/>))

--

- ((<Satoru Takabayashi|URL:http://namazu.org/~satoru/>)) -
=end
