--武神器－イオツミ
-- 效果：
-- 「武神器-五百箇」的效果1回合只能使用1次。
-- ①：自己场上的兽战士族「武神」怪兽被战斗破坏送去墓地时，把这张卡从手卡送去墓地才能发动。从卡组把1只「武神」怪兽特殊召唤。
function c10860121.initial_effect(c)
	-- 「武神器-五百箇」的效果1回合只能使用1次。①：自己场上的兽战士族「武神」怪兽被战斗破坏送去墓地时，把这张卡从手卡送去墓地才能发动。从卡组把1只「武神」怪兽特殊召唤。
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
-- 判定送去墓地的卡是否满足：在我方场上主要怪兽区被战斗破坏送去墓地，且是兽战士族的「武神」怪兽。
function c10860121.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsSetCard(0x88) and c:IsRace(RACE_BEASTWARRIOR) and c:IsReason(REASON_BATTLE)
end
-- 检查本次送去墓地的怪兽集合中是否存在至少1只满足上述条件的我方兽战士族「武神」怪兽，以此判断触发条件是否成立。
function c10860121.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c10860121.cfilter,1,nil,tp)
end
-- 发动代价的检查与执行：确认这张卡可以从手卡作为代价送去墓地，然后实际将其送去墓地作为发动代价。
function c10860121.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 实际将效果发动者（这张卡）从手卡送去墓地，作为效果的发动代价（REASON_COST）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选卡组中满足条件的「武神」怪兽：属于「武神」系列且可以被当前效果特殊召唤（不跳过召唤条件与苏生限制的检查）。
function c10860121.filter(c,e,tp)
	return c:IsSetCard(0x88) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动前合法性检查：我方主要怪兽区有空位，且卡组中存在符合条件的「武神」怪兽，并设置操作信息为特殊召唤。
function c10860121.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否还有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查我方卡组中是否存在至少1只符合特殊召唤条件的「武神」怪兽。
		and Duel.IsExistingMatchingCard(c10860121.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次连锁的处理信息：预计从卡组把1只怪兽特殊召唤，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 效果处理：若主要怪兽区仍有空位，则提示玩家选择并特殊召唤1只符合条件的「武神」怪兽。
function c10860121.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时再次确认我方主要怪兽区仍有空格，若没有则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家发出选择特殊召唤对象的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足过滤条件的「武神」怪兽。
	local g=Duel.SelectMatchingCard(tp,c10860121.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到我方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
