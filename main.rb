#!/usr/bin/env ruby

require 'mongo'
require 'open3'
include Mongo

mongo_client = MongoClient.new
db = mongo_client.db("mydb")
coll = db.collection("testCollection")
doc = {"_id" => "1"}
id = coll.insert(doc)
h = Hash.new

cmd = 'debmirror -a i386 --no-source -s main -h archive.ubuntu.com -d trusty -r /ubuntu --progress --ignore-release-gpg --method=http /tmp/UbuntuMirror'
Open3.popen2e(cmd) do |stdin, stdout_err, wait_thr|
  while line = stdout_err.gets
    line = line.split(" ")

    unless line[1].nil?
     line = line[1].to_s.gsub(/\]/,"")
      puts line.inspect
      h["status"] = line
	puts h
	coll.update({"_id" => "1"}, h)
    end
  end

  exit_status = wait_thr.value
  unless exit_status.success?
    abort "FAILED !!! #{cmd}"
  end
end
