--インセクト・プリンセス
-- 效果：
-- 只要这张卡在场上表侧表示存在，对方场上所有以表侧表示存在的昆虫族怪兽全部变成攻击表示。这张卡每战斗破坏1只昆虫族怪兽，攻击力上升500点。
function c37957847.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，对方场上所有以表侧表示存在的昆虫族怪兽全部变成攻击表示。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_POSITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c37957847.target)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e1)
	-- 这张卡每战斗破坏1只昆虫族怪兽，攻击力上升500点。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c37957847.atkcon)
	e2:SetOperation(c37957847.atkop)
	c:RegisterEffect(e2)
end
-- 判定候选怪兽是否为昆虫族，用于筛选出对方场上受到表侧攻击表示变更影响的昆虫族怪兽。
function c37957847.target(e,c)
	return c:IsRace(RACE_INSECT)
end
-- 获取这张卡战斗破坏的怪兽，并判断其是否为昆虫族，若为昆虫族则满足攻击力上升的触发条件。
function c37957847.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	return bc and bc:IsRace(RACE_INSECT)
end
-- 确认此卡仍与该效果存在联系后，赋予其攻击力上升500的持续效果。
function c37957847.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 攻击力上升500点。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
