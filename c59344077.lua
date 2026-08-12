--マジック・ドレイン
-- 效果：
-- 对方的魔法发动的时候才可以发动。对方从手卡丢弃1张魔法卡就可以使这张卡无效化。如果对方不丢弃的场合，对方的魔法卡的发动无效化并破坏。
function c59344077.initial_effect(c)
	-- 对方的魔法发动的时候才可以发动。对方从手卡丢弃1张魔法卡就可以使这张卡无效化。如果对方不丢弃的场合，对方的魔法卡的发动无效化并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c59344077.condition)
	e1:SetOperation(c59344077.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数
function c59344077.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方发动的魔法卡的发动，且该连锁的发动可以被无效
	return rp==1-tp and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 定义效果处理函数
function c59344077.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查本卡（魔力抽取）的效果是否可以被无效
	if Duel.IsChainDisablable(0) then
		local sel=1
		-- 获取对方手牌中的所有魔法卡
		local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_HAND,nil,TYPE_SPELL)
		-- 向对方玩家提示是否要丢弃一张魔法卡
		Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(59344077,0))  --"是否要丢弃一张魔法卡？"
		if g:GetCount()>0 then
			-- 如果对方手牌有魔法卡，让对方选择“是”（丢弃）或“否”（不丢弃）
			sel=Duel.SelectOption(1-tp,1213,1214)
		else
			-- 如果对方手牌没有魔法卡，则强制让对方选择“否”（不丢弃）
			sel=Duel.SelectOption(1-tp,1214)+1
		end
		if sel==0 then
			-- 向对方玩家提示选择要丢弃的手牌
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
			local sg=g:Select(1-tp,1,1,nil)
			-- 将对方选择的魔法卡作为效果丢弃送去墓地
			Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
			-- 使本卡（魔力抽取）的效果无效
			Duel.NegateEffect(0)
			return
		end
	end
	-- 如果对方不丢弃，则使对方魔法卡的发动无效，并检查该卡是否在场
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该对方的魔法卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
