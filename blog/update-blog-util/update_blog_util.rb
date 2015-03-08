# made by Christian Barentine 2015
=begin
input: the util preferences file, and the name of a new blog file
          -or-
      an existing blog file
output: a new blog html file with updated links and empty content OR a replacement of an old blog post with the same, but with updated links.

Steps:
==========================================
Goal 1: create new blog file from template
==========================================
1: load the blog template file into an array
2. load the util prefs and parse into instance variables
3. search the blog template array to find the navigation section
4. search the navigation section to find the appropriate lines for the links
5. search the specified directory for filenames starting with t# or c# as specified by the util preferences
6. for each file found, insert the link code from the util prefs into the appropriate line in the navigation block
7. write the array to the file.



==========================================
Goal 2: update existing blog file with current links
==========================================

=end

=begin
path = '/tmp/foo'
lines = IO.readlines(path).map do |line|
  'Kilroy was here ' + line
end
File.open(path, 'w') do |file|
  file.puts lines
end


require 'tempfile'
require 'fileutils'

path = '/tmp/foo'
temp_file = Tempfile.new('foo')
begin
  File.open(path, 'r') do |file|
    file.each_line do |line|
      temp_file.puts 'Kilroy was here ' + line
    end
  end
  temp_file.close
  FileUtils.mv(temp_file.path, path)
ensure
  temp_file.close
  temp_file.unlink
end
=end

# loads a file and returns a new array with
# the lines of the file
def load_file(path)
  file_array = IO.readlines(path)
  file_array.map {|element| element.chomp}
end

# used in the parsing array to turn the strings 'true' and 'false' to their respective booleans
def to_boolean(string)
  string == 'true'
end

# parses the utility preferences file into a useful set of information
# returns a hash with the utility preference names as keys, and settings as values.
def parse_util_pref(array)
  temp_array = []
  utilHash = {}
  array.each {|line|
    if (line.chr != "#")
      # a '#' marks a comment line, so these lines should be ignored
      temp_array.push(line.split(";"))
    end
  }
  utilHash = Hash[temp_array]
  # the hash will have two values inside of it that are supposed to be boolean, but are currently strings.
  # these will need to be changed  before proceeding.
  utilHash["technical"] = to_boolean(utilHash["technical"])
  utilHash["cultural"] = to_boolean(utilHash["cultural"])
  return utilHash
end

# searches through the given file array for the FIRST instance of the specified
# string. returns the INDEX of the matching line in the array
def find_match_index (fileArray, match_string)
  fileArray.each_index {|index|
    if fileArray[index].include?(match_string)
      return index # no error checking, SO MAKE SURE THE MATCH EXISTS IN YOUR FILE
   end}
end

# given a file to look through and a util hash, finds the
# value of match_code in the document, and returns the line INDEX of the match.
# (this is the line's index in the file array, not the actual line number)
def find_code_insert_point (fileArray, utilHash)
  find_match_index(fileArray, utilHash["match_code"])
end

# locates the name of the link for THIS blogpost.
# I.e. the link text to get to the file that is being searched
# <!--link_name::name::-->
# takes the fileArray and utilHash and returns a string with the link name
def find_link_name (fileArray, utilHash)
  nameIndex = find_match_index(fileArray, utilHash["link_match"])
  return linkName = fileArray[nameIndex].split("::")[1] # the name should be the second element in the split array
end

#===========================
#Driver test code
#===========================
# list of util hash keys:
# template_path, blog_path, technical, cultural, match_code, link_match, link_code
utilFileArray = load_file("util_prefs.txt")
utilHash = parse_util_pref(utilFileArray)
p utilHash["link_match"]
#- - - - - - - -
blogTemplateArray = load_file(utilHash["template_path"])

p find_code_insert_point(blogTemplateArray, utilHash)
p find_link_name(blogTemplateArray, utilHash)

p Dir[utilHash["blog_path"] + "*.html"]
