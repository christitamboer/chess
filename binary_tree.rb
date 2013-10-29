class TreeNode

  attr_accessor :parent, :children, :value  #getters and setters

  def initialize(parent, value)
    self.parent = parent
    self.parent.children << self unless parent.nil?
    self.value = value #value of the node
    self.children = []
  end



  def dfs(value, &blk)
    blk = Proc.new { |x,y| x == y } unless blk

    if blk.call(self.value,value)
      return self
    else
      ret = nil
      self.children.each do |child|
        #p child.value
        ret = child.dfs(value, &blk) unless child.nil?
        return ret unless ret.nil?# || ret.empty?
      end
      ret
    end
  end

  def bfs(value, &blk)
    check_nodes = []
    blk = Proc.new {|x,y| x == y} unless blk

    check_nodes << self
    until check_nodes.empty?
      front_node = check_nodes.shift
      return front_node if blk.call(front_node.value, value)
      check_nodes += front_node.children
    end
  end


  #TreeNode.new(nil,value) {self.right = Treenode.new...}
end

#a = TreeNode.new(nil,1)
#b = TreeNode.new(a,2)
#d = TreeNode.new(a,3)
#c = TreeNode.new(b,4)
#p a.dfs(2){|x,y| x > y }.value
#p a.bfs(2){|x,y| x > y }.value

