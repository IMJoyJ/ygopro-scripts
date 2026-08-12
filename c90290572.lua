--代行者の近衛 ムーン
-- 效果：
-- 天使族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「天空的圣域」或者有那个卡名记述的卡送去墓地。场上或者墓地有「天空的圣域」存在的场合，可以作为代替从自己的卡组·墓地选1只「神秘之代行者 厄斯」加入手卡。
-- ②：把自己场上1只天使族怪兽解放，以对方场上1张卡为对象才能发动。那张卡破坏。
function c90290572.initial_effect(c)
	-- 添加连接召唤手续：天使族怪兽2只。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_FAIRY),2,2)
	-- 注册卡片记述了「天空的圣域」卡号。
	aux.AddCodeList(c,56433456)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「天空的圣域」或者有那个卡名记述的卡送去墓地。场上或者墓地有「天空的圣域」存在的场合，可以作为代替从自己的卡组·墓地选1只「神秘之代行者 厄斯」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90290572,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_DECKDES+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,90290572)
	e1:SetCondition(c90290572.condition)
	e1:SetTarget(c90290572.target)
	e1:SetOperation(c90290572.operation)
	c:RegisterEffect(e1)
	-- ②：把自己场上1只天使族怪兽解放，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90290572,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,90290573)
	e2:SetCost(c90290572.descost)
	e2:SetTarget(c90290572.destg)
	e2:SetOperation(c90290572.desop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：此卡连接召唤成功。
function c90290572.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤卡组中「天空的圣域」或记述了该卡名的卡。
function c90290572.tgfilter(c)
	-- 判断卡片是否为「天空的圣域」或记述了该卡名，且能送去墓地。
	return aux.IsCodeOrListed(c,56433456) and c:IsAbleToGrave()
end
-- 过滤卡组或墓地中的「神秘之代行者 厄斯」。
function c90290572.thfilter(c)
	return c:IsCode(91188343) and c:IsAbleToHand()
end
-- 效果①的发动准备与合法性检查。
function c90290572.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上或双方墓地是否存在「天空的圣域」。
	local b=Duel.IsEnvironment(56433456,PLAYER_ALL,LOCATION_ONFIELD+LOCATION_GRAVE)
	-- 检查卡组中是否存在可送去墓地的目标卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c90290572.tgfilter,tp,LOCATION_DECK,0,1,nil)
		-- 或者在满足「天空的圣域」存在的前提下，检查卡组或墓地是否存在可加入手牌的「神秘之代行者 厄斯」。
		or b and Duel.IsExistingMatchingCard(c90290572.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- 效果①的效果处理。
function c90290572.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查卡组中是否存在可送去墓地的目标卡。
	local a=Duel.IsExistingMatchingCard(c90290572.tgfilter,tp,LOCATION_DECK,0,1,nil)
	-- 检查场上或双方墓地是否存在「天空的圣域」。
	local b=Duel.IsEnvironment(56433456,PLAYER_ALL,LOCATION_ONFIELD+LOCATION_GRAVE)
	-- 获取卡组或墓地中不受王家之谷影响的「神秘之代行者 厄斯」卡片组。
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c90290572.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	-- 若满足代替条件，且无法送墓或玩家选择代替，则执行代替效果。
	if b and #tg>0 and (not a or Duel.SelectYesNo(tp,aux.Stringid(90290572,2))) then  --"是否把「神秘之代行者 厄斯」加入手卡？"
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local g=tg:Select(tp,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 让对方玩家确认加入手牌的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	else
		-- 提示玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组选择1张「天空的圣域」或记述了该卡名的卡。
		local g=Duel.SelectMatchingCard(tp,c90290572.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡送去墓地。
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- 过滤可作为解放Cost的天使族怪兽，且场上存在其他可作为破坏对象的卡。
function c90290572.costfilter(c,tp)
	return c:IsRace(RACE_FAIRY) and (c:IsFaceup() or c:IsControler(tp))
		-- 且对方场上存在至少1张不等于该解放怪兽的卡作为效果对象。
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,c)
end
-- 效果②的发动代价（Cost）处理。
function c90290572.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可解放的天使族怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c90290572.costfilter,1,nil,tp) end
	-- 玩家选择1只自己场上的天使族怪兽解放。
	local rg=Duel.SelectReleaseGroup(tp,c90290572.costfilter,1,1,nil,tp)
	-- 解放选中的怪兽。
	Duel.Release(rg,REASON_COST)
end
-- 效果②的发动准备与目标选择。
function c90290572.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可作为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为破坏选中的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的效果处理。
function c90290572.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏该卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
