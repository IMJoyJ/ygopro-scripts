--アポピスの化神
-- 效果：
-- ①：自己·对方的主要阶段才能把这张卡发动。这张卡变成通常怪兽（爬虫类族·地·4星·攻1600/守1800）在怪兽区域特殊召唤（也当作陷阱卡使用）。
function c28649820.initial_effect(c)
	-- 创建效果，设置为陷阱卡发动效果，可特殊召唤，提示时点为主要阶段结束，无费用检查，设置连锁处理条件为自由连锁，设置发动条件、目标和效果处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c28649820.condition)
	e1:SetTarget(c28649820.target)
	e1:SetOperation(c28649820.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的条件判断函数，判断当前是否为自己的主要阶段1或主要阶段2
function c28649820.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 设置效果的目标函数，检查是否满足特殊召唤条件
function c28649820.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查玩家场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定参数的怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,28649820,0,TYPES_NORMAL_TRAP_MONSTER,1600,1800,4,RACE_REPTILE,ATTRIBUTE_EARTH) end
	-- 设置效果处理时的连锁信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，执行将此卡特殊召唤为怪兽的操作
function c28649820.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次检查玩家是否可以特殊召唤此卡，若不可以则返回
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,28649820,0,TYPES_NORMAL_TRAP_MONSTER,1600,1800,4,RACE_REPTILE,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP)
	-- 将此卡以通常怪兽形式特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
end
