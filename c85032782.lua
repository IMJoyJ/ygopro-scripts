--時花の賢者－フルール・ド・サージュ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只怪兽和场上1张卡为对象才能发动。这张卡从手卡特殊召唤，作为对象的卡破坏。
-- ②：这张卡从场上送去墓地的场合，以这张卡以外的自己墓地1只怪兽为对象才能发动。那只怪兽回到卡组。那之后，从自己的卡组·墓地选1只植物族·1星怪兽加入手卡。
function c85032782.initial_effect(c)
	-- ①：以自己场上1只怪兽和场上1张卡为对象才能发动。这张卡从手卡特殊召唤，作为对象的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85032782,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,85032782)
	e1:SetTarget(c85032782.destg)
	e1:SetOperation(c85032782.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合，以这张卡以外的自己墓地1只怪兽为对象才能发动。那只怪兽回到卡组。那之后，从自己的卡组·墓地选1只植物族·1星怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85032782,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,85032783)
	e2:SetCondition(c85032782.thcon)
	e2:SetTarget(c85032782.thtg)
	e2:SetOperation(c85032782.thop)
	c:RegisterEffect(e2)
end
-- 定义过滤条件：场上存在除自身以外的卡片作为第二个对象
function c85032782.tgfilter(c,tp)
	-- 检查场上是否存在除自身以外的卡片
	return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- ①号效果的发动准备与对象选择
function c85032782.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在可以作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c85032782.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		-- 检查自己场上是否有空余的怪兽区域用于特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只怪兽作为第一个对象
	local g1=Duel.SelectTarget(tp,c85032782.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为第二个对象
	local g2=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,g1)
	g1:Merge(g2)
	-- 设置破坏操作的信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
	-- 设置特殊召唤操作的信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①号效果的处理
function c85032782.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取仍与效果关联的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 若这张卡特殊召唤成功，且存在有效的对象卡
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and g:GetCount()>0 then
		-- 破坏作为对象的卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- ②号效果的发动条件：这张卡从场上送去墓地
function c85032782.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义过滤条件：等级1的植物族怪兽且能加入手卡
function c85032782.thfilter(c)
	return c:IsLevel(1) and c:IsRace(RACE_PLANT) and c:IsAbleToHand()
end
-- 定义过滤条件：墓地中可以回到卡组的怪兽，且此时卡组或墓地存在可检索的等级1植物族怪兽
function c85032782.tdfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
		-- 检查自己的卡组或墓地是否存在等级1的植物族怪兽
		and Duel.IsExistingMatchingCard(c85032782.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
end
-- ②号效果的发动准备与对象选择
function c85032782.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c85032782.tdfilter(chkc,tp) and chkc~=e:GetHandler() end
	-- 检查自己墓地是否存在可以回到卡组的怪兽
	if chk==0 then return Duel.IsExistingTarget(c85032782.tdfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),tp) end
	-- 提示玩家选择要回到卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1只怪兽作为对象
	local g=Duel.SelectTarget(tp,c85032782.tdfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),tp)
	-- 设置回到卡组操作的信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置加入手卡操作的信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②号效果的处理
function c85032782.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为对象的墓地怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽成功回到卡组并洗卡
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从自己的卡组或墓地选择1只满足条件的植物族怪兽（受王家长眠之谷影响）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c85032782.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果，使之后的操作不视为同时处理
			Duel.BreakEffect()
			-- 将选中的怪兽加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方确认加入手卡的卡片
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
