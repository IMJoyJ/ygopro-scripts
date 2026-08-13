--インフェルニティ・アーチャー
-- 效果：
-- 自己手卡是0张的场合，这张卡可以直接攻击对方玩家。
function c18724123.initial_effect(c)
	-- 自己手卡是0张的场合，这张卡可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c18724123.con)
	c:RegisterEffect(e1)
end
-- 直接攻击效果的发动条件函数：判定当前效果控制者（这张卡的控制者）的手牌数是否为0，条件满足时才允许直接攻击。
function c18724123.con(e)
	-- 获取效果控制者手牌区的卡牌数量，并与0比较，用于判断其手卡是否为0张。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)==0
end
