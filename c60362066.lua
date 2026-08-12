--壱世壊を揺るがす鼓動
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以场上1张魔法·陷阱卡为对象才能发动。那张卡回到持有者卡组。那之后，选自己1张手卡送去墓地。自己场上有「维萨斯-斯塔弗罗斯特」存在的场合，这个效果的对象可以变成2张。
-- ②：这张卡被效果送去墓地的场合，以自己墓地1张「珠泪哀歌族」陷阱卡为对象才能发动。那张卡加入手卡。
function c60362066.initial_effect(c)
	-- 注册卡片脚本中记载了「维萨斯-斯塔弗罗斯特」的卡片密码
	aux.AddCodeList(c,56099748)
	-- ①：以场上1张魔法·陷阱卡为对象才能发动。那张卡回到持有者卡组。那之后，选自己1张手卡送去墓地。自己场上有「维萨斯-斯塔弗罗斯特」存在的场合，这个效果的对象可以变成2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,60362066)
	e1:SetTarget(c60362066.tdtg)
	e1:SetOperation(c60362066.tdop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合，以自己墓地1张「珠泪哀歌族」陷阱卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,60362066)
	e2:SetCondition(c60362066.thcon)
	e2:SetTarget(c60362066.thtg)
	e2:SetOperation(c60362066.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上的魔法·陷阱卡且能回到卡组
function c60362066.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
-- 过滤条件：自己场上表侧表示的「维萨斯-斯塔弗罗斯特」
function c60362066.cfilter(c)
	return c:IsCode(56099748) and c:IsFaceup()
end
-- ①效果的发动准备（检查发动条件、选择对象并设置操作信息）
function c60362066.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c60362066.filter(chkc) and chkc~=e:GetHandler() end
	-- 检查场上是否存在可以作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c60362066.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
		-- 检查自己手卡中是否存在可以送去墓地的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	local ct=1
	-- 若自己场上存在「维萨斯-斯塔弗罗斯特」，则可选的对象数量上限变为2张
	if Duel.IsExistingMatchingCard(c60362066.cfilter,tp,LOCATION_ONFIELD,0,1,nil) then ct=2 end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择场上的魔法·陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,c60362066.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,e:GetHandler())
	-- 设置当前连锁的操作信息为：将选中的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	-- 设置当前连锁的操作信息为：将自己手卡的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- ①效果的处理（将对象卡片送回卡组，之后将手卡送去墓地）
function c60362066.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍对效果有效的对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将对象卡片送回持有者卡组并洗牌，并判断是否成功送回
	if g:GetCount()>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)~=0 then
		-- 提示玩家选择要送去墓地的手卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择自己手卡中1张可以送去墓地的卡
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,1,nil)
		if #sg>0 then
			-- 中断当前效果处理，使后续的送去墓地处理不与返回卡组同时进行
			Duel.BreakEffect()
			-- 将选中的手卡送去墓地
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件：这张卡被效果送去墓地
function c60362066.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤条件：自己墓地的「珠泪哀歌族」陷阱卡且能加入手卡
function c60362066.thfilter(c)
	return c:IsSetCard(0x181) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果的发动准备（检查发动条件、选择对象并设置操作信息）
function c60362066.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c60362066.thfilter(chkc) end
	-- 检查自己墓地是否存在可以作为对象的「珠泪哀歌族」陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c60362066.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地的1张「珠泪哀歌族」陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,c60362066.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息为：将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的处理（将墓地的对象卡片加入手牌）
function c60362066.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡片加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
