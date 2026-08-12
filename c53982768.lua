--冥界の魔王 ハ・デス
-- 效果：
-- 这张卡不能作从墓地的特殊召唤。
-- ①：只要这张卡在怪兽区域存在，自己的恶魔族怪兽战斗破坏怪兽的场合，那破坏的怪兽只要在场上·墓地存在效果无效化。
function c53982768.initial_effect(c)
	-- 这张卡不能作从墓地的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，自己的恶魔族怪兽战斗破坏怪兽的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c53982768.operation)
	c:RegisterEffect(e2)
end
-- 在伤害计算后，判断是否由己方的恶魔族怪兽战斗破坏了对方怪兽，并获取该被破坏的怪兽
function c53982768.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗中进行攻击的怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗中被攻击的怪兽
	local d=Duel.GetAttackTarget()
	local p=e:GetHandler():GetControler()
	if d==nil then return end
	local tc=nil
	if a:GetControler()==p and a:IsRace(RACE_FIEND) and d:IsStatus(STATUS_BATTLE_DESTROYED) then tc=d
	elseif d:GetControler()==p and d:IsRace(RACE_FIEND) and a:IsStatus(STATUS_BATTLE_DESTROYED) then tc=a end
	if not tc then return end
	-- 那破坏的怪兽只要在场上·墓地存在效果无效化。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+0x17a0000)
	tc:RegisterEffect(e1)
	-- 那破坏的怪兽只要在场上·墓地存在效果无效化。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+0x17a0000)
	tc:RegisterEffect(e2)
end
