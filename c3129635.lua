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
-- 检查是否满足特殊召唤的条件，包括是否有足够的怪兽区域和是否可以特殊召唤该怪兽。
function c3129635.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查玩家的怪兽区域是否有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定参数的怪兽。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,3129635,0,TYPES_EFFECT_TRAP_MONSTER,1800,1000,4,RACE_ROCK,ATTRIBUTE_DARK) end
	-- 设置特殊召唤操作信息，用于连锁处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将卡片以怪兽形式特殊召唤到场上。
function c3129635.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次检查是否可以特殊召唤该怪兽，防止条件变化导致错误。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,3129635,0,TYPES_EFFECT_TRAP_MONSTER,1800,1000,4,RACE_ROCK,ATTRIBUTE_DARK) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将卡片以特殊召唤方式放入场上。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 判断此卡是否为特殊召唤入场。
function c3129635.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 设置破坏效果的目标，判断是否满足破坏条件。
function c3129635.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前攻击目标怪兽。
	local d=Duel.GetAttackTarget()
	if chk==0 then
		if a:IsControler(tp) then return d and a~=e:GetHandler() and bit.band(a:GetOriginalType(),TYPE_TRAP)~=0
		else return d and d~=e:GetHandler() and bit.band(d:GetOriginalType(),TYPE_TRAP)~=0 end
	end
	if a:IsControler(tp) then
		-- 设置破坏操作信息，目标为攻击怪兽。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,d,1,0,0)
		e:SetLabelObject(d)
	else
		-- 设置破坏操作信息，目标为攻击目标怪兽。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,a,1,0,0)
		e:SetLabelObject(a)
	end
end
-- 执行破坏操作，将符合条件的怪兽破坏。
function c3129635.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() then
		-- 将目标怪兽以效果原因破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
