--F.A.ソニックマイスター
-- 效果：
-- ①：这张卡的攻击力上升这张卡的等级×300，不会被和原本的等级或者阶级比这张卡的等级低的对方怪兽的战斗破坏。
-- ②：「方程式运动员」魔法·陷阱卡的效果发动的场合才能发动（伤害步骤也能发动）。这张卡的等级上升1星。
-- ③：这张卡的等级是7星以上的场合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
function c67045745.initial_effect(c)
	-- ①：这张卡的攻击力上升这张卡的等级×300
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c67045745.atkval)
	c:RegisterEffect(e1)
	-- 不会被和原本的等级或者阶级比这张卡的等级低的对方怪兽的战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(c67045745.indval)
	c:RegisterEffect(e2)
	-- ②：「方程式运动员」魔法·陷阱卡的效果发动的场合才能发动（伤害步骤也能发动）。这张卡的等级上升1星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(67045745,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e3:SetCondition(c67045745.lvcon)
	e3:SetOperation(c67045745.lvop)
	c:RegisterEffect(e3)
	-- ③：这张卡的等级是7星以上的场合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e4:SetCondition(c67045745.excon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 计算并返回这张卡上升的攻击力数值（自身等级×300）
function c67045745.atkval(e,c)
	return c:GetLevel()*300
end
-- 判断进行战斗的对方怪兽的原本等级或阶级是否低于这张卡的当前等级
function c67045745.indval(e,c)
	local lv=e:GetHandler():GetLevel()
	if c:GetRank()>0 then
		return c:GetOriginalRank()<lv
	elseif c:GetLevel()>0 then
		return c:GetOriginalLevel()<lv
	else return false end
end
-- 检查发动的效果是否为「方程式运动员」魔法·陷阱卡的效果
function c67045745.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetHandler():IsSetCard(0x107)
end
-- 若这张卡在场上表侧表示存在，则使其等级上升1星
function c67045745.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的等级上升1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 检查这张卡的等级是否在7星以上
function c67045745.excon(e)
	return e:GetHandler():IsLevelAbove(7)
end
