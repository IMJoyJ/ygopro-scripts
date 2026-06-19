--検問
-- 效果：
-- ①：对方怪兽的攻击宣言时才能发动。对方手卡全部确认，那之中有怪兽卡的场合，那次攻击无效。那之后，自己从对方手卡选1只怪兽丢弃。
function c94861297.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。对方手卡全部确认，那之中有怪兽卡的场合，那次攻击无效。那之后，自己从对方手卡选1只怪兽丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES_OPPO)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c94861297.condition)
	e1:SetTarget(c94861297.target)
	e1:SetOperation(c94861297.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：对方怪兽攻击宣言时
function c94861297.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方（即对方怪兽攻击宣言时）
	return tp~=Duel.GetTurnPlayer()
end
-- 发动准备：检查对方手卡是否至少有1张
function c94861297.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查对方手卡数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
end
-- 效果处理：确认对方手卡，若有怪兽卡则无效攻击并选1只丢弃
function c94861297.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡的所有卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 给己方玩家确认对方的所有手卡
		Duel.ConfirmCards(tp,g)
		local tg=g:Filter(Card.IsType,nil,TYPE_MONSTER)
		-- 若确认的手卡中存在怪兽卡，则尝试无效该次攻击
		if tg:GetCount()>0 and Duel.NegateAttack() then
			-- 中断当前效果，使后续的丢弃手卡处理视为不同时处理
			Duel.BreakEffect()
			-- 设置提示信息为选择要丢弃的手卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
			local hg=tg:Select(tp,1,1,nil)
			-- 将选中的怪兽卡因效果丢弃送去墓地
			Duel.SendtoGrave(hg,REASON_EFFECT+REASON_DISCARD)
		end
		-- 洗切对方的手卡
		Duel.ShuffleHand(1-tp)
	end
end
