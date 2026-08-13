--蘇りし魔王 ハ・デス
-- 效果：
-- 「僵尸带菌者」＋调整以外的不死族怪兽1只以上
-- 只要这张卡在场上表侧表示存在，自己场上存在的不死族怪兽战斗破坏的效果怪兽的效果无效化。
function c5309481.initial_effect(c)
	-- 声明此同调怪兽的素材包含卡号为33420078的「僵尸带菌者」，将其加入素材卡名列表以用于召唤限制判定。
	aux.AddMaterialCodeList(c,33420078)
	-- 为这张卡添加同调召唤手续：调整必须是「僵尸带菌者」（卡号33420078），调整以外的不死族怪兽1只以上，对应召唤素材条件「僵尸带菌者」＋调整以外的不死族怪兽1只以上。
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
-- 伤害计算后触发，获取攻击者和攻击目标，判断其中是否有一方是这张卡的控制者控制的不死族怪兽且被战斗破坏，确定要无效化的对象tc；若没有符合条件的对象则直接返回。
function c5309481.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前战斗的攻击目标怪兽（直接攻击时为nil）。
	local d=Duel.GetAttackTarget()
	local p=e:GetHandler():GetControler()
	if d==nil then return end
	local tc=nil
	if a:GetControler()==p and a:IsRace(RACE_ZOMBIE) and d:IsStatus(STATUS_BATTLE_DESTROYED) then tc=d
	elseif d:GetControler()==p and d:IsRace(RACE_ZOMBIE) and a:IsStatus(STATUS_BATTLE_DESTROYED) then tc=a end
	if not tc then return end
	-- 对应效果原文「效果怪兽的效果无效化」，给被战斗破坏的效果怪兽附加EFFECT_DISABLE，使其效果无效。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+0x17a0000)
	tc:RegisterEffect(e1)
	-- 对应效果原文「效果怪兽的效果无效化」，给被战斗破坏的效果怪兽附加EFFECT_DISABLE_EFFECT，使其效果文本也无效且离场后仍无效。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+0x17a0000)
	tc:RegisterEffect(e2)
end
