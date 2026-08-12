--氷の魔妖－雪女
-- 效果：
-- 「魔妖」怪兽2只
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：「冰之魔妖-雪女」在自己场上只能有1只表侧表示存在。
-- ②：只要这张卡所连接区有同调怪兽存在，对方不能选择这张卡作为攻击对象。
-- ③：这张卡在怪兽区域存在，自己的同调怪兽被战斗或者对方的效果破坏的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时变成一半。
function c66870733.initial_effect(c)
	c:SetUniqueOnField(1,0,66870733)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：使用2只「魔妖」怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x121),2,2)
	-- 只要这张卡所连接区有同调怪兽存在，对方不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(c66870733.imcon)
	-- 设置不能成为攻击对象效果的过滤函数
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- 这张卡在怪兽区域存在，自己的同调怪兽被战斗或者对方的效果破坏的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66870733,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,66870733)
	e2:SetCondition(c66870733.atkcon)
	e2:SetTarget(c66870733.atktg)
	e2:SetOperation(c66870733.atkop)
	c:RegisterEffect(e2)
end
-- 过滤所连接区表侧表示同调怪兽的条件函数
function c66870733.imfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 判定这张卡的所连接区是否存在表侧表示同调怪兽
function c66870733.imcon(e)
	return e:GetHandler():GetLinkedGroup():IsExists(c66870733.imfilter,1,nil)
end
-- 过滤被破坏的卡是否为自己场上表侧表示的同调怪兽，且是被战斗或对方效果破坏
function c66870733.atkfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousTypeOnField()&TYPE_SYNCHRO~=0
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 判定被破坏的卡片中是否存在满足条件的自己同调怪兽
function c66870733.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c66870733.atkfilter,1,nil,tp)
end
-- 效果3的发动准备阶段，确认并选择场上1只表侧表示怪兽作为对象
function c66870733.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsFaceup() and chkc:IsLocation(LOCATION_MZONE) end
	-- 检查场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送选择表侧表示卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果3的实际处理，使作为对象的怪兽的攻击力·守备力直到回合结束时变成一半
function c66870733.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的第一个对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力……直到回合结束时变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的……守备力直到回合结束时变成一半。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(math.ceil(tc:GetDefense()/2))
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
