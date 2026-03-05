--古生代化石竜 スカルギオス
-- 效果：
-- 岩石族怪兽＋对方墓地的7星以上的怪兽
-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。
-- ①：这张卡和对方怪兽进行战斗的伤害计算前才能发动。那只对方怪兽的攻击力和守备力直到那次伤害步骤结束时交换。
-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ③：融合召唤的这张卡和对方怪兽的战斗给与对方的战斗伤害变成2倍。
function c21225115.initial_effect(c)
	-- 记录该卡具有「化石融合」这张卡的卡片密码，用于特殊召唤条件判断
	aux.AddCodeList(c,59419719)
	c:EnableReviveLimit()
	-- 设置融合召唤所需的素材条件：一方为岩石族怪兽，另一方为对方墓地7星以上的怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_ROCK),c21225115.matfilter,true)
	-- ①：这张卡和对方怪兽进行战斗的伤害计算前才能发动。那只对方怪兽的攻击力和守备力直到那次伤害步骤结束时交换。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该效果的值为FossilFusionLimit函数，用于判断是否满足化石融合的特殊召唤条件
	e1:SetValue(aux.FossilFusionLimit)
	c:RegisterEffect(e1)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21225115,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_CONFIRM)
	e2:SetCondition(c21225115.atkcon)
	e2:SetOperation(c21225115.atkop)
	c:RegisterEffect(e2)
	-- ③：融合召唤的这张卡和对方怪兽的战斗给与对方的战斗伤害变成2倍。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
	-- 设置战斗伤害变为2倍的效果值为DOUBLE_DAMAGE常量
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e4:SetCondition(c21225115.damcon)
	-- 设置融合召唤的这张卡和对方怪兽的战斗给与对方的战斗伤害变成2倍
	e4:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e4)
end
-- 定义融合素材过滤函数：判断怪兽是否为怪兽类型、等级7以上、在对方墓地且为对方控制
function c21225115.matfilter(c,fc)
	return c:IsFusionType(TYPE_MONSTER) and c:IsLevelAbove(7) and c:IsLocation(LOCATION_GRAVE) and c:IsControler(1-fc:GetControler())
end
-- 判断是否满足效果发动条件：自身和对方怪兽均处于战斗状态且对方怪兽为表侧表示、守备力大于0、攻击力与守备力不同且为对方控制
function c21225115.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle() and bc:IsDefenseAbove(0)
		and bc:GetAttack()~=bc:GetDefense() and bc:IsControler(1-tp)
end
-- 执行效果操作：交换对方怪兽的攻击力与守备力
function c21225115.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if tc:IsFaceup() and tc:IsRelateToBattle() and tc:IsControler(1-tp) then
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		if atk==def then return end
		-- 设置对方怪兽的攻击力为指定值（原守备力）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(def)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
		-- 设置对方怪兽的守备力为指定值（原攻击力）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(atk)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e2)
	end
end
-- 判断是否满足效果发动条件：自身处于战斗状态且为融合召唤方式特殊召唤
function c21225115.damcon(e)
	return e:GetHandler():GetBattleTarget()~=nil and e:GetHandler():GetSummonType()&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION
end
