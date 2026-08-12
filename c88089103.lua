--四次元の墓
-- 效果：
-- 选择自己墓地存在的2只名字含有「LV」的怪兽，加入到自己卡组并且洗切。
function c88089103.initial_effect(c)
	-- 选择自己墓地存在的2只名字含有「LV」的怪兽，加入到自己卡组并且洗切。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c88089103.target)
	e1:SetOperation(c88089103.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选自己墓地中可以返回卡组的「LV」怪兽
function c88089103.filter(c)
	return c:IsSetCard(0x41) and c:IsAbleToDeck()
end
-- 效果发动的目标选择：验证墓地中是否存在合法的目标，并进行取对象操作
function c88089103.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c88089103.filter(chkc) end
	-- 在发动阶段的准备检查中，确认自己墓地是否存在至少2只可以成为效果对象的「LV」怪兽
	if chk==0 then return Duel.IsExistingTarget(c88089103.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 向发动效果的玩家发送提示信息，要求选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地的2只「LV」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c88089103.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置当前连锁的操作信息，声明此效果包含将2张目标卡片送回卡组的处理
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- 效果处理：获取目标卡片，将其送回卡组并洗牌，并让对方确认
function c88089103.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时被选为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将仍受效果影响的对象卡片送回持有者的卡组并洗牌
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 向对方玩家展示并确认这些送回卡组的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
