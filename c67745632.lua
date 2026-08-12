--超越竜ギガントザウラー
-- 效果：
-- 恐龙族怪兽＋通常怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合，以自己墓地1只恐龙族怪兽为对象才能发动。那只怪兽加入手卡。这张卡从墓地特殊召唤的场合，可以再选自己的手卡·场上1张卡和对方场上1张卡破坏。
-- ②：这张卡被破坏的场合才能发动。从自己墓地选1只通常怪兽回到卡组。那之后，可以把这张卡特殊召唤。
function c67745632.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为1只恐龙族怪兽和1只通常怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_DINOSAUR),aux.FilterBoolFunction(Card.IsFusionType,TYPE_NORMAL),true)
	-- ①：这张卡特殊召唤成功的场合，以自己墓地1只恐龙族怪兽为对象才能发动。那只怪兽加入手卡。这张卡从墓地特殊召唤的场合，可以再选自己的手卡·场上1张卡和对方场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67745632,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,67745632)
	e1:SetTarget(c67745632.thtg)
	e1:SetOperation(c67745632.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡被破坏的场合才能发动。从自己墓地选1只通常怪兽回到卡组。那之后，可以把这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67745632,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,67745633)
	e2:SetTarget(c67745632.tdtg)
	e2:SetOperation(c67745632.tdop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地的恐龙族怪兽且能加入手卡
function c67745632.thfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToHand()
end
-- ①效果的发动准备（检查墓地是否有恐龙族怪兽、选择对象、判断是否从墓地特殊召唤并设置对应的操作信息）
function c67745632.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c67745632.thfilter(chkc) end
	-- 检查自己墓地是否存在至少1只满足条件的恐龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(c67745632.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只恐龙族怪兽作为效果的对象
	local sg=Duel.SelectTarget(tp,c67745632.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if e:GetHandler():IsPreviousLocation(LOCATION_GRAVE) then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
		e:SetLabel(1)
	else
		e:SetCategory(CATEGORY_TOHAND)
		e:SetLabel(0)
	end
	-- 设置当前连锁的操作信息为将选中的对象加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
end
-- ①效果的处理（将对象怪兽加入手牌，若此卡是从墓地特殊召唤的，则可以再选择自己手牌·场上1张卡和对方场上1张卡破坏）
function c67745632.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍存在且成功加入手牌
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		if e:GetLabel()>0
			-- 检查自己手牌或场上是否存在至少1张卡
			and Duel.GetFieldGroupCount(tp,LOCATION_HAND+LOCATION_ONFIELD,0)>0
			-- 检查对方场上是否存在至少1张卡
			and Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)>0
			-- 询问玩家是否选择破坏双方场上/手牌的卡
			and Duel.SelectYesNo(tp,aux.Stringid(67745632,2)) then  --"是否选双方的卡破坏？"
			-- 中断当前效果，使后续的破坏处理与加入手牌不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 让玩家选择自己手牌或场上的1张卡
			local g1=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
			-- 让玩家选择对方场上的1张卡
			local g2=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
			g1:Merge(g2)
			-- 显式展示被选择破坏的卡片
			Duel.HintSelection(g1)
			-- 破坏选中的双方卡片
			Duel.Destroy(g1,REASON_EFFECT)
		end
	end
end
-- 过滤自己墓地能回到卡组的通常怪兽
function c67745632.tdfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToDeck()
end
-- ②效果的发动准备（检查墓地是否有通常怪兽、设置操作信息）
function c67745632.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只通常怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c67745632.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置当前连锁的操作信息为将墓地的卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	if e:GetActivateLocation()==LOCATION_GRAVE then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	else
		e:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	end
end
-- ②效果的处理（将自己墓地1只通常怪兽回到卡组，那之后可以把这张卡特殊召唤）
function c67745632.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1只通常怪兽
	local g=Duel.SelectMatchingCard(tp,c67745632.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		local c=e:GetHandler()
		-- 若成功将选中的通常怪兽送回卡组并洗牌
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
			and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)>0
			-- 检查此卡是否仍与效果相关，且自己场上有可用的怪兽区域
			and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 询问玩家是否将此卡特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(67745632,3)) then  --"是否把这张卡特殊召唤？"
			-- 中断当前效果，使后续的特殊召唤与回到卡组不视为同时进行
			Duel.BreakEffect()
			-- 将此卡以表侧表示特殊召唤
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
