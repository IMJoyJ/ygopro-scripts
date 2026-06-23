--炎帝近衛兵
-- 效果：
-- ①：这张卡召唤的场合，以自己墓地4只炎族怪兽为对象发动。那4只怪兽回到卡组。那之后，自己抽2张。
function c54040221.initial_effect(c)
	-- ①：这张卡召唤的场合，以自己墓地4只炎族怪兽为对象发动。那4只怪兽回到卡组。那之后，自己抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54040221,0))  --"返回卡组抽卡"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c54040221.tg)
	e1:SetOperation(c54040221.op)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中可以回到卡组的炎族怪兽
function c54040221.filter(c)
	return c:IsRace(RACE_PYRO) and c:IsAbleToDeck()
end
-- 效果①的发动准备，处理对象选择和操作信息注册
function c54040221.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c54040221.filter(chkc) end
	if chk==0 then return true end
	-- 判断自己墓地中是否存在至少4只符合条件的炎族怪兽
	if Duel.IsExistingTarget(c54040221.filter,tp,LOCATION_GRAVE,0,4,nil) then
		-- 在客户端显示提示信息，要求玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择自己墓地的4只炎族怪兽作为效果对象
		local g=Duel.SelectTarget(tp,c54040221.filter,tp,LOCATION_GRAVE,0,4,4,nil)
		-- 设置效果处理信息，声明此效果包含将选中的怪兽送回卡组的操作
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
		-- 设置效果处理信息，声明此效果包含让玩家抽2张卡的操作
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	end
end
-- 效果①的实际处理，执行返回卡组和抽卡的操作
function c54040221.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=4 then return end
	-- 将作为对象的怪兽送回持有者的卡组
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取实际被送回卡组或额外卡组的卡片组
	local g=Duel.GetOperatedGroup()
	-- 若有卡片被送回主卡组，则洗切玩家的卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==4 then
		-- 中断当前效果处理，使前后的返回卡组与抽卡不视为同时进行
		Duel.BreakEffect()
		-- 让玩家从卡组抽2张卡
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
