--混沌の召喚神
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡解放才能发动。「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的其中1只从手卡无视召唤条件特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从卡组把1张「失乐园」加入手卡。
function c27439792.initial_effect(c)
	-- 记录该卡牌效果中涉及的其他卡名代码，用于后续效果识别和匹配
	aux.AddCodeList(c,6007213,32491822,69890967,13301895)
	-- ①：把这张卡解放才能发动。「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的其中1只从手卡无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27439792,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,27439792)
	e1:SetCost(c27439792.spcost)
	e1:SetTarget(c27439792.sptg)
	e1:SetOperation(c27439792.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把1张「失乐园」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27439792,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,27439793)
	-- 设置效果发动时的代价为将此卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c27439792.thtg)
	e2:SetOperation(c27439792.thop)
	c:RegisterEffect(e2)
end
-- 设置效果发动时的代价为将此卡解放，并检查是否满足解放条件
function c27439792.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	local c=e:GetHandler()
	-- 检查是否满足解放条件，即此卡可被解放且场上存在可用怪兽区
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0 end
	-- 执行将此卡解放的操作
	Duel.Release(c,REASON_COST)
end
-- 定义特殊召唤目标卡的过滤条件，即为指定的三只神皇卡且可特殊召唤
function c27439792.spfilter(c,e,tp)
	return c:IsCode(6007213,32491822,69890967) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 设置效果的发动条件，检查是否满足特殊召唤的条件
function c27439792.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤的条件，即当前怪兽区有空位或标签为100
	local res=e:GetLabel()==100 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then
		e:SetLabel(0)
		-- 检查手牌中是否存在满足条件的特殊召唤目标卡
		return res and Duel.IsExistingMatchingCard(c27439792.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	-- 设置效果发动后将要处理的卡组信息，即特殊召唤一张手牌中的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行特殊召唤操作，将选择的卡特殊召唤到场上
function c27439792.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有可用怪兽区，若无则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择一张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c27439792.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
-- 定义检索目标卡的过滤条件，即为「失乐园」且可加入手牌
function c27439792.thfilter(c)
	return c:IsCode(13301895) and c:IsAbleToHand()
end
-- 设置效果的发动条件，检查是否满足检索的条件
function c27439792.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的检索目标卡
	if chk==0 then return Duel.IsExistingMatchingCard(c27439792.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果发动后将要处理的卡组信息，即从卡组检索一张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索操作，将选中的卡加入手牌并确认
function c27439792.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c27439792.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选卡的卡面信息
		Duel.ConfirmCards(1-tp,g)
	end
end
