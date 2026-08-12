--驚天動地
-- 效果：
-- ①：从自己或者对方的卡组有卡被送去墓地的场合，以自己或者对方的墓地1张卡为对象把这个效果发动。那张卡回到持有者卡组。这个效果的发动后，直到回合结束时双方不能从卡组把卡送去墓地。
function c54407825.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：从自己或者对方的卡组有卡被送去墓地的场合，以自己或者对方的墓地1张卡为对象把这个效果发动。那张卡回到持有者卡组。这个效果的发动后，直到回合结束时双方不能从卡组把卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c54407825.condition)
	e2:SetTarget(c54407825.target)
	e2:SetOperation(c54407825.operation)
	c:RegisterEffect(e2)
end
-- 过滤出原本在卡组的卡片
function c54407825.filter(c)
	return c:IsPreviousLocation(LOCATION_DECK)
end
-- 判断送去墓地的卡中是否存在原本在卡组的卡，作为效果发动的条件
function c54407825.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c54407825.filter,1,nil)
end
-- 效果发动时的目标选择与操作信息设置，选择双方墓地中可以回到卡组的1张卡作为对象
function c54407825.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() end
	if chk==0 then return true end
	-- 给发动效果的玩家发送“请选择要返回卡组的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己或对方墓地1张可以回到卡组的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置当前连锁的操作信息，表示该效果的处理为将选中的卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理，将作为对象的卡送回持有者卡组，并注册直到回合结束时双方不能从卡组把卡送去墓地的效果
function c54407825.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将作为对象的卡片送回持有者卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
	-- 这个效果的发动后，直到回合结束时双方不能从卡组把卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_GRAVE)
	e1:SetTargetRange(LOCATION_DECK,LOCATION_DECK)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境注册该限制效果，使双方不能将卡组的卡送去墓地
	Duel.RegisterEffect(e1,tp)
	-- 这个效果的发动后，直到回合结束时双方不能从卡组把卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_DISCARD_DECK)
	e2:SetTargetRange(1,1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境注册该限制效果，使双方玩家不能通过丢弃卡组等方式将卡组的卡送去墓地
	Duel.RegisterEffect(e2,tp)
end
