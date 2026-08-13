--ダイナソーイング
-- 效果：
-- ①：这张卡不会被战斗破坏。
-- ②：这张卡被选择作为攻击对象的场合发动。这张卡的攻击力·守备力上升1000。
-- ③：这张卡攻击的伤害计算后发动。这张卡的②的效果上升的数值回到0。
function c27143874.initial_effect(c)
	-- ①：这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：这张卡被选择作为攻击对象的场合发动。这张卡的攻击力·守备力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27143874,0))  --"是否发动「缝制恐龙」的效果？"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetOperation(c27143874.operation)
	c:RegisterEffect(e2)
	-- ③：这张卡攻击的伤害计算后发动。这张卡的②的效果上升的数值回到0。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(27143874,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLED)
	e3:SetCondition(c27143874.retcon)
	e3:SetOperation(c27143874.retop)
	c:RegisterEffect(e3)
end
-- ②效果发动后的处理：检查这张卡是否仍与②效果关联且表侧表示，若是则为它赋予攻击力和守备力各上升1000的持续效果（直至离场、无效等标准重置）。
function c27143874.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 对应②中“攻击力”上升1000的部分：为这张卡赋予攻击力上升1000的持续效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
-- ③效果的发动条件：判定这次战斗的攻击怪兽是否就是这张卡自身。
function c27143874.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前攻击怪兽是否为效果持有者，是则③效果条件成立。
	return Duel.GetAttacker()==e:GetHandler()
end
-- ③效果处理：将这张卡因②效果产生的攻击力·守备力上升效果重置清除，使上升数值回到0。
function c27143874.retop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetEffect(RESET_DISABLE,RESET_EVENT)
end
