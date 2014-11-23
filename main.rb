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

cmd = 'wget http://www.particleflux.co.uk'
Open3.popen2e(cmd) do |stdin, stdout_err, wait_thr|
  while line = stdout_err.gets
    line = line.split(" ")
    h["status"] = line[6]
	puts h
	coll.update({"_id" => "1"}, h)
  end

  exit_status = wait_thr.value
  unless exit_status.success?
    abort "FAILED !!! #{cmd}"
  end
end
