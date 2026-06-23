--蘇りし魔王 ハ・デス
-- 效果：
-- 「僵尸带菌者」＋调整以外的不死族怪兽1只以上
-- 只要这张卡在场上表侧表示存在，自己场上存在的不死族怪兽战斗破坏的效果怪兽的效果无效化。
function c5309481.initial_effect(c)
	-- 为该怪兽添加融合召唤所需的素材代码列表，允许使用卡牌代码33420078作为素材
	aux.AddMaterialCodeList(c,33420078)
	-- 设置该怪兽的同调召唤条件：必须使用1只「僵尸带菌者」（卡牌代码33420078）作为调整，再配合1只以上调整以外的不死族怪兽进行同调召唤
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsCode,33420078),aux.NonTuner(Card.IsRace,RACE_ZOMBIE),1)
	c:EnableReviveLimit()
	-- 只要这张卡在场上表侧表示存在，自己场上存在的不死族怪兽战斗破坏的效果怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c5309481.operation)
	c:RegisterEffect(e1)
end
-- 判断攻击怪兽和防守怪兽中是否有己方的不死族怪兽被战斗破坏，若有则记录该被破坏的怪兽
function c5309481.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗中的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取此次战斗中的防守怪兽
	local d=Duel.GetAttackTarget()
	local p=e:GetHandler():GetControler()
	if d==nil then return end
	local tc=nil
	if a:GetControler()==p and a:IsRace(RACE_ZOMBIE) and d:IsStatus(STATUS_BATTLE_DESTROYED) then tc=d
	elseif d:GetControler()==p and d:IsRace(RACE_ZOMBIE) and a:IsStatus(STATUS_BATTLE_DESTROYED) then tc=a end
	if not tc then return end
	-- 使被战斗破坏的效果怪兽的效果无效
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+0x17a0000)
	tc:RegisterEffect(e1)
	-- 使被战斗破坏的效果怪兽的效果无效化
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+0x17a0000)
	tc:RegisterEffect(e2)
end
