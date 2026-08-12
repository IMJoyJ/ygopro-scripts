--アマゾネスの叫声
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组选「亚马逊的叫声」以外的1张「亚马逊」卡加入手卡或送去墓地。
-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只「亚马逊」怪兽为对象才能发动。这个回合，那只怪兽以外的自己怪兽不能攻击，作为对象的怪兽可以向对方怪兽全部各作1次攻击。
function c57312333.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组选「亚马逊的叫声」以外的1张「亚马逊」卡加入手卡或送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,57312333+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c57312333.target)
	e1:SetOperation(c57312333.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只「亚马逊」怪兽为对象才能发动。这个回合，那只怪兽以外的自己怪兽不能攻击，作为对象的怪兽可以向对方怪兽全部各作1次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57312333,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(c57312333.atkcost)
	e2:SetTarget(c57312333.atktg)
	e2:SetOperation(c57312333.atkop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中除「亚马逊的叫声」以外、可以加入手卡或送去墓地的「亚马逊」卡片
function c57312333.filter(c)
	return c:IsSetCard(0x4) and not c:IsCode(57312333) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- ①号效果的发动准备，检查卡组中是否存在符合条件的卡片
function c57312333.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张除「亚马逊的叫声」以外且能加入手卡或送去墓地的「亚马逊」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c57312333.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- ①号效果的处理，从卡组选择1张「亚马逊」卡片并决定加入手卡或送去墓地
function c57312333.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组选择1张满足过滤条件的「亚马逊」卡片
	local g=Duel.SelectMatchingCard(tp,c57312333.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 判断卡片是否只能加入手卡，或者在既能加入手卡也能送去墓地时由玩家选择“加入手卡”
	if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
		-- 将选择的卡片加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
	else
		-- 将选择的卡片送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- ②号效果的发动代价，检查并执行将墓地的这张卡除外
function c57312333.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将墓地的这张卡表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
-- 过滤自己场上表侧表示的「亚马逊」怪兽
function c57312333.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x4)
end
-- ②号效果的发动准备，选择自己场上1只表侧表示的「亚马逊」怪兽作为对象
function c57312333.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c57312333.atkfilter(chkc) end
	-- 检查自己场上是否存在可以作为效果对象的表侧表示「亚马逊」怪兽
	if chk==0 then return Duel.IsExistingTarget(c57312333.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「亚马逊」怪兽作为效果对象
	Duel.SelectTarget(tp,c57312333.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②号效果的处理，使对象怪兽可以向对方所有怪兽各作1次攻击，并限制其他怪兽不能攻击
function c57312333.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 作为对象的怪兽可以向对方怪兽全部各作1次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ATTACK_ALL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 这个回合，那只怪兽以外的自己怪兽不能攻击
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c57312333.ftarget)
	e2:SetLabel(tc:GetFieldID())
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，限制除对象怪兽以外的自己怪兽在本回合不能攻击
	Duel.RegisterEffect(e2,tp)
end
-- 过滤除作为对象的怪兽以外的自己场上的怪兽
function c57312333.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
