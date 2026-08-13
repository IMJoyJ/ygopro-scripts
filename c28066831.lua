--ガスタ・サンボルト
-- 效果：
-- 这张卡被战斗破坏送去墓地的场合，那次战斗阶段结束时可以把自己墓地存在的1只名字带有「薰风」的怪兽从游戏中除外，从自己卡组把1只守备力1500以下的念动力族·风属性怪兽特殊召唤。
function c28066831.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地的场合，那次战斗阶段结束时可以把自己墓地存在的1只名字带有「薰风」的怪兽从游戏中除外，从自己卡组把1只守备力1500以下的念动力族·风属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetOperation(c28066831.flagop)
	c:RegisterEffect(e1)
end
-- 当此卡被战斗破坏并送入墓地后，检查其是否确实位于墓地且破坏原因为战斗破坏；若满足，则在此卡于墓地期间注册一个可在战斗阶段结束时发动的选发效果，用于后续除外「薰风」怪兽并从卡组特殊召唤。
function c28066831.flagop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_GRAVE) or bit.band(c:GetReason(),REASON_BATTLE)==0 then return end
	-- 那次战斗阶段结束时可以把自己墓地存在的1只名字带有「薰风」的怪兽从游戏中除外，从自己卡组把1只守备力1500以下的念动力族·风属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28066831,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetCost(c28066831.cost)
	e1:SetTarget(c28066831.target)
	e1:SetOperation(c28066831.operation)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 判断墓地中的卡是否满足作为发动代价的条件：卡名带有「薰风」、是怪兽、且可以作为代价除外。
function c28066831.costfilter(c)
	return c:IsSetCard(0x10) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 代价处理：先确认自己墓地存在至少1只可除外的「薰风」怪兽；然后提示玩家选择1只，将其表侧除外作为发动代价。
function c28066831.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：若自己墓地不存在满足条件的「薰风」怪兽，则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c28066831.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出提示，要求玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张满足costfilter条件的卡。
	local g=Duel.SelectMatchingCard(tp,c28066831.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡以表侧表示除外，作为效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 判断卡组中的怪兽是否满足特殊召唤条件：守备力1500以下、念动力族、风属性，且可以被当前效果正常特殊召唤。
function c28066831.filter(c,e,tp)
	return c:IsDefenseBelow(1500) and c:IsRace(RACE_PSYCHO) and c:IsAttribute(ATTRIBUTE_WIND)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的检查：自己主要怪兽区有空位，且卡组中存在至少1只满足filter的怪兽；满足后将本次操作登记为从卡组特殊召唤。
function c28066831.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否仍有可用空位，作为可发动条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查卡组中是否存在至少1只满足filter条件的怪兽，确保有可特殊召唤的对象。
		and Duel.IsExistingMatchingCard(c28066831.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，标记本次效果包含特殊召唤，预定从卡组特殊召唤1只怪兽（对象在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：确认主要怪兽区仍有空位后，提示玩家从卡组选择1只符合条件的怪兽，并正面表示特殊召唤到自己场上。
function c28066831.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主要怪兽区有空位，若没有空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组选择1只满足filter条件的怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c28066831.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以正面表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
