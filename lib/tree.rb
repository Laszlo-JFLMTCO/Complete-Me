require './lib/node'
require 'pry'

class Tree
  attr_reader :root_node,
              :word_count,
              :suggestions,
              :weighted_suggestions

  def initialize
    @root_node = Node.new
  end

  def insert(word)
    add_to_tree(atomize(word))
    word
  end

  def atomize(word)
    word.chars
  end

  def add_to_tree(node = root_node, letters)
    return if letters.empty?
    letter = letters.shift
    go_to_node(node, letters, letter) if node.has_child?(letter)
    make_child(node, letters, letter) unless node.has_child?(letter)
  end

  def go_to_node(node, letters, letter)
    terminate_word(node, letter) if letters.empty?
    child = node.find_child(letter)
    add_to_tree(child, letters)
  end

  def terminate_word(node, letter)
    node.find_child(letter).set_terminator
  end

  def make_child(node, letters, letter)
    child_node = node.add_child(letter)
    child_node.set_terminator if letters.empty?
    add_to_tree(child_node, letters)
  end

  def count(node = root_node)
    @word_count = 0
    count_children(node)
    return word_count
  end

  def count_children(node)
    @word_count += 1 if node.terminator?
    continue_count(node)
  end

  def continue_count(node)
    node.children.each do |child|
      count_children(child)
    end
  end

  def import(all_words)
    separated_words = parse(all_words)
    insert_words(separated_words)
  end

  def parse(all_words)
    all_words.split("\n")
  end

  def insert_words(words)
    words.each { |word| insert(word) }
  end

  def clean_suggestions
    @suggestions = []
    @weighted_suggestions = []
  end

  def suggest(stub)
    clean_suggestions

    stub_node = find_stub_node(atomize(stub))
    return [] if stub_node.nil?

    used_words = stub_node.sorted_selections
    words_on_branch(stub_node, stub)

    return @weighted_suggestions = used_words | suggestions
  end

  def words_on_branch(stub_node, stub)
    assemble_word(stub_node,stub) if stub_node.has_children?
    return suggestions.sort
  end

  def assemble_word(stub_node, stub)
    stub_node.children.each do |child_node|
      find_words_on_branch(child_node, stub)
    end
  end

  def find_words_on_branch(node, word_suggestion)
    word_suggestion += node.letter
    suggestions << word_suggestion if node.terminator?
    continue_find(node, word_suggestion)
  end

  def continue_find(node, word_suggestion)
    if node.has_children?
      node.children.each do |child_node|
        find_words_on_branch(child_node, word_suggestion)
      end
    end
  end

  def find_stub_node(node = root_node, letters)
    return node if done_stubing?(node, letters)
    letter = letters.shift
    child = node.find_child(letter)
    find_stub_node(child, letters)
  end

  def done_stubing?(node, letters)
    letters.empty? || node.nil? || node.is_leaf? 
  end

  def select(stub, word)
    letters = atomize(stub)
    return unless root_node.has_child?(letters.first)
    stub_node = find_stub_node(letters)
    stub_node.add_selected(word)
  end


  

end
