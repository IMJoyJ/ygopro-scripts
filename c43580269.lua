--エメス・ザ・インフィニティ
-- 效果：
-- ①：这张卡战斗破坏对方怪兽送去墓地的场合发动。这张卡的攻击力上升700。
function c43580269.initial_effect(c)
	-- ①：这张卡战斗破坏对方怪兽送去墓地的场合发动。这张卡的攻击力上升700。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43580269,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c43580269.atcon)
	e1:SetOperation(c43580269.atop)
	c:RegisterEffect(e1)
end
-- 检查进行战斗的怪兽和战斗破坏的怪兽是否与效果相关，且被破坏怪兽来自对方墓地且是因为战斗破坏
function c43580269.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE)
end
-- 将自身攻击力上升700点
function c43580269.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身攻击力上升700
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(700)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
