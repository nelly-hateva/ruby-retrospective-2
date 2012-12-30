class Song
  attr_reader :name, :artist, :album

  def initialize(name, artist, album)
    @name, @artist, @album = name, artist, album
  end
end

class Collection
  include Enumerable

  attr_reader :songs

  def self.parse(text)
    songs = text.lines.each_slice(4).map do |name, artist, album|
      Song.new name.chomp, artist.chomp, album.chomp
    end
    new songs
  end

  def initialize(songs)
    @songs = songs
  end

  def each
    each { |song| yield song }
  end

  def names
    map(&:name).uniq
  end

  def artists
    map(&:artist).uniq
  end

  def albums
    map(&:album).uniq
  end

  def filter(criteria)
    Collection.new select { |song| criteria.matches?(song) }
  end

  def adjoin(other)
    Collection.new songs | other.songs
  end

  protected

  def songs
    @songs
  end
end

module Criteria
  def name(name)
    Criterion.new { |song| song.name == name }
  end

  def artist(artist)
    Criterion.new { |song| song.artist == artist }
  end

  def album(album)
    Criterion.new { |song| song.album == album }
  end
end

class Criterion
  def initialize(&block)
    @predicate = block
  end

  def matches?(song)
    @predicate.(song)
  end

  def &(other)
    Criterion.new { |song| self.matches?(song) and other.matches?(song) }
  end

  def |(other)
    Criterion.new { |song| self.matches?(song) or other.matches?(song) }
  end

  def !
    Criterion.new { |song| not self.matches?(song) }
  end
end
