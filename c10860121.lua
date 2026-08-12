--武神器－イオツミ
-- 效果：
-- 「武神器-五百箇」的效果1回合只能使用1次。
-- ①：自己场上的兽战士族「武神」怪兽被战斗破坏送去墓地时，把这张卡从手卡送去墓地才能发动。从卡组把1只「武神」怪兽特殊召唤。
function c10860121.initial_effect(c)
	-- 创建效果，设置为场上的诱发选发效果，可在伤害步骤发动，只能从手卡发动，发动时需支付送去墓地的代价，效果条件为己方场上的兽战士族武神怪兽被战斗破坏送入墓地时，效果描述为特殊召唤，效果限制为每回合只能发动一次
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10860121,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,10860121)
	e1:SetCondition(c10860121.condition)
	e1:SetCost(c10860121.cost)
	e1:SetTarget(c10860121.target)
	e1:SetOperation(c10860121.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断被送入墓地的卡是否为己方场上被战斗破坏的兽战士族武神怪兽
function c10860121.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsSetCard(0x88) and c:IsRace(RACE_BEASTWARRIOR) and c:IsReason(REASON_BATTLE)
end
-- 效果条件函数，判断是否有满足条件的卡被送入墓地
function c10860121.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c10860121.cfilter,1,nil,tp)
end
-- 效果代价函数，判断是否能将此卡送去墓地作为代价
function c10860121.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送去墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于筛选可以特殊召唤的武神怪兽
function c10860121.filter(c,e,tp)
	return c:IsSetCard(0x88) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标函数，判断是否满足发动条件并设置操作信息
function c10860121.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，判断己方场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足发动条件，判断卡组中是否存在满足条件的武神怪兽
		and Duel.IsExistingMatchingCard(c10860121.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将从卡组特殊召唤一只武神怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 效果处理函数，执行特殊召唤操作
function c10860121.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有空位，若无则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从卡组选择一只满足条件的武神怪兽
	local g=Duel.SelectMatchingCard(tp,c10860121.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
