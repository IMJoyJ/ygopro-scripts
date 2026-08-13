--夜の逃飛行
-- 效果：
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽回到持有者手卡。这个回合，双方不能把这个效果加入手卡的卡以及那些同名卡的效果发动。
function c42560034.initial_effect(c)
	-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽回到持有者手卡。这个回合，双方不能把这个效果加入手卡的卡以及那些同名卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42560034,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c42560034.target)
	e1:SetOperation(c42560034.activate)
	c:RegisterEffect(e1)
end
-- 对象选择过滤：只选择表侧表示且能够被送回手卡的怪兽。
function c42560034.filter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 效果发动时的目标处理：检查是否存在合法对象，若存在则让玩家选择自己场上1只表侧表示且能回手的怪兽，并设定回手牌的操作信息。
function c42560034.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c42560034.filter(chkc) end
	-- 发动条件判定：自己场上是否存在至少1只满足表侧表示且能回手的怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c42560034.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出选择提示文案“请选择要返回手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家从自己场上选择1只符合条件的怪兽作为效果对象，同时将该卡登记为本连锁的对象。
	local g=Duel.SelectTarget(tp,c42560034.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本次效果将把对象卡加入手牌（回手牌），用于后续处理与连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：若对象仍与效果关联且为表侧表示，则将其送回持有者手卡；若回手成功，则再注册一个本回合内禁止双方发动该卡及同名卡效果的封印效果。
function c42560034.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup()
		-- 将对象怪兽送回持有者手卡；若实际送回成功且该卡现在位于手牌，则继续执行后续封印效果。
		and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- “这个回合，双方不能把这个效果加入手卡的卡以及那些同名卡的效果发动。”——即给双方附加一个持续到结束阶段的发动禁止效果。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,1)
		e1:SetValue(c42560034.actlimit)
		e1:SetLabel(tc:GetCode())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将上述封印效果注册到当前玩家场地，作用于双方（通过SetTargetRange(1,1)），持续到回合结束。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 封印判定：若某玩家发动的效果的发动者卡片卡号与回手卡片卡号一致（即该卡或其同名卡），则禁止其效果发动。
function c42560034.actlimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
