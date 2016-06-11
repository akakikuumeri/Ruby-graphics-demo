#!/usr/bin/env ruby

# Usage:
#   cm12345$ ruby ./check.rb [--report] test.rb
#   
#    - check.rb: このプログラムです。
#    - test.rb: 与えられたテストデータです。
#    - --report オプションを付けると提出ファイルを作ります。

$OUTPUT_FILENAME = :NONE # :UNIQUE, or :WITH_TIMESTAMP

# When $TOJIS is true, output messages in the Shift JIS code.
$to_SJIS__=false
$messages_log=[]
def jputs(*messages)
#  m=$to_SJIS__ ? messages.map{|s| s.tosjis} : messages
#  m2 = m.map{ |s| s + "\n" }
  jprint(*messages.map{ |s| s + "\n" })
end
def jprint(*messages)
  m=$to_SJIS__ ? messages.map{|s| s.tosjis} : messages
  $messages_log.push(*m)
  m.each{ |m| print(m) }
end
def jprintf(*args)
  m=sprintf *($to_SJIS__ ? args.map{|o|
                (o.kind_of? String) ? o.tosjis : o
              } : args)
  $messages_log.push(m)
  print(m)
end

$loaded_files=[]
if !(defined? $orginal_load)
  $orginal_load = method(:load)
end
def load(file, priv=false)
  $loaded_files.push(file)
  $orginal_load.call(file,priv)
end

def testmain()
  # Perparation for MS Windows
  if(RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/)
    require "kconv"
    $to_SJIS__=true
  end

  if ARGV[0] == "--report"
    ARGV.shift
    $OUTPUT_FILENAME = :WITH_TIMESTAMP
  end

  if ARGV[0]
    jputs("\n"*3 + "="*70 + "\n"*3)
    jputs("テストデータファイルとして " + ARGV[0] + " を使います...")
  else
    jputs("ERROR: テストデータファイルを指定してください。")
    exit 1
  end 
  
  begin 
    load(ARGV[0])
    num_testcases = 0
    passed = 0
    excluded = 0
    $loaded_files=[]
    $testunits__.each{ |reportname,testcases|
      num_testcases += testcases.size
      (p,e) = testreport_sep(reportname,testcases)
      passed += p
      excluded += e
    }
    
    jputs 
    jputs "成功数: " + passed.to_s + "/" + (num_testcases - excluded).to_s
    jputs "(未定義で検査できなかった個数: " + excluded.to_s + ")"

    if $OUTPUT_FILENAME != :NONE
      
      log_base_name=File.basename(ARGV[0], ".rb")+
        ($OUTPUT_FILENAME == :WITH_TIMESTAMP ?
         Time.now.strftime("-%y%m%d-%H%M%S") :
         "")
      logfile=log_base_name+ ".log"
      #   jputs "テスト結果を#{logfile}に記録します"
      open(logfile,"a+"){|out|
        out.print($messages_log)
        out.puts(ENV["USER"])
      }
      #    jputs "読み込んだファイル:#{$loaded_files.join(',')}"
      archive_file_name = test_archive_results(
                              log_base_name, logfile, *$loaded_files)
      File.delete(logfile)
      jputs "提出用ファイル #{archive_file_name} ができました"
      
    end
  rescue LoadError
    # Test_data file not found
    jputs "ERROR: テストデータファイルが見つかりません。"
  ensure 
    jputs
  end
end

def test_archive_results(archive_base_name, *file_names)
  current_dir = Regexp.new("^"+Regexp.escape(File.expand_path("."))+"(.*)")
  expanded = file_names.map{|x|
    if (File.exists? x) && m = current_dir.match(File.expand_path(x))
      "."+m[1]
    else
      false
    end
  }.select{ |path_or_false| path_or_false}.uniq
  archive_file_name = archive_base_name + ".tgz"
  system("tar zcf #{archive_file_name} #{expanded.join(" ")}")
  archive_file_name
end

def testreport_sep(reportname,testcases)
  STDOUT.flush
  STDERR.flush
  (pipe_in,pipe_out)=IO.pipe
  begin
    #raise NotImplementedError
    fork{
      $messages_log=[]
      $loaded_files=[]
      result = testreport(reportname,testcases)
      Marshal.dump([result,$messages_log,$loaded_files], pipe_out)
      STDOUT.flush
      STDERR.flush
    }
  rescue NotImplementedError => no_fork # You can't fork on Windows
    result = testreport(reportname,testcases)
    Marshal.dump([result,[],[]], pipe_out)
  end
  (result,log,files) = Marshal.load(pipe_in)
  $messages_log.push(*log)
  $loaded_files.push(*files)
  result
end 

def testreport(reportname,testcases)
  jputs
  jputs("ファイル " + reportname + " を読み込みます...")

  begin
    load(reportname)
  rescue LoadError => le
    # Case of "file is not found."
    
    # extract filename from error message
    notfoundfile = le.to_s.sub(/^.* -- /, '') 
    
    jputs "ERROR: ファイル " + notfoundfile + " が見つかりません。"
    jputs "       ファイル名が異なっているかもしれません。"
    jputs "       違うフォルダに存在するかもしれません。"
    #    exit 1
#    return [0, testcases.size]
  rescue Exception => se
    if (se.kind_of? SyntaxError) && se.to_s =~ /^([^:]+):([0-9]+): (.*)/
      errorfile=$1
      errorline=$2
      errormsg=$3
      jputs "ERROR: ファイル #{errorfile} の#{errorline}行付近で文法誤り(#{errormsg})がありました"
      jputs se.to_s
    else
      jputs "ERROR: ファイル #{reportname} 読込中に誤りがありました"
      jputs se.to_s
    end
#    return [0, testcases.size]
  end
  
  passed, excluded = do_testcases(testcases)
  
  return passed,excluded
#  jputs 
#  jputs "Pass: " + passed.to_s + "/" + ($testcases__.size - excluded).to_s
#  jputs "(Failed tests due to Undefined methods: " + excluded.to_s + ")"
end

PASS = 0
NG = 1
NOTFOUND = 2

def do_testcases(testcases)
  passed = 0
  excluded = 0
  testcases.each { |tc|
    case do_testcase(*tc)
    when PASS
      passed = passed + 1
    when NOTFOUND
      excluded = excluded + 1
    end
  }
  jprint "\n\n"

  return [passed, excluded]
end

# default 'equal' method := equal?
def equal(a,b)
  a == b
end
def equal_float_with_prec(a,b,eps)
  if !b.kind_of? Numeric
    false
  else
    maxabs=[a.abs,b.abs].max
    a==b || maxabs < eps || (a-b).abs < eps * maxabs
  end
end

def equal_float(a,b)
  equal_float_with_prec(a,b,1e-3)
end
def equal_float10(a,b)
  equal_float_with_prec(a,b,1e-10)
end
def equal_float1(a,b)
  equal_float_with_prec(a,b,1)
end
def equal_array(expected, retval)
  if (!retval.kind_of? Array) || expected.length != retval.length
    false
  else
    for i in 0..expected.length-1
      v=expected[i]
      if v.kind_of? Array
        eqelm=equal_array(v, retval[i])
      else
        eqelm=equal_float(v, retval[i])
      end
      if !eqelm
        return false
      end
    end
    true
  end
end

def get_equals(c)
  case c
  when "int"
  when "boolean"
  when "string"
  when "array_of_int"
    return method(:equal)
  else
    return method("equal_"+c)
  end
  return method(:equal)
end

def do_testcase(exname, mname, eqtype, expected, *args)
  eqmethod = get_equals(eqtype)
  
  basemsg = " %-10s [対象のメソッド: %-16s] => "
  
  begin
    exp=mname+"("+args.map{|x| x.inspect}.join(",")+")"
    m = method(mname) 	# Maybe raise NameError
    begin 
      r = m.call(*args)	# r: return value of target method
      # Maybe raise ArgumentError
      
      if eqmethod.call(expected, r)	# Maybe raise TypeError
        assertmsg(basemsg + "PASS", exname, mname)
        return PASS
      else
        assertmsg(basemsg + "NG (計算式:"+ exp +
                  "期待した値: " + expected.inspect +
                  ", 実際の値: " + r.inspect + ")", exname, mname)
        return NG
      end
    rescue NameError => ne
      assertmsg(basemsg + "ERROR: " + ne.name.to_s.gsub(/%/, "%%") + " という名前のメソッドか変数が見つかりませんでした(計算式#{exp})", exname, mname,
                "    includeやloadのし忘れや、定義のし忘れなどに注意してもう一度確認してください")
    rescue TypeError => te
      assertmsg(basemsg + "ERROR: 結果が違います", exname, mname,
                "    返すべき値（文字列、数値、などなど）をもう一度確認してください",
                "    " + te.to_s)
      return NG
    end
  rescue NameError
    assertmsg(basemsg + "ERROR: 対象のメソッドが見つかりません", exname, mname)
    return NOTFOUND
  rescue ArgumentError => ae
    assertmsg(basemsg + "ERROR: 引数の数が合いません(計算式:#{exp})", exname, mname, "    " + ae.to_s,  "    " + ae.backtrace.to_s)
    return NG
  rescue Exception => exception
    assertmsg(basemsg + "ERROR: その他の誤りが起きました", exname, mname,
              "    " + exception.to_s,
              "    " + exception.backtrace.to_s)
    return NG
  end
  return NG
end

$previous_assert_message = nil

def assertmsg(format, exname, mname, *extra_messages)
  m = ([sprintf(format, exname, mname)] + extra_messages).join("\n")
  if $previous_assert_message == m
    jprint(".")
  else
    jprint("\n" + m)
  end
  $previous_assert_message = m
end

testmain if !(defined? IRB)

#puts $messages_log

#$Id: check.rb,v 1.16 2010/09/20 22:23:59 masuhara Exp $


# version 1.16
# see http://lecture.ecc.u-tokyo.ac.jp/johzu/joho-kagaku/
