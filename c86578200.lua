--魔界大道具「ニゲ馬車」
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，自己的「魔界剧团」怪兽在1回合各有1次不会被战斗破坏。
-- ②：1回合1次，以自己场上1只「魔界剧团」怪兽为对象才能发动。直到对方回合结束时，对方不能把那只怪兽作为效果的对象。
-- ③：自己的额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在，盖放的这张卡被对方的效果破坏的场合才能发动。对方场上的卡全部回到持有者手卡。
function c86578200.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己的「魔界剧团」怪兽在1回合各有1次不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的目标为「魔界剧团」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x10ec))
	e2:SetValue(c86578200.indct)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以自己场上1只「魔界剧团」怪兽为对象才能发动。直到对方回合结束时，对方不能把那只怪兽作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(86578200,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(c86578200.tgtg)
	e3:SetOperation(c86578200.tgop)
	c:RegisterEffect(e3)
	-- ③：自己的额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在，盖放的这张卡被对方的效果破坏的场合才能发动。对方场上的卡全部回到持有者手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(86578200,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(c86578200.thcon)
	e4:SetTarget(c86578200.thtg)
	e4:SetOperation(c86578200.thop)
	c:RegisterEffect(e4)
end
-- 判定破坏原因为战斗破坏时，提供1次免于破坏的次数
function c86578200.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		return 1
	else return 0 end
end
-- 过滤条件：表侧表示的「魔界剧团」卡
function c86578200.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x10ec)
end
-- 效果②的发动准备：进行对象合法性检测并选择自己场上1只表侧表示的「魔界剧团」怪兽
function c86578200.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c86578200.filter(chkc) end
	-- 检查自己场上是否存在可以作为对象的表侧表示「魔界剧团」怪兽
	if chk==0 then return Duel.IsExistingTarget(c86578200.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送提示信息，提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「魔界剧团」怪兽作为效果对象
	Duel.SelectTarget(tp,c86578200.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的处理：给作为对象的怪兽赋予“不能成为对方效果对象”的效果
function c86578200.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 直到对方回合结束时，对方不能把那只怪兽作为效果的对象。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		-- 设置不能成为对象的效果仅对对方玩家生效
		e1:SetValue(aux.tgoval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
	end
end
-- 效果③的发动条件：盖放的这张卡被对方效果破坏，且自己额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在
function c86578200.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
		-- 检查自己的额外卡组是否存在表侧表示的「魔界剧团」灵摆怪兽
		and Duel.IsExistingMatchingCard(c86578200.filter,tp,LOCATION_EXTRA,0,1,nil)
end
-- 效果③的发动准备：检查对方场上是否有可以送回手牌的卡，并注册操作信息
function c86578200.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在可以送回手牌的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有可以送回手牌的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁的操作信息为将对方场上的卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果③的处理：将对方场上的卡全部送回持有者手牌
function c86578200.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有可以送回手牌的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 将获取到的卡全部因效果送回持有者手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
