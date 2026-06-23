--隣の芝刈り
-- 效果：
-- ①：自己卡组的数量比对方多的场合才能发动。直到卡组数量变成和对方相同为止，从自己卡组上面把卡送去墓地。
function c11110587.initial_effect(c)
	-- ①：自己卡组的数量比对方多的场合才能发动。直到卡组数量变成和对方相同为止，从自己卡组上面把卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c11110587.condition)
	e1:SetTarget(c11110587.target)
	e1:SetOperation(c11110587.activate)
	c:RegisterEffect(e1)
end
-- 检查是否满足发动条件
function c11110587.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己卡组数量是否大于对方卡组数量
	return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
end
-- 设置效果的发动目标
function c11110587.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算自己卡组与对方卡组数量差值
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)-Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
	-- 判断是否可以发动此效果
	if chk==0 then return ct>0 and Duel.IsPlayerCanDiscardDeck(tp,ct) end
	-- 设置连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
end
-- 设置效果的发动时点
function c11110587.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 计算自己卡组与对方卡组数量差值
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)-Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
	if ct>0 then
		-- 将指定数量的卡从自己卡组顶部送去墓地
		Duel.DiscardDeck(tp,ct,REASON_EFFECT)
	end
end
