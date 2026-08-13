--ヴォルカニック・チャージ
-- 效果：
-- 自己墓地存在的最多3张名字带有「火山」的怪兽卡回到卡组。
function c33725271.initial_effect(c)
	-- 自己墓地存在的最多3张名字带有「火山」的怪兽卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c33725271.target)
	e1:SetOperation(c33725271.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：对象必须为名字带有「火山」的怪兽卡，且能够返回卡组。
function c33725271.filter(c)
	return c:IsSetCard(0x32) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果的目标选择函数：检查对象合法性、是否存在符合条件的卡，提示并选择1~3张自己墓地的「火山」怪兽作为对象，并设置回卡组的操作信息。
function c33725271.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c33725271.filter(chkc) end
	-- 发动时判定：若自己墓地不存在符合条件的「火山」怪兽则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c33725271.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示选择提示消息，要求其选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择1~3张满足条件的「火山」怪兽卡，并指定为效果对象。
	local g=Duel.SelectTarget(tp,c33725271.filter,tp,LOCATION_GRAVE,0,1,3,nil)
	-- 登记操作信息：本次效果将把选中的卡返回卡组，用于连锁检测等。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理函数：取出连锁对象，筛选仍与效果相关的卡，并将其返回卡组。
function c33725271.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将筛选后的卡以效果原因送回持有者卡组并洗切。
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
