--F.A.ハングオンマッハ
-- 效果：
-- ①：这张卡的攻击力上升这张卡的等级×300，不受原本的等级或者阶级比这张卡的等级低的对方怪兽发动的效果影响。
-- ②：「方程式运动员」魔法·陷阱卡的效果发动的场合才能发动（伤害步骤也能发动）。这张卡的等级上升1星。
-- ③：这张卡的等级是7星以上的场合，被送去对方墓地的卡不去墓地而除外。
function c93449450.initial_effect(c)
	-- ①：这张卡的攻击力上升这张卡的等级×300
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c93449450.atkval)
	c:RegisterEffect(e1)
	-- 不受原本的等级或者阶级比这张卡的等级低的对方怪兽发动的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c93449450.immval)
	c:RegisterEffect(e2)
	-- ②：「方程式运动员」魔法·陷阱卡的效果发动的场合才能发动（伤害步骤也能发动）。这张卡的等级上升1星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(93449450,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e3:SetCondition(c93449450.lvcon)
	e3:SetOperation(c93449450.lvop)
	c:RegisterEffect(e3)
	-- ③：这张卡的等级是7星以上的场合，被送去对方墓地的卡不去墓地而除外。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c93449450.excon)
	e4:SetTarget(c93449450.extg)
	e4:SetTargetRange(0,LOCATION_DECK)
	e4:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e4)
end
-- 计算并返回这张卡的等级×300的数值，用于增加攻击力
function c93449450.atkval(e,c)
	return c:GetLevel()*300
end
-- 判定对方发动的怪兽效果，若其原本等级或阶级低于自身当前等级则使自身免疫该效果
function c93449450.immval(e,te)
	if te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_MONSTER) and te:IsActivated() then
		local lv=e:GetHandler():GetLevel()
		local tc=te:GetHandler()
		if tc:GetRank()>0 then
			return tc:GetOriginalRank()<lv
		elseif tc:GetLevel()>0 then
			return tc:GetOriginalLevel()<lv
		else return false end
	else return false end
end
-- 检查发动的效果是否为「方程式运动员」魔法·陷阱卡的效果
function c93449450.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetHandler():IsSetCard(0x107)
end
-- 使自身等级上升1星
function c93449450.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的等级上升1星。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_UPDATE_LEVEL)
		e4:SetValue(1)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e4)
	end
end
-- 检查这张卡的等级是否在7星以上
function c93449450.excon(e)
	return e:GetHandler():IsLevelAbove(7)
end
-- 过滤出持有者为对方的卡片（即送去对方墓地的卡）
function c93449450.extg(e,c)
	return c:GetOwner()~=e:GetHandlerPlayer()
end
