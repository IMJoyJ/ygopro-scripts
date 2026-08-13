--SRバンブー・ホース
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时才能发动。从手卡把1只4星以下的「疾行机人」怪兽特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从卡组把1只风属性怪兽送去墓地。这个效果在这张卡送去墓地的回合不能发动。
function c17328157.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从手卡把1只4星以下的「疾行机人」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17328157,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c17328157.sptg)
	e1:SetOperation(c17328157.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：把墓地的这张卡除外才能发动。从卡组把1只风属性怪兽送去墓地。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17328157,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,17328157)
	-- 设置②效果的发动条件：这张卡送去墓地的回合不能发动（通过aux.exccon判断当前回合是否为该卡被送去墓地的回合）。
	e2:SetCondition(aux.exccon)
	-- 设置②效果的发动代价：把墓地的这张卡除外（aux.bfgcost将这张卡从墓地除外作为cost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c17328157.tgtg)
	e2:SetOperation(c17328157.tgop)
	c:RegisterEffect(e2)
end
-- 定义①效果要特殊召唤的卡的筛选条件：等级4以下、属于「疾行机人」系列、且可以被当前效果特殊召唤。
function c17328157.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x2016) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件与目标设定：检查自己场上是否有空位、手牌是否存在符合条件的「疾行机人」怪兽，满足才可发动。
function c17328157.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用空格，以确保特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1张满足spfilter（4星以下疾行机人且可特殊召唤）的怪兽，以此判断①效果能否发动。
		and Duel.IsExistingMatchingCard(c17328157.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记本次效果的操作信息：将进行1只怪兽的特殊召唤，来源为手牌，用于让其他卡正确响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理时的操作：若仍有怪兽区空格，则从手卡选择1只符合条件的「疾行机人」怪兽，以表侧表示特殊召唤。
function c17328157.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己主要怪兽区仍有可用空格，若没有则中止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选出1张满足spfilter的「疾行机人」怪兽。
	local g=Duel.SelectMatchingCard(tp,c17328157.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果要送去墓地的卡的筛选条件：风属性、怪兽类型、且可以送去墓地。
function c17328157.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ②效果的发动条件与目标设定：检查卡组中是否存在符合条件的风属性怪兽，并登记送去墓地的操作信息。
function c17328157.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足tgfilter的风属性怪兽，有才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c17328157.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次效果的操作信息：从卡组将1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理时的操作：从卡组选择1张符合条件的风属性怪兽送去墓地。
function c17328157.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选出1张满足tgfilter的卡。
	local g=Duel.SelectMatchingCard(tp,c17328157.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因（REASON_EFFECT）送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
