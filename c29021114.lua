--シルバー・ガジェット
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡召唤·特殊召唤成功时才能发动。从手卡把1只机械族·4星怪兽特殊召唤。
-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把「银色零件」以外的1只4星「零件」怪兽特殊召唤。
function c29021114.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时才能发动。从手卡把1只机械族·4星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29021114,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,29021114)
	e1:SetTarget(c29021114.sptg1)
	e1:SetOperation(c29021114.spop1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把「银色零件」以外的1只4星「零件」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29021114,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,29021114)
	e3:SetCondition(c29021114.spcon2)
	e3:SetTarget(c29021114.sptg2)
	e3:SetOperation(c29021114.spop2)
	c:RegisterEffect(e3)
end
-- 定义①效果的从手卡特殊召唤的过滤条件：机械族、4星且可以被特殊召唤的怪兽。
function c29021114.spfilter1(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动时机判定函数：确认主怪兽区有空位且手牌存在符合spfilter1条件的机械族·4星怪兽，并设置特殊召唤操作信息。
function c29021114.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）检查主要怪兽区是否有空位，以保证有特殊召唤的格子。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手牌是否存在至少1只满足spfilter1（机械族·4星且可特殊召唤）的怪兽。
		and Duel.IsExistingMatchingCard(c29021114.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记本次效果处理涉及从手卡特殊召唤1只机械族·4星怪兽（数量1，位置为手牌）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果的处理：若仍有空位，从手牌选择1只满足条件的机械族·4星怪兽，以表侧表示特殊召唤到自己的主要怪兽区。
function c29021114.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主要怪兽区有空位，没有空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向当前玩家显示“请选择要特殊召唤的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1只满足spfilter1条件的机械族·4星怪兽（必须选择1张）。
	local g=Duel.SelectMatchingCard(tp,c29021114.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的主要怪兽区，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：这张卡被战斗或效果破坏时才能发动，即破坏原因包含战斗或效果中的任意一种。
function c29021114.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 定义②效果的从卡组特殊召唤的过滤条件：4星『零件』怪兽、卡名不是『银色零件』本身、且可以被特殊召唤。
function c29021114.spfilter2(c,e,tp)
	return c:IsSetCard(0x51) and c:IsLevel(4) and not c:IsCode(29021114) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件判定：主要怪兽区有空位且卡组存在至少1只符合spfilter2条件的『零件』怪兽，并设置从卡组特殊召唤1只怪兽的操作信息。
function c29021114.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）检查主要怪兽区是否有空位，以保证特殊召唤的格子。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查卡组是否存在至少1只满足spfilter2条件的4星『零件』怪兽（且不是『银色零件』）。
		and Duel.IsExistingMatchingCard(c29021114.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本次效果处理涉及从卡组特殊召唤1只4星『零件』怪兽（数量1，位置为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：若仍有空位，从卡组选择1只满足条件的『零件』怪兽，以表侧表示特殊召唤到自己的主要怪兽区。
function c29021114.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主要怪兽区有空位，没有空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向当前玩家显示“请选择要特殊召唤的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足spfilter2条件的4星『零件』怪兽（必须选择1张）。
	local g=Duel.SelectMatchingCard(tp,c29021114.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的主要怪兽区，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
