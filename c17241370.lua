--リチュア・ナタリア
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转的回合的结束阶段时回到持有者手卡。这张卡召唤·反转时，可以选择自己墓地1只名字带有「遗式」的怪兽回到卡组最上面。
function c17241370.initial_effect(c)
	-- 为卡片添加在召唤或反转成功后的结束阶段回到手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该效果为无法被无效且无法被复制的特殊召唤条件
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 这张卡召唤·反转时，可以选择自己墓地1只名字带有「遗式」的怪兽回到卡组最上面
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
-- 定义过滤器函数，用于筛选墓地里名字带有「遗式」的怪兽卡片
function c17241370.filter(c)
	return c:IsSetCard(0x3a) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 处理效果的发动时点，检查是否能选择目标并设置操作信息
function c17241370.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c17241370.filter(chkc) end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(c17241370.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送提示信息，提示选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的墓地怪兽作为目标
	local g=Duel.SelectTarget(tp,c17241370.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁的操作信息，指定将目标怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 处理效果的发动，将选中的目标怪兽送回卡组最上面
function c17241370.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片以效果原因送回卡组最顶端
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
