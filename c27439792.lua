--混沌の召喚神
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡解放才能发动。「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的其中1只从手卡无视召唤条件特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从卡组把1张「失乐园」加入手卡。
function c27439792.initial_effect(c)
	-- 在卡片上登记本卡记载的卡名：神炎皇 乌利亚、降雷皇 哈蒙、幻魔皇 拉比艾尔、失乐园，用于规则判定。
	aux.AddCodeList(c,6007213,32491822,69890967,13301895)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把这张卡解放才能发动。「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的其中1只从手卡无视召唤条件特殊召唤。
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
	-- 这个卡名的①②的效果1回合各能使用1次。②：把墓地的这张卡除外才能发动。从卡组把1张「失乐园」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27439792,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,27439793)
	-- 设置②效果的发动代价为：把墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c27439792.thtg)
	e2:SetOperation(c27439792.thop)
	c:RegisterEffect(e2)
end
-- 定义①效果的代价函数：发动时解放此卡，并确保解放后仍有可用怪兽区域；实际执行解放作为代价。
function c27439792.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	local c=e:GetHandler()
	-- 代价检测：此卡可解放，且解放后自己场上有可用的怪兽区域。
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0 end
	-- 以代价形式解放此卡。
	Duel.Release(c,REASON_COST)
end
-- 定义特殊召唤筛选条件：对象必须是三幻魔之一（乌利亚/哈蒙/拉比艾尔），且可以被无视召唤条件地特殊召唤。
function c27439792.spfilter(c,e,tp)
	return c:IsCode(6007213,32491822,69890967) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 定义①效果发动条件：确认有怪兽区域空位且手牌存在符合条件的三幻魔，并设置特殊召唤的操作信息。
function c27439792.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有可用怪兽区域：若代价阶段已标记腾出空位，或当前仍有空位，则满足。
	local res=e:GetLabel()==100 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then
		e:SetLabel(0)
		-- 确认手牌中存在能够被特殊召唤的三幻魔。
		return res and Duel.IsExistingMatchingCard(c27439792.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	-- 设置连锁信息：本效果将把手牌中的1只怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 定义①效果处理：若仍有空位，从手牌选择1只三幻魔，无视召唤条件表侧表示特殊召唤。
function c27439792.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前再次确认怪兽区域有空位，否则中止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选出1张符合条件的三幻魔。
	local g=Duel.SelectMatchingCard(tp,c27439792.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽无视召唤条件以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
-- 定义检索筛选条件：卡名为「失乐园」且能够加入手牌。
function c27439792.thfilter(c)
	return c:IsCode(13301895) and c:IsAbleToHand()
end
-- 定义②效果发动条件：卡组存在可加入手牌的「失乐园」，并设置检索到手的操作信息。
function c27439792.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认卡组中存在符合条件的「失乐园」。
	if chk==0 then return Duel.IsExistingMatchingCard(c27439792.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息：本效果将从卡组把卡片加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义②效果处理：从卡组选择1张「失乐园」加入手牌，并展示给对方确认。
function c27439792.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张「失乐园」。
	local g=Duel.SelectMatchingCard(tp,c27439792.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者手牌（因效果而移动）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示刚加入手牌的卡，以确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
