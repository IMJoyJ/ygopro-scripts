--イグニッションP
-- 效果：
-- ①：场上的「点火骑士」怪兽的攻击力·守备力上升300。
-- ②：1回合1次，以自己场上1张「点火骑士」卡为对象才能发动。那张卡破坏，从卡组把1张「点火骑士」卡加入手卡。
function c79555535.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的「点火骑士」怪兽的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(300)
	-- 设置效果影响的对象为「点火骑士」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xc8))
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：1回合1次，以自己场上1张「点火骑士」卡为对象才能发动。那张卡破坏，从卡组把1张「点火骑士」卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetTarget(c79555535.destg)
	e4:SetOperation(c79555535.desop)
	c:RegisterEffect(e4)
end
-- 过滤条件：场上表侧表示的「点火骑士」卡
function c79555535.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc8)
end
-- 过滤条件：卡组中可以加入手牌的「点火骑士」卡
function c79555535.thfilter(c)
	return c:IsSetCard(0xc8) and c:IsAbleToHand()
end
-- 效果发动的目标选择与合法性检查
function c79555535.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c79555535.desfilter(chkc) end
	-- 检查自己场上是否存在可以作为破坏对象的「点火骑士」卡
	if chk==0 then return Duel.IsExistingTarget(c79555535.desfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查卡组中是否存在可以检索的「点火骑士」卡
		and Duel.IsExistingMatchingCard(c79555535.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 给玩家发送提示信息：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张「点火骑士」卡作为效果对象
	local g=Duel.SelectTarget(tp,c79555535.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置操作信息：破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：从卡组把1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：破坏对象卡，并从卡组检索「点火骑士」卡
function c79555535.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡在场且成功被效果破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 给玩家发送提示信息：请选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择1张「点火骑士」卡
		local g=Duel.SelectMatchingCard(tp,c79555535.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
