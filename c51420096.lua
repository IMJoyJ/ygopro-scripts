--魔救の奇石－ティアマイト
local s,id,o=GetID()
-- 创建效果，注册两个效果，分别为发动时检索并特殊召唤和墓地发动的送回卡组效果
function s.initial_effect(c)
	-- 当此卡特殊召唤成功时，可以发动的效果，将满足条件的卡加入手牌并可能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 在墓地时可发动的效果，将场上或墓地的岩石族同步怪兽送回额外卡组和自身送回卡组
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.dttg)
	e2:SetOperation(s.dtop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否为岩石族特殊召唤而来
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSpecialSummonSetCard(0x140)
end
-- 过滤满足条件的卡：不是此卡本身、是岩石族、可以加入手牌
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x140) and c:IsAbleToHand()
end
-- 设置效果处理时要操作的卡，从卡组中选择一张岩石族卡加入手牌
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤满足条件的卡：是岩石族、可以特殊召唤
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理效果，选择一张卡加入手牌并确认，若手牌中有卡且有空场则可特殊召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 如果选中的卡成功加入手牌
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 判断是否手牌中有卡且场上还有空位
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 获取满足特殊召唤条件的卡组
			local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
			-- 询问玩家是否要特殊召唤
			if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				-- 中断当前效果处理，使后续效果视为错时点
				Duel.BreakEffect()
				-- 提示玩家选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local tg=sg:Select(tp,1,1,nil)
				-- 洗切自己的手牌
				Duel.ShuffleHand(tp)
				-- 将选中的卡特殊召唤到场上
				Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 过滤满足条件的卡：表侧表示、是岩石族、是同步怪兽、可以送回额外卡组
function s.texfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_ROCK) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
end
-- 设置效果处理时要操作的目标，选择场上或墓地的岩石族同步怪兽和自身
function s.dttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and s.texfilter(chkc) and chkc~=c end
	-- 检查是否存在满足条件的目标卡和自身是否能送回卡组
	if chk==0 then return Duel.IsExistingTarget(s.texfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,c) and c:IsAbleToDeck() end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 优先从场上选择满足条件的卡作为目标
	local g=aux.SelectTargetFromFieldFirst(tp,s.texfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,c)
	-- 设置操作信息为将卡送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	-- 设置操作信息为将自身送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
-- 处理效果，将选中的卡和自身送回卡组
function s.dtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡是否有效且未被王家长眠之谷影响，并成功送回卡组
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) and c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将自身送回卡组顶部
		Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
