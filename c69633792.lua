--エヴォルダー・テリアス
-- 效果：
-- 这张卡用名字带有「进化虫」的怪兽的效果特殊召唤成功时，这张卡的攻击力下降500。
function c69633792.initial_effect(c)
	-- 这张卡用名字带有「进化虫」的怪兽的效果特殊召唤成功时，这张卡的攻击力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69633792,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 设置效果的发动条件为用名字带有「进化虫」的怪兽的效果特殊召唤成功
	e1:SetCondition(aux.evospcon)
	e1:SetOperation(c69633792.atkop)
	c:RegisterEffect(e1)
end
-- 攻击力下降效果的具体执行操作：若自身表侧表示存在且仍与效果相关联，则使其攻击力下降500
function c69633792.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力下降500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
