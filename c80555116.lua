--ナチュル・ガーディアン
-- 效果：
-- 对方对怪兽的召唤成功时，这张卡的攻击力直到结束阶段时上升300。
function c80555116.initial_effect(c)
	-- 对方对怪兽的召唤成功时，这张卡的攻击力直到结束阶段时上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80555116,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c80555116.atkcon)
	e1:SetOperation(c80555116.atkop)
	c:RegisterEffect(e1)
end
-- 检查召唤怪兽的玩家是否为对方玩家。
function c80555116.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 若此卡在场上表侧表示存在且与效果有联系，则为其添加直到结束阶段时攻击力上升300的效果。
function c80555116.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到结束阶段时上升300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
