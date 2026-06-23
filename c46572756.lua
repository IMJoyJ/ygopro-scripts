--レアル・ジェネクス・ウルティマム
-- 效果：
-- ①：场上的表侧表示的这张卡被破坏送去墓地时，以自己墓地2只「次世代」怪兽为对象才能发动。那些怪兽回到卡组。
function c46572756.initial_effect(c)
	-- 创建效果，设置为诱发选发效果，满足条件时才能发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46572756,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c46572756.condition)
	e1:SetTarget(c46572756.target)
	e1:SetOperation(c46572756.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：这张卡从场上被破坏送去墓地
function c46572756.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP)
end
-- 筛选函数：判断是否为「次世代」怪兽且能回到卡组
function c46572756.filter(c)
	return c:IsSetCard(0x2) and c:IsAbleToDeck()
end
-- 设置效果目标：选择自己墓地2只符合条件的怪兽
function c46572756.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c46572756.filter(chkc) end
	-- 检查阶段：确认场上是否存在满足条件的2只怪兽
	if chk==0 then return Duel.IsExistingTarget(c46572756.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择目标：从自己墓地选择2只「次世代」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c46572756.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置操作信息：记录将要返回卡组的2张卡
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- 效果处理函数：将选中的怪兽送回卡组
function c46572756.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将符合条件的怪兽送回卡组并洗牌
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
