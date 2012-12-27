class Collection
  include Enumerable

  attr_reader :songs_array

  def self.parse(text)
    lines_as_array = (text.lines.map { |song| song.split("\n") }).flatten
    collection = Collection.new(lines_as_array)
  end

  def initialize(lines_as_array)
    @songs_array = []
    lines_as_array.each_slice(3) do |song|
      @songs_array << Song.new(song[0], song[1], song[2])
    end
  end

  def each
    @songs_array.each { |song| yield song }
  end

  def names
    names = []
    each { |song| names << song.name }
    names.uniq
  end

  def artists
    artists = []
    each { |song| artists << song.artist }
    artists.uniq
  end

  def albums
    albums = []
    each { |song| albums << song.album }
    albums.uniq
  end

  def filter(criteria)
    filtered_songs = (@songs_array.select { |song| criteria.match?(song) }).uniq
    sub_collection = SubCollection.new(filtered_songs)
  end
end

class SubCollection < Collection
  def initialize(songs_array)
    @songs_array = songs_array
  end

  def adjoin(other)
    unite_collection = SubCollection.new((@songs_array+other.songs_array).uniq)
  end
end

class Song
  include Comparable

  attr_reader :name, :artist, :album

  def initialize(name,artist,album)
    @name, @artist, @album = name, artist, album
  end

  def hash
    (name+artist+album).hash
  end

  def eql?(other)
    self == other
  end

  def ==(other)
    name == other.name and artist == other.artist and album == other.album
  end
end

class Criteria
  attr_reader :type, :value

  def self.name(song_name)
    criteria = Criteria.new(:name,song_name)
  end

  def self.artist(artist_name)
    criteria = Criteria.new(:artist,artist_name)
  end

  def self.album(album_name)
    criteria = Criteria.new(:album,album_name)
  end

  def initialize(type, value)
    @type, @value = type, value
  end

  def match?(song)
    if @type == :name then song.name == @value
    elsif @type == :artist then song.artist == @value
    else song.album == @value
    end
  end

  def &(other)
    criteria = ConjunctionCriteria.new(@type, other.type, @value, other.value)
  end

  def |(other)
    criteria = DisjunctionCriteria.new(@type, other.type, @value, other.value)
  end

  def !
    criteria = NegationCriteria.new(@type, @value)
  end
end

class ConjunctionCriteria
  def initialize(type1, type2, value1, value2)
    @type1, @type2, @value1, @value2 = type1, type2, value1, value2
  end

  def match?(song)
    Criteria.new(@type1, @value1).match?(song) and
      Criteria.new(@type2, @value2).match?(song)
  end
end

class DisjunctionCriteria
  def initialize(type1, type2, value1, value2)
    @type1, @type2, @value1, @value2 = type1, type2, value1, value2
  end

  def match?(song)
    Criteria.new(@type1, @value1).match?(song) or
      Criteria.new(@type2, @value2).match?(song)
  end
end

class NegationCriteria
  def initialize(type, value)
    @type, @value = type, value
  end

  def match?(song)
    not Criteria.new(@type, @value).match?(song)
  end

  def match?(song)
    not Criteria.new(@type, @value).match?(song)
  end
end
