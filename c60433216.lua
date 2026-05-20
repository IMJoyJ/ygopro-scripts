--キング・スカーレット
-- 效果：
-- ①：自己的「红莲魔」怪兽进行战斗的伤害计算时才能把这张卡发动。那只自己怪兽不会被那次战斗破坏，这张卡变成通常怪兽（恶魔族·调整·炎·1星·攻/守0）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。
function c60433216.initial_effect(c)
	-- ①：自己的「红莲魔」怪兽进行战斗的伤害计算时才能把这张卡发动。那只自己怪兽不会被那次战斗破坏，这张卡变成通常怪兽（恶魔族·调整·炎·1星·攻/守0）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c60433216.condition)
	e1:SetTarget(c60433216.target)
	e1:SetOperation(c60433216.activate)
	c:RegisterEffect(e1)
end
-- 判断进行战斗的怪兽是否为自己场上的「红莲魔」怪兽，且该怪兽仍处于战斗状态
function c60433216.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是对方的，则将目标怪兽切换为被攻击的怪兽（即自己场上的怪兽）
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	return tc and tc:IsSetCard(0x1045) and tc:IsRelateToBattle()
end
-- 判断是否满足发动卡片的效果处理条件（怪兽区域有空位，且玩家可以特殊召唤该陷阱怪兽）
function c60433216.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上的主要怪兽区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以将这张卡作为特定属性、种族、等级、攻守的陷阱怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,60433216,0,TYPES_NORMAL_TRAP_MONSTER+TYPE_TUNER,0,0,1,RACE_FIEND,ATTRIBUTE_FIRE) end
	-- 设置连锁的操作信息为将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行卡片发动时的效果处理：使进行战斗的自己怪兽不会被该次战斗破坏，并将这张卡作为陷阱怪兽特殊召唤
function c60433216.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是对方的，则将目标怪兽切换为被攻击的怪兽（即自己场上的怪兽）
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	if not tc or not tc:IsRelateToBattle() then return end
	local c=e:GetHandler()
	-- 那只自己怪兽不会被那次战斗破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	tc:RegisterEffect(e1)
	-- 检查此时是否仍能将这张卡作为陷阱怪兽特殊召唤，若不能则结束效果处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,60433216,0,TYPES_NORMAL_TRAP_MONSTER+TYPE_TUNER,0,0,1,RACE_FIEND,ATTRIBUTE_FIRE) then return end
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TUNER+TYPE_TRAP)
	-- 将这张卡在自己的怪兽区域以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
end
