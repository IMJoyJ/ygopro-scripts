--表裏一体
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只光·暗属性怪兽解放才能发动。和那只怪兽是原本的种族·等级相同而原本属性不同的1只光·暗属性怪兽从手卡·额外卡组特殊召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地的光·暗属性怪兽各1只为对象才能发动。那2只怪兽回到卡组洗切。那之后，自己从卡组抽1张。
function c39973386.initial_effect(c)
	-- ①：把自己场上1只光·暗属性怪兽解放才能发动。和那只怪兽是原本的种族·等级相同而原本属性不同的1只光·暗属性怪兽从手卡·额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,39973386)
	e1:SetTarget(c39973386.target)
	e1:SetOperation(c39973386.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地的光·暗属性怪兽各1只为对象才能发动。那2只怪兽回到卡组洗切。那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,39973387)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c39973386.tdtg)
	e2:SetOperation(c39973386.tdop)
	c:RegisterEffect(e2)
end
-- 检查场上是否存在满足条件的光·暗属性怪兽（需为己方控制或表侧表示），且该怪兽原本等级大于0，且存在满足条件的可特殊召唤怪兽
function c39973386.costfilter(c,e,tp)
	return (c:IsControler(tp) or c:IsFaceup())
		and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:GetOriginalLevel()>0
		-- 检查是否存在满足条件的可特殊召唤怪兽
		and Duel.IsExistingMatchingCard(c39973386.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,c,e,tp)
end
-- 检查特殊召唤的怪兽是否满足种族、等级、属性要求，且能特殊召唤
function c39973386.spfilter(c,tc,e,tp)
	if c:GetOriginalAttribute()==tc:GetOriginalAttribute() then return end
	-- 检查手卡中的怪兽是否能特殊召唤到己方场上
	local b1=c:IsLocation(LOCATION_HAND) and Duel.GetMZoneCount(tp,tc)>0
	-- 检查额外卡组中的怪兽是否能特殊召唤到己方场上
	local b2=c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		and c:GetOriginalRace()==tc:GetOriginalRace()
		and c:GetOriginalLevel()==tc:GetOriginalLevel()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (b1 or b2)
end
-- 检查是否满足发动条件
function c39973386.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查场上是否存在满足条件的光·暗属性怪兽
		and Duel.CheckReleaseGroup(tp,c39973386.costfilter,1,nil,e,tp) end
	-- 选择场上满足条件的光·暗属性怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c39973386.costfilter,1,1,nil,e,tp)
	-- 将选中的怪兽解放作为cost
	Duel.Release(g,REASON_COST)
	-- 设置当前效果的目标为被解放的怪兽
	Duel.SetTargetCard(g)
	-- 设置效果处理信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA)
end
-- 处理特殊召唤效果
function c39973386.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,c39973386.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,tc,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检查墓地中的怪兽是否满足条件
function c39973386.tdfilter(c,e)
	return c:IsCanBeEffectTarget(e) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToDeck()
end
-- 处理墓地效果
function c39973386.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39973386.tdfilter(chkc) end
	-- 获取满足条件的墓地怪兽
	local g=Duel.GetMatchingGroup(c39973386.tdfilter,tp,LOCATION_GRAVE,0,nil,e)
	-- 检查是否存在满足条件的2只怪兽且属性不同
	if chk==0 then return g:CheckSubGroup(aux.dabcheck,2,2) and Duel.IsPlayerCanDraw(tp,1) end
	-- 提示玩家选择要返回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从满足条件的怪兽中选择2只属性不同的怪兽
	local sg=g:SelectSubGroup(tp,aux.dabcheck,false,2,2)
	-- 设置当前效果的目标为选中的怪兽
	Duel.SetTargetCard(sg)
	-- 设置效果处理信息为返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,2,0,0)
	-- 设置效果处理信息为抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理墓地效果的后续处理
function c39973386.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=2 then return end
	-- 将目标怪兽送回卡组
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取实际操作的卡片组
	local g=Duel.GetOperatedGroup()
	-- 若送回卡组的怪兽中有在卡组的，则洗切卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==2 then
		-- 中断当前效果
		Duel.BreakEffect()
		-- 从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
