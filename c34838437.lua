--アクセル・ライト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能通常召唤。
-- ①：自己场上没有怪兽存在的场合才能发动。从卡组把4星以下的1只「光子」怪兽或者「银河」怪兽特殊召唤。
function c34838437.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能通常召唤。①：自己场上没有怪兽存在的场合才能发动。从卡组把4星以下的1只「光子」怪兽或者「银河」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,34838437+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c34838437.condition)
	e1:SetCost(c34838437.cost)
	e1:SetTarget(c34838437.target)
	e1:SetOperation(c34838437.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件：该函数在效果发动时进行判定，后续具体判定为“自己场上没有怪兽”时才允许发动。
function c34838437.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上主要怪兽区的怪兽数量是否为0，以此判断自己场上是否没有怪兽；满足则条件成立。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 定义效果发动代价（cost）：一方面确认本回合自己尚未进行过通常召唤，另一方面给己方附加本回合不能召唤/覆盖怪兽的誓约效果。
function c34838437.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段（chk==0）确认本回合自己尚未进行过通常召唤；因为发动后会有不能通常召唤的限制，所以发动前必须没有通常召唤过。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0 end
	-- 这张卡发动的回合，自己不能通常召唤。从卡组把4星以下的1只「光子」怪兽或者「银河」怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将禁止通常召唤的誓约效果（EFFECT_CANNOT_SUMMON）注册给当前玩家，使该回合内自己不能进行通常召唤。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	-- 将禁止覆盖怪兽的誓约效果（EFFECT_CANNOT_MSET）注册给当前玩家，使该回合内自己也不能以里侧表示通常召唤（覆盖怪兽）。
	Duel.RegisterEffect(e2,tp)
end
-- 定义特殊召唤的过滤函数：选择卡组中等级4以下、属于「光子」或「银河」字段、且能够被特殊召唤的怪兽。
function c34838437.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x55,0x7b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动时的目标检查与选择：确认自己场上有空位且卡组中存在符合条件的怪兽，并设置效果处理信息。
function c34838437.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己场上主要怪兽区是否有空位，没有空位则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动时检查卡组中是否存在至少1只满足特殊召唤条件的怪兽。
		and Duel.IsExistingMatchingCard(c34838437.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果处理将进行从卡组把1只怪兽特殊召唤的动作（供诱发效果等发动检测使用）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果处理时的操作：从卡组选择符合条件的1只怪兽特殊召唤。
function c34838437.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上仍有空位，若无空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的选择提示，并要求玩家选择卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1张满足spfilter条件的怪兽（必须选择1张）。
	local g=Duel.SelectMatchingCard(tp,c34838437.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
