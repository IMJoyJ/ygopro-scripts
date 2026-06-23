--森羅の守神 アルセイ
-- 效果：
-- 8星怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，宣言1个卡名才能发动。自己卡组最上面的卡翻开，宣言的卡的场合，那张卡加入手卡。不是的场合，翻开的卡送去墓地。
-- ②：自己卡组的卡被效果送去墓地的场合，把这张卡1个超量素材取除，以场上1张卡为对象才能发动。那张卡回到持有者卡组最上面或者最下面。
function c10406322.initial_effect(c)
	-- 添加超量召唤手续：8星怪兽×2
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
-- ①效果的Target函数，检查是否能翻开卡组，并让玩家宣言1个卡名
function c10406322.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能将卡组顶部的卡送去墓地，作为能否翻开卡组的判断
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	-- 给玩家发送宣言卡名的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT}
	-- 让玩家宣言一个卡名（过滤掉额外怪兽等类型）
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 保存宣言的卡名作为效果处理参数
	Duel.SetTargetParam(ac)
	-- 设置操作信息为宣言卡名
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- ①效果的Operation函数，翻开卡组顶部的卡，若是宣言的卡则加入手卡，否则送去墓地
function c10406322.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果玩家此时无法将卡组顶部的卡送去墓地，则效果不处理
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 确认自己卡组最上方的一张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取自己卡组最上方的一张卡
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	-- 获取发动时宣言的卡名
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if tc:IsCode(ac) and tc:IsAbleToHand() then
		-- 使接下来的卡片移动操作不自动触发洗牌
		Duel.DisableShuffleCheck()
		-- 将该卡加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 洗切手卡
		Duel.ShuffleHand(tp)
	else
		-- 使接下来的送去墓地操作不自动洗切卡组
		Duel.DisableShuffleCheck()
		-- 将翻开的卡送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
	end
end
-- 过滤被效果送去墓地的、原位置在自己卡组的卡片的条件函数
function c10406322.cfilter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_DECK) and c:IsPreviousControler(tp)
end
-- ②效果的发动条件：自己卡组的卡被效果送去墓地
function c10406322.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c10406322.cfilter,1,nil,tp)
end
-- ②效果的Cost：把这张卡1个超量素材取除
function c10406322.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ②效果的Target函数，选择场上一张卡作为对象并发动
function c10406322.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToDeck() end
	-- 检查场上是否存在能回到卡组的卡作为对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给玩家提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 以场上1张可以回到卡组的卡为对象发动
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息为将该对象卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ②效果的Operation函数，使对象卡回到持有者卡组的最上面或者最下面
function c10406322.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:IsExtraDeckMonster()
			-- 若目标卡是额外怪兽，或者玩家选择将其放回卡组最上方
			or Duel.SelectOption(tp,aux.Stringid(10406322,2),aux.Stringid(10406322,3))==0 then  --"返回卡组最上面/返回卡组最下面"
			-- 将目标卡送回持有者卡组最上面
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		else
			-- 将目标卡送回持有者卡组最下面
			Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
