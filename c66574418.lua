--伝説の黒石
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把这张卡解放才能发动。从卡组把1只7星以下的「真红眼」怪兽特殊召唤。
-- ②：这张卡在墓地存在的场合，以自己墓地1只7星以下的「真红眼」怪兽为对象才能发动。那只怪兽回到卡组，这张卡加入手卡。
function c66574418.initial_effect(c)
	-- ①：把这张卡解放才能发动。从卡组把1只7星以下的「真红眼」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,66574418)
	e1:SetCost(c66574418.spcost)
	e1:SetTarget(c66574418.sptg)
	e1:SetOperation(c66574418.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己墓地1只7星以下的「真红眼」怪兽为对象才能发动。那只怪兽回到卡组，这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,66574418)
	e2:SetTarget(c66574418.tdtg)
	e2:SetOperation(c66574418.tdop)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价与效果注册：检查自身是否可以解放，并将其解放作为发动代价
function c66574418.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数：检索自己卡组中7星以下的「真红眼」怪兽，且该怪兽可以被特殊召唤
function c66574418.spfilter(c,e,tp)
	return c:IsSetCard(0x3b) and c:IsLevelBelow(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备：检查怪兽区域空位以及卡组中是否存在符合条件的怪兽，并设置特殊召唤的操作信息
function c66574418.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域空位（因为自身作为代价解放，所以空位限制可以比平时多1个，即>-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查卡组中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c66574418.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，预计从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的效果处理：从卡组选择1只7星以下的「真红眼」怪兽在场上特殊召唤
function c66574418.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c66574418.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：检索自己墓地中7星以下的「真红眼」怪兽，且该怪兽可以回到卡组
function c66574418.tdfilter(c)
	return c:IsSetCard(0x3b) and c:IsLevelBelow(7) and c:IsAbleToDeck()
end
-- ②效果的发动准备：检查自身是否能加入手卡，并选择墓地中1只符合条件的怪兽作为对象，设置回到卡组和加入手卡的操作信息
function c66574418.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c66574418.tdfilter(chkc) end
	if chk==0 then return e:GetHandler():IsAbleToHand()
		-- 检查自己墓地中是否存在至少1只满足过滤条件的怪兽作为效果对象
		and Duel.IsExistingTarget(c66574418.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择墓地中1只满足过滤条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c66574418.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置回到卡组的操作信息，操作对象为选择的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置加入手卡的操作信息，操作对象为墓地中的这张卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果的效果处理：使作为对象的墓地怪兽回到卡组，若成功则将墓地的这张卡加入手卡
function c66574418.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 若对象怪兽仍与效果相关，则将其送回卡组并洗牌，并检查是否成功送回
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) and c:IsRelateToEffect(e) then
		-- 将墓地的这张卡加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
