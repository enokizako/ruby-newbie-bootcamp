require_relative 'card.rb'

# このサンプルは、代入と四則演算と比較だけで力技でなんとかしてみるサンプルです
# 配列や配列が持っているメソッドなど、構文についての知識をなるべく減らしていき、
# 比較演算子とif/whileなどの、最低限の武器だけで戦うシミュレーション
class Hand
  # 判定に必要な要素をインスタンス変数としてあらかじめ追加しておく
  # 都合上、pairだけInteger、他がtrue/falseになってしまった
  attr_reader :cards, :rank, :straight, :flash, :pair, :three, :four, :royal

  # インスタンスの初期化時に呼ばれるが、
  # カードをうけとったら、次の行では判定してしまうのでここにすべてがある
  def initialize(draw_cards)
    @cards = draw_cards.map { |str| Card.new(str) }
    @rank = categorize
  end

  private

  # sortメソッドを知らない前提の力技
  # 繰り返しは4固定でなく配列のサイズで繰り返すとよい
  # 本来ならsort、最低でもmapメソッドをつかうべき
  def bubble_sort
    j = 0
    while j < 4
      # カード同士を比較し、大きい方を右に持っていくことをひとつずつ
      # ずらして続ければ、最終的に1番大きい数が右端まで寄せられる
      # そして繰り返せば、2番目に大きい数、3番目に大きい数というように、
      # 徐々に右側から順番が整えられていく
      # 詳しくはバブルソートで検索。
      j = j + 1
      i = 0
      while i < 4
        i = i + 1
        if @cards[i - 1].ordinal > @cards[i].ordinal
          @cards[i - 1], @cards[i] = @cards[i], @cards[i - 1]
        end
      end
    end
  end

  # 自分と同じカードが、自分を含めて何枚あるかをチェックする
  # ２枚が２つだとワンペア、２枚が４つだとツーペアになる
  def check_same_face
    @pair = 0
    @three = false
    @four = false
    j = 0
    # ５枚のカードそれぞれに対して処理をする
    while j < 5
      j = j + 1
      i = 0
      same = 0
      # 比較相手を変更しながら、自分と同じfaceかどうかを調べる
      while i < 5
        i = i + 1
        if @cards[j - 1].face == @cards[i - 1].face
          same = same + 1
        end
      end
      # 自分と同じfaceの数をチェックする
      # ３枚と４枚は２つ以上発生することがあり得ないので、
      # true/falseで判定する
      # ペアは、ペアの数で役が変わるので数で記録する
      if same == 2
        @pair = @pair + 1
      elsif same == 3
        @three = true
      elsif same == 4
        @four = true
      end
    end
  end

  # 0番目のカードとすべて同じsuitであればフラッシュ条件
  def judge_flush
    @flush = true
    i = 0
    while i < 4
      i = i + 1
      # と、いうことは逆に、0番目のカードとひとつでも異なる
      # suitであれば条件を満たさない、と考える
      if @cards[0].suit != @cards[i].suit
        @flush = false
      end
    end
  end

  # 前提としてカードの強さ順に並べ替えている前提でストレートの判定を行う
  def judge_straight
    @straight = true
    i = 0
    while i < 4
      i = i + 1
      # カードと１つ前のカードの強さの差が、1でないものがひとつでもあれば
      # ストレートの条件を満たさない
      if @straight && @cards[i].ordinal - @cards[i - 1].ordinal != 1
        @straight = false
      end
    end

    # カードのfaceのみ抽出する
    i = 0
    faces = []
    while i < 5
      faces[i] = @cards[i].face
      i = i + 1
    end
    # Aには特別ルールがあるので、強さの条件にあてはまらない場合でも、
    # カードのfaceが、一定のパターンの時はストレートとして判定する
    if faces == [:"2", :"3", :"4", :"5", :A]
      @straight = true
    end
  end 

  # ストレートの後半の応用で、faceが特定のパターンであればロイヤルとして扱う
  def judge_royal
    # ストレートのコードを流用
    i = 0
    faces = []
    while i < 5
      faces[i] = @cards[i].face
      i = i + 1
    end
    # faceのパターンの一致チェック
    if faces == [:"10", :J, :Q, :K, :A]
      @royal = true
    end
  end

  # ここで一気に役判定を行う
  # 明示的にreturnしなくても、最後に評価された変数が
  # 戻り値として扱われる
  def categorize
    # straightとroyalのチェックのためには並べ替えが必要
    bubble_sort

    # 役の判定に必要な条件をあらかじめ用意しておく
    # 判定に必要な要素は、すべてインスタンス変数として定義しておく
    check_same_face
    judge_flush
    judge_straight
    judge_royal

    # 条件の厳しい方（複数の条件がすべてあてはまるもの）を
    # 上にしておかないと、誤って緩い条件側と判定されてしまう
    if @pair == 2 && @three
      'full-house'
    elsif @pair == 2
      'one-pair'
    elsif @pair == 4
      'two-pair'
    elsif @three
      'three-of-a-kind'
    elsif @four
      'four-of-a-kind'
    elsif @royal && @straight && @flush
      'royal-straight-flush'
    elsif @straight && @flush
      'straight-flush'
    elsif @straight
      'straight'
    elsif @flush
      'flush'
    else
      'high-card'
    end
  end
end
