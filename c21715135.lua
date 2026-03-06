--ガガガ学園の緊急連絡網
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能作超量召唤以外的特殊召唤。
-- ①：只有对方场上才有怪兽存在的场合才能发动。从卡组把1只「我我我」怪兽特殊召唤。
function c21715135.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能作超量召唤以外的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,21715135+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c21715135.condition)
	e1:SetCost(c21715135.cost)
	e1:SetTarget(c21715135.target)
	e1:SetOperation(c21715135.activate)
	c:RegisterEffect(e1)
	-- 设置操作类型为特殊召唤、代号为21715135的计数器，用于记录是否已进行过非超量的特殊召唤。
	Duel.AddCustomActivityCounter(21715135,ACTIVITY_SPSUMMON,c21715135.counterfilter)
end
-- 过滤函数，判断卡片是否为超量召唤类型，用于计数器的过滤条件。
function c21715135.counterfilter(c)
	return c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果原文内容：只有对方场上才有怪兽存在的场合才能发动。
function c21715135.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方场上存在怪兽且自己场上没有怪兽的条件。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 设置发动时的费用，检查是否在本回合中已经进行过非超量的特殊召唤。
function c21715135.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否在本回合中已经进行过非超量的特殊召唤。
	if chk==0 then return Duel.GetCustomActivityCount(21715135,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建一个影响全场的永续效果，禁止玩家进行特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(c21715135.splimit)
	-- 将效果e1注册给玩家tp，使其生效。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数，排除超量召唤和当前效果自身。
function c21715135.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return sumtype~=SUMMON_TYPE_XYZ and e:GetLabelObject()~=se
end
-- 过滤函数，筛选「我我我」卡组中的怪兽，满足特殊召唤条件。
function c21715135.filter(c,e,tp)
	return c:IsSetCard(0x54) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置连锁处理的目标，检查是否满足特殊召唤的条件。
function c21715135.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的「我我我」怪兽。
		and Duel.IsExistingMatchingCard(c21715135.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 发动效果的处理函数，执行特殊召唤操作。
function c21715135.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有空位，若无则不执行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的「我我我」怪兽。
	local g=Duel.SelectMatchingCard(tp,c21715135.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
