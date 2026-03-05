--森羅の守神 アルセイ
-- 效果：
-- 8星怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，宣言1个卡名才能发动。自己卡组最上面的卡翻开，宣言的卡的场合，那张卡加入手卡。不是的场合，翻开的卡送去墓地。
-- ②：自己卡组的卡被效果送去墓地的场合，把这张卡1个超量素材取除，以场上1张卡为对象才能发动。那张卡回到持有者卡组最上面或者最下面。
function c10406322.initial_effect(c)
	-- 为卡片添加等级为8、需要2只怪兽进行XYZ召唤的手续
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，宣言1个卡名才能发动。自己卡组最上面的卡翻开，宣言的卡的场合，那张卡加入手卡。不是的场合，翻开的卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10406322,0))  --"宣言卡名"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c10406322.target)
	e1:SetOperation(c10406322.operation)
	c:RegisterEffect(e1)
	-- ②：自己卡组的卡被效果送去墓地的场合，把这张卡1个超量素材取除，以场上1张卡为对象才能发动。那张卡回到持有者卡组最上面或者最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10406322,1))  --"返回卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,10406322)
	e2:SetCondition(c10406322.tdcon)
	e2:SetCost(c10406322.tdcost)
	e2:SetTarget(c10406322.tdtg)
	e2:SetOperation(c10406322.tdop)
	c:RegisterEffect(e2)
end
-- 效果处理函数：设置效果目标
function c10406322.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以将卡组最上方的1张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	-- 提示玩家选择要宣言的卡牌类型
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	getmetatable(e:GetHandler()).announce_filter={TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT}
	-- 让玩家宣言一个卡牌类型
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 将宣言的卡牌类型设置为效果的目标参数
	Duel.SetTargetParam(ac)
	-- 设置效果操作信息，提示玩家宣言了卡牌类型
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 效果处理函数：执行效果
function c10406322.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否可以将卡组最上方的1张卡送去墓地
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 确认玩家卡组最上方的1张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取玩家卡组最上方的1张卡
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	-- 获取当前连锁的目标参数（即宣言的卡牌类型）
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if tc:IsCode(ac) and tc:IsAbleToHand() then
		-- 禁用洗牌检测
		Duel.DisableShuffleCheck()
		-- 将翻开的卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 洗切玩家手牌
		Duel.ShuffleHand(tp)
	else
		-- 禁用洗牌检测
		Duel.DisableShuffleCheck()
		-- 将翻开的卡送去墓地并显示
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
	end
end
-- 条件过滤函数：判断卡是否因效果从卡组送去墓地
function c10406322.cfilter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_DECK) and c:IsPreviousControler(tp)
end
-- 触发条件函数：判断是否有卡因效果从卡组送去墓地
function c10406322.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c10406322.cfilter,1,nil,tp)
end
-- 效果消耗函数：移除1个超量素材
function c10406322.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果目标选择函数：选择场上1张可回到卡组的卡
function c10406322.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToDeck() end
	-- 检查场上是否存在可回到卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择将卡送回卡组的位置
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	-- 选择场上1张可回到卡组的卡
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，提示将卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理函数：执行效果
function c10406322.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:IsExtraDeckMonster()
			-- 选择将卡送回卡组的位置（最上面或最下面）
			or Duel.SelectOption(tp,aux.Stringid(10406322,2),aux.Stringid(10406322,3))==0 then  --"返回卡组最上面" / "返回卡组最下面"
			-- 将目标卡送回卡组最上方
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		else
			-- 将目标卡送回卡组最下方
			Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
