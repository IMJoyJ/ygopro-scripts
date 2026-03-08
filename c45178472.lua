--フルハウス
-- 效果：
-- 选择这张卡以外的场上表侧表示存在的2张魔法·陷阱卡和盖放的3张魔法·陷阱卡才能发动。选择的卡破坏。
function c45178472.initial_effect(c)
	-- 效果原文内容：选择这张卡以外的场上表侧表示存在的2张魔法·陷阱卡和盖放的3张魔法·陷阱卡才能发动。选择的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c45178472.target)
	e1:SetOperation(c45178472.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：定义一个函数用于判断卡片是否为表侧表示的魔法·陷阱卡
function c45178472.up(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果作用：定义一个函数用于判断卡片是否为里侧表示的魔法·陷阱卡
function c45178472.down(c)
	return c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果作用：效果发动时的处理函数，用于判断是否满足选择目标的条件
function c45178472.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 效果作用：判断场上是否存在至少2张表侧表示的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c45178472.up,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,e:GetHandler())
		-- 效果作用：判断场上是否存在至少3张里侧表示的魔法·陷阱卡
		and Duel.IsExistingTarget(c45178472.down,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,3,e:GetHandler()) end
	-- 效果作用：向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择满足条件的2张表侧表示的魔法·陷阱卡作为目标
	local g1=Duel.SelectTarget(tp,c45178472.up,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,e:GetHandler())
	-- 效果作用：向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择满足条件的3张里侧表示的魔法·陷阱卡作为目标
	local g2=Duel.SelectTarget(tp,c45178472.down,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,3,3,e:GetHandler())
	g1:Merge(g2)
	-- 效果作用：设置本次连锁的操作信息，指定将要破坏5张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,5,0,0)
end
-- 效果作用：效果发动时的处理函数，用于执行破坏操作
function c45178472.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁中指定的目标卡组，并筛选出与当前效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 效果作用：以效果为原因破坏指定的卡组
	Duel.Destroy(g,REASON_EFFECT)
end
