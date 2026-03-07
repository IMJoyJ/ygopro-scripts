--イタチの大暴発
-- 效果：
-- ①：对方场上的表侧表示怪兽的攻击力合计数值比自己基本分高的场合才能发动。直到对方场上的表侧表示怪兽的攻击力合计数值变成自己基本分以下为止，对方必须选自身场上的攻击力是0以外的表侧表示怪兽回到持有者卡组。
function c31044787.initial_effect(c)
	-- 效果原文内容：①：对方场上的表侧表示怪兽的攻击力合计数值比自己基本分高的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(c31044787.condition)
	e1:SetTarget(c31044787.target)
	e1:SetOperation(c31044787.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤出对方场上表侧表示且攻击力大于0的怪兽，以及该玩家可以将其送入卡组的条件
function c31044787.filter(c,tp)
	-- 效果原文内容：对方场上的表侧表示怪兽的攻击力合计数值比自己基本分高的场合才能发动
	return c:IsFaceup() and c:GetAttack()>0 and Duel.IsPlayerCanSendtoDeck(tp,c)
end
-- 效果作用：计算对方场上所有表侧表示怪兽的攻击力总和，并与自己的基本分比较
function c31044787.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取对方场上所有表侧表示且攻击力大于0的怪兽组
	local g=Duel.GetMatchingGroup(c31044787.filter,tp,0,LOCATION_MZONE,nil,1-tp)
	local atk=g:GetSum(Card.GetAttack)
	-- 效果作用：判断对方场上怪兽攻击力总和是否大于自己的基本分
	return atk>Duel.GetLP(tp)
end
-- 效果原文内容：直到对方场上的表侧表示怪兽的攻击力合计数值变成自己基本分以下为止，对方必须选自身场上的攻击力是0以外的表侧表示怪兽回到持有者卡组
function c31044787.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：设置连锁处理信息，表示将要处理的卡是对方场上的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_MZONE)
end
-- 效果作用：处理攻击力超过16位的数值，防止溢出
function c31044787.getAttack(c)
	local atk=c:GetAttack()
	if atk>0xffff then atk=(atk&0x7fffffff)|0x80000000 end
	return atk
end
-- 效果作用：检索满足条件的怪兽组并将其送入卡组
function c31044787.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取对方场上所有表侧表示且攻击力大于0的怪兽组
	local g=Duel.GetMatchingGroup(c31044787.filter,tp,0,LOCATION_MZONE,nil,1-tp)
	local atk=g:GetSum(Card.GetAttack)
	-- 效果作用：获取自己的基本分
	local lp=Duel.GetLP(tp)
	local diff=atk-lp
	if diff<=0 then return end
	-- 效果作用：提示对方选择要送入卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:SelectWithSumGreater(1-tp,c31044787.getAttack,diff)
	-- 效果作用：将选中的怪兽送入卡组并洗牌
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_RULE,1-tp)
end
