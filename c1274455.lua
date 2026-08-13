--Kozmo－シーミウズ
-- 效果：
-- 「星际仙踪-飞猴队」的①的效果1回合只能使用1次。
-- ①：把场上的这张卡除外才能发动。从手卡把1只4星以上的「星际仙踪」怪兽特殊召唤。这个效果在对方回合也能发动。
-- ②：1回合1次，支付1000基本分，以自己墓地1只念动力族「星际仙踪」怪兽为对象才能发动。那只怪兽特殊召唤。
function c1274455.initial_effect(c)
	-- 「星际仙踪-飞猴队」的①的效果1回合只能使用1次。①：把场上的这张卡除外才能发动。从手卡把1只4星以上的「星际仙踪」怪兽特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1274455,0))  --"从手卡把「星际仙踪」怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,1274455)
	e1:SetCost(c1274455.spcost)
	e1:SetTarget(c1274455.sptg)
	e1:SetOperation(c1274455.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，支付1000基本分，以自己墓地1只念动力族「星际仙踪」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1274455,1))  --"从墓地把「星际仙踪」怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c1274455.cost)
	e2:SetTarget(c1274455.target)
	e2:SetOperation(c1274455.operation)
	c:RegisterEffect(e2)
end
-- 定义效果①的代价函数：在cost检查时验证这张卡能否作为代价除外，可支付时表侧除外自身。
function c1274455.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 支付代价：将效果发动者（这张卡）以表侧表示除外，除外原因为COST。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 定义效果①的特殊召唤筛选条件：手牌中满足「星际仙踪」字段、等级4星以上、并能被特殊召唤的怪兽。
function c1274455.spfilter(c,e,tp)
	return c:IsSetCard(0xd2) and c:IsLevelAbove(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果①的发动目标条件：自场上有空位（此处用>-1，因代价会除外自身腾出格子）且手牌存在满足筛选条件的怪兽。
function c1274455.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法检查时，要求自己主要怪兽区可用格数>-1（即允许当前0格，因为自身除外后可能腾出空格）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 同时要求手牌存在至少1只满足spfilter的「星际仙踪」怪兽可作为特殊召唤对象。
		and Duel.IsExistingMatchingCard(c1274455.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果处理包含特殊召唤，预计从手牌特殊召唤1只怪兽（对象在处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 定义效果①的解决处理：若场上没有可用的怪兽区则终止；否则从手牌选择1只满足条件的怪兽表侧特殊召唤。
function c1274455.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认怪兽区有空位，若无空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 发出选择提示，提示玩家从手牌选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1张满足spfilter的怪兽并返回所选卡组。
	local g=Duel.SelectMatchingCard(tp,c1274455.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义效果②的代价函数：检查能否支付1000基本分，并实际支付。
function c1274455.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查时，返回是否可以支付1000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际支付1000基本分作为发动代价。
	Duel.PayLPCost(tp,1000)
end
-- 定义效果②的取对象筛选条件：自己墓地中满足「星际仙踪」字段、念动力族、并且能特殊召唤的怪兽。
function c1274455.filter(c,e,tp)
	return c:IsSetCard(0xd2) and c:IsRace(RACE_PSYCHO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果②的发动条件与取对象过程：选择自己墓地1只符合条件的「星际仙踪」念动力族怪兽为对象；检查场上是否有空位及墓地是否有对象。
function c1274455.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c1274455.filter(chkc,e,tp) end
	-- 效果发动合法检查时，要求场上存在至少1个可用的主要怪兽区，因为效果处理时要特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时要求自己墓地存在至少1只可成为对象且满足filter的怪兽。
		and Duel.IsExistingTarget(c1274455.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 发出选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足filter的怪兽作为效果对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c1274455.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果将特殊召唤所选择的对象卡（对象已确定，targets为g）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义效果②的解决处理：取得对象怪兽，若仍与效果关联则将其表侧特殊召唤。
function c1274455.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的第一张对象卡（即墓地的对象怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
