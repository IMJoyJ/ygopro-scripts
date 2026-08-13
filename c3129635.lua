--カース・オブ・スタチュー
-- 效果：
-- 这张卡发动后变成怪兽卡（岩石族·暗·4星·攻1800/守1000）在自己的怪兽卡区域特殊召唤。这张卡在场上当作怪兽使用而存在，这张卡以外的当作怪兽使用的陷阱卡和对方怪兽进行战斗的场合，那只对方怪兽在伤害计算后破坏。这张卡也当作陷阱卡使用。
function c3129635.initial_effect(c)
	-- 这张卡发动后变成怪兽卡（岩石族·暗·4星·攻1800/守1000）在自己的怪兽卡区域特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c3129635.target)
	e1:SetOperation(c3129635.activate)
	c:RegisterEffect(e1)
	-- 这张卡在场上当作怪兽使用而存在，这张卡以外的当作怪兽使用的陷阱卡和对方怪兽进行战斗的场合，那只对方怪兽在伤害计算后破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3129635,0))  --"破坏"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCondition(c3129635.descon)
	e2:SetTarget(c3129635.destg)
	e2:SetOperation(c3129635.desop)
	c:RegisterEffect(e2)
end
-- 效果发动的发动条件检查：确认该效果的COST检查已通过、自己主要怪兽区域有空位、且自己能够特殊召唤该陷阱怪兽（岩石族·暗·4星·攻1800/守1000），满足才可发动。
function c3129635.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否有可用的主要怪兽区域空格，以确保这张卡发动后能特殊召唤到怪兽区。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己是否满足特殊召唤该陷阱怪兽的条件，包括种族、属性、等级、攻击力、守备力等召唤参数是否允许。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,3129635,0,TYPES_EFFECT_TRAP_MONSTER,1800,1000,4,RACE_ROCK,ATTRIBUTE_DARK) end
	-- 将本次连锁的操作信息登记为特殊召唤，对象为这张卡自身，数量为1，使其他卡能响应这次特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：获取这张卡，再次确认仍能特殊召唤后，将其赋予怪兽属性（效果怪兽+陷阱卡），然后以自身效果特殊召唤到自己的主要怪兽区。
function c3129635.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次检查是否仍能特殊召唤该陷阱怪兽，若不能则直接结束效果处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,3129635,0,TYPES_EFFECT_TRAP_MONSTER,1800,1000,4,RACE_ROCK,ATTRIBUTE_DARK) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将这张卡以表侧表示特殊召唤到自己的主要怪兽区；使用自身效果作为特殊召唤方式，不检查召唤条件，检查苏生限制。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 破坏效果的发动条件：仅当这张卡是以自身效果特殊召唤成功的陷阱怪兽状态时才可发动，避免非怪兽状态的此卡触发。
function c3129635.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 破坏效果的发动时点检查：根据本次战斗的攻防双方，判断是否存在“这张卡以外的当作怪兽使用的陷阱卡与对方怪兽战斗”的情况，以此确定可否发动并锁定破坏对象。
function c3129635.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽（直接攻击时为nil）。
	local d=Duel.GetAttackTarget()
	if chk==0 then
		if a:IsControler(tp) then return d and a~=e:GetHandler() and bit.band(a:GetOriginalType(),TYPE_TRAP)~=0
		else return d and d~=e:GetHandler() and bit.band(d:GetOriginalType(),TYPE_TRAP)~=0 end
	end
	if a:IsControler(tp) then
		-- 当己方的陷阱怪兽是攻击方时，将操作信息登记为破坏对方怪兽（被攻击方）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,d,1,0,0)
		e:SetLabelObject(d)
	else
		-- 当对方的怪兽是攻击方、己方的陷阱怪兽是被攻击方时，将操作信息登记为破坏对方怪兽（攻击方）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,a,1,0,0)
		e:SetLabelObject(a)
	end
end
-- 效果处理：从效果标签中取出要破坏的对方怪兽，若其仍与本次战斗关联（未被转移或离场等），则将其破坏。
function c3129635.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() then
		-- 以效果原因破坏该对方怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
