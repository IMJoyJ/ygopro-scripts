--リチュア・ナタリア
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转的回合的结束阶段时回到持有者手卡。这张卡召唤·反转时，可以选择自己墓地1只名字带有「遗式」的怪兽回到卡组最上面。
function c17241370.initial_effect(c)
	-- 为这张卡添加灵魂怪兽效果：当此卡召唤或反转成功的回合结束阶段，此卡回到持有者手卡。
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件的判定值设为false，使该卡永远无法被特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 这张卡召唤·反转时，可以选择自己墓地1只名字带有「遗式」的怪兽回到卡组最上面。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(17241370,1))  --"返回卡组"
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetTarget(c17241370.tdtg)
	e4:SetOperation(c17241370.tdop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP)
	c:RegisterEffect(e5)
end
-- 定义过滤器：筛选出自己墓地中卡名包含「遗式」、属于怪兽且可以返回卡组的卡，作为可选对象。
function c17241370.filter(c)
	return c:IsSetCard(0x3a) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果发动时的目标选择阶段：检查并选择1只满足条件的「遗式」怪兽，将其设为效果对象并登记回卡组的操作信息。
function c17241370.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c17241370.filter(chkc) end
	-- 效果发动条件检查：在效果发动时确认自己墓地中存在至少1只满足条件的「遗式」怪兽，存在才能发动。
	if chk==0 then return Duel.IsExistingTarget(c17241370.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择要返回卡组的卡”的提示消息，用于选择卡牌的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择1只满足条件的「遗式」怪兽作为效果对象（取对象效果），并自动将其标记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c17241370.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本连锁的操作信息：该效果将把1张卡返回卡组（类别为CATEGORY_TODECK），供后续效果发动检测与处理时参考。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理阶段：获取之前选择的对象卡，确认其仍与效果相关后，将其送往持有者卡组最顶端。
function c17241370.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的第一个（也是唯一一个）效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将该卡送回持有者卡组最顶端（SEQ_DECKTOP表示返回卡组最上面）。
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
