--魔轟神オルトロ
-- 效果：
-- 把1张手卡送去墓地发动。从手卡把1只3星的名字带有「魔轰神」的怪兽特殊召唤。这个效果1回合只能使用1次。
function c49633574.initial_effect(c)
	-- 效果原文内容：把1张手卡送去墓地发动。从手卡把1只3星的名字带有「魔轰神」的怪兽特殊召唤。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49633574,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c49633574.cost)
	e1:SetTarget(c49633574.tg)
	e1:SetOperation(c49633574.op)
	c:RegisterEffect(e1)
end
-- 检索满足条件的手卡并确保能特殊召唤符合条件的怪兽
function c49633574.cfilter(c,e,tp)
	-- 检查手卡中是否有可以作为代价送去墓地且能特殊召唤符合条件怪兽的卡
	return c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(c49633574.spfilter,tp,LOCATION_HAND,0,1,c,e,tp)
end
-- 过滤出名字带有「魔轰神」且等级为3的怪兽，确保其可被特殊召唤
function c49633574.spfilter(c,e,tp)
	return c:IsSetCard(0x35) and c:IsLevel(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：选择1张手卡送去墓地作为代价
function c49633574.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：手卡中存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c49633574.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的手卡并将其加入处理组
	local g=Duel.SelectMatchingCard(tp,c49633574.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选中的卡送去墓地作为效果的代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果作用：设置特殊召唤怪兽的目标信息
function c49633574.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：玩家场上存在可特殊召唤怪兽的位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果作用：从手卡特殊召唤符合条件的怪兽
function c49633574.op(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足发动条件：玩家场上存在可特殊召唤怪兽的位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的手卡并将其加入处理组
	local g=Duel.SelectMatchingCard(tp,c49633574.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
