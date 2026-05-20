--機械王－B.C.3000
-- 效果：
-- 这张卡发动后变成怪兽卡（机械族·地·4星·攻/守1000）在自己的怪兽卡区域特殊召唤。只在这个效果特殊召唤的场合，1回合1次，可以把自己场上存在的1只机械族怪兽解放，这张卡的攻击力直到结束阶段时上升解放的怪兽的攻击力数值。这张卡发动的回合，自己不能把怪兽召唤·特殊召唤。（这张卡也当作陷阱卡使用）
function c70406920.initial_effect(c)
	-- 这张卡发动后变成怪兽卡（机械族·地·4星·攻/守1000）在自己的怪兽卡区域特殊召唤。这张卡发动的回合，自己不能把怪兽召唤·特殊召唤。（这张卡也当作陷阱卡使用）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c70406920.cost)
	e1:SetTarget(c70406920.target)
	e1:SetOperation(c70406920.activate)
	c:RegisterEffect(e1)
	-- 只在这个效果特殊召唤的场合，1回合1次，可以把自己场上存在的1只机械族怪兽解放，这张卡的攻击力直到结束阶段时上升解放的怪兽的攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70406920,0))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c70406920.atkcon)
	e2:SetCost(c70406920.atkcost)
	e2:SetOperation(c70406920.atkop)
	c:RegisterEffect(e2)
end
-- 发动的Cost：检查本回合是否进行过召唤或特殊召唤，并注册本回合不能进行召唤·特殊召唤的誓约效果
function c70406920.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前，检查本回合玩家是否进行过通常召唤或特殊召唤
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SUMMON)==0 and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不能把怪兽召唤·特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(c70406920.sumlimit)
	-- 给玩家注册不能特殊召唤（除此卡发动效果以外）的誓约效果
	Duel.RegisterEffect(e1,tp)
	-- 这张卡发动后变成怪兽卡（机械族·地·4星·攻/守1000）在自己的怪兽卡区域特殊召唤。只在这个效果特殊召唤的场合，1回合1次，可以把自己场上存在的1只机械族怪兽解放，这张卡的攻击力直到结束阶段时上升解放的怪兽的攻击力数值。这张卡发动的回合，自己不能把怪兽召唤·特殊召唤。（这张卡也当作陷阱卡使用）
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	-- 给玩家注册不能通常召唤的誓约效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制特殊召唤的过滤函数，允许由本卡发动效果（e）进行的特殊召唤，阻止其他特殊召唤
function c70406920.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return e:GetLabelObject()~=se
end
-- 发动的Target：检查怪兽区域空格以及是否能将此卡作为怪兽特殊召唤
function c70406920.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己的怪兽区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能将此卡作为特定属性、种族、攻守和等级的怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,70406920,0,TYPES_EFFECT_TRAP_MONSTER,1000,1000,4,RACE_MACHINE,ATTRIBUTE_EARTH) end
	-- 设置特殊召唤的操作信息，包含此卡自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 发动的Operation：将此卡作为怪兽卡特殊召唤到怪兽区域
function c70406920.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，再次检查是否能将此卡作为怪兽特殊召唤
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,70406920,0,TYPES_EFFECT_TRAP_MONSTER,1000,1000,4,RACE_MACHINE,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将此卡以自身效果特殊召唤到场上，并标记特殊召唤类型为SUMMON_VALUE_SELF
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 攻击力上升效果的发动条件：此卡必须是由自身效果特殊召唤的场合
function c70406920.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 攻击力上升效果的Cost：解放自己场上1只除自身以外的机械族怪兽，并记录其攻击力
function c70406920.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在除自身以外可解放的机械族怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,e:GetHandler(),RACE_MACHINE) end
	-- 选择场上1只除自身以外的机械族怪兽作为解放对象
	local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,e:GetHandler(),RACE_MACHINE)
	e:SetLabel(g:GetFirst():GetAttack())
	-- 将选中的怪兽作为Cost解放
	Duel.Release(g,REASON_COST)
end
-- 攻击力上升效果的Operation：使此卡的攻击力上升被解放怪兽的攻击力数值，直到结束阶段
function c70406920.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 这张卡的攻击力直到结束阶段时上升解放的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(e:GetLabel())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
