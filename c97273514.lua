--甲虫装機 ピコファレーナ
-- 效果：
-- 昆虫族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合，丢弃1张手卡，以这张卡以外的自己场上1只昆虫族怪兽为对象才能发动。从卡组选1只昆虫族怪兽当作攻击力·守备力上升500的装备卡使用给作为对象的怪兽装备。
-- ②：以自己墓地3只昆虫族怪兽为对象才能发动。那些怪兽回到卡组洗切。那之后，自己从卡组抽1张。
function c97273514.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤的手续，需要2只昆虫族怪兽作为素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_INSECT),2,2)
	-- ①：这张卡连接召唤成功的场合，丢弃1张手卡，以这张卡以外的自己场上1只昆虫族怪兽为对象才能发动。从卡组选1只昆虫族怪兽当作攻击力·守备力上升500的装备卡使用给作为对象的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97273514,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,97273514)
	e1:SetCondition(c97273514.eqcon)
	e1:SetCost(c97273514.eqcost)
	e1:SetTarget(c97273514.eqtg)
	e1:SetOperation(c97273514.eqop)
	c:RegisterEffect(e1)
	-- ②：以自己墓地3只昆虫族怪兽为对象才能发动。那些怪兽回到卡组洗切。那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97273514,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,97273515)
	e2:SetTarget(c97273514.drtg)
	e2:SetOperation(c97273514.drop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：这张卡连接召唤成功
function c97273514.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果①的Cost：丢弃1张手卡
function c97273514.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择并丢弃1张手卡
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：场上表侧表示的昆虫族怪兽
function c97273514.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 过滤条件：卡组中可以作为装备卡装备的昆虫族怪兽
function c97273514.eqfilter(c,tp)
	return c:IsRace(RACE_INSECT) and c:CheckUniqueOnField(tp) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 效果①的发动准备：检查场上是否有其他昆虫族怪兽、魔法与陷阱区域是否有空位、卡组中是否有可装备的昆虫族怪兽，并选择对象
function c97273514.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c97273514.filter(chkc) and chkc~=c end
	-- 检查自己场上是否存在除这张卡以外的表侧表示昆虫族怪兽
	if chk==0 then return Duel.IsExistingTarget(c97273514.filter,tp,LOCATION_MZONE,0,1,c)
		-- 检查自己的魔法与陷阱区域是否有可用的空格
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在可以作为装备卡装备的昆虫族怪兽
		and Duel.IsExistingMatchingCard(c97273514.eqfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只除自身以外的表侧表示昆虫族怪兽作为效果对象
	Duel.SelectTarget(tp,c97273514.filter,tp,LOCATION_MZONE,0,1,1,c)
end
-- 效果①的效果处理：从卡组选1只昆虫族怪兽作为装备卡装备给对象怪兽，并使其攻击力·守备力上升500
function c97273514.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 若魔法与陷阱区域没有空位，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从卡组选择1只满足条件的昆虫族怪兽
	local ec=Duel.SelectMatchingCard(tp,c97273514.eqfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if ec then
		-- 将选中的昆虫族怪兽作为装备卡装备给对象怪兽
		Duel.Equip(tp,ec,tc)
		-- 当作攻击力·守备力上升500的装备卡使用给作为对象的怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c97273514.eqlimit)
		e1:SetLabelObject(tc)
		ec:RegisterEffect(e1)
		-- 攻击力·守备力上升500
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		ec:RegisterEffect(e3)
	end
end
-- 装备限制：只能装备给作为对象的怪兽
function c97273514.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 过滤条件：墓地中可以回到卡组的昆虫族怪兽
function c97273514.tdfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToDeck()
end
-- 效果②的发动准备：检查自己是否能抽卡、墓地是否有3只昆虫族怪兽，并选择对象，设置操作信息
function c97273514.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c97273514.tdfilter(chkc) end
	-- 检查玩家当前是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查自己墓地是否存在至少3只昆虫族怪兽
		and Duel.IsExistingTarget(c97273514.tdfilter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 提示玩家选择要回到卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地3只昆虫族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c97273514.tdfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 设置效果处理信息：将选中的卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置效果处理信息：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的效果处理：将对象怪兽送回卡组洗切，之后自己抽1张卡
function c97273514.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与当前效果有关联的对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()<=0 then return end
	-- 将对象卡片送回持有者卡组并洗切
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取实际被操作（送回卡组）的卡片组
	local g=Duel.GetOperatedGroup()
	-- 如果卡片回到了主卡组，则洗切卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		-- 中断当前效果处理，使后续的抽卡处理不与回卡组同时进行
		Duel.BreakEffect()
		-- 玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
