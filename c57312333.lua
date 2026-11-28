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
	-- 设定②效果的发动条件为本回合仍可进入战斗阶段
	e2:SetCondition(aux.bpcon)
	e2:SetCost(c57312333.atkcost)
	e2:SetTarget(c57312333.atktg)
	e2:SetOperation(c57312333.atkop)
	c:RegisterEffect(e2)
end
-- ①效果过滤函数：筛选「亚马逊的叫声」以外可加入手卡或送去墓地的「亚马逊」卡
function c57312333.filter(c)
	return c:IsSetCard(0x4) and not c:IsCode(57312333) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- ①效果发动检查：确认卡组中存在符合条件的「亚马逊」卡
function c57312333.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张满足①效果条件的「亚马逊」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c57312333.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- ①效果处理：从卡组选择1张符合条件的「亚马逊」卡，根据玩家选择或可执行性将其加入手卡或送去墓地
function c57312333.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要从卡组操作的「亚马逊」卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从自己卡组选择1张符合条件的「亚马逊」卡
	local g=Duel.SelectMatchingCard(tp,c57312333.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 判断选中的卡是否可加入手卡，并在无法送墓或玩家选择加入手卡时进入回手分支
	if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
		-- 以效果原因将选中的「亚马逊」卡加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家公开确认加入手卡的卡
		Duel.ConfirmCards(1-tp,tc)
	else
		-- 以效果原因将选中的「亚马逊」卡送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- ②效果代价处理：检查并将墓地中的这张卡除外
function c57312333.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将墓地中的这张卡表侧除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
-- ②效果对象过滤函数：筛选表侧表示的「亚马逊」怪兽
function c57312333.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x4)
end
-- ②效果目标设定：取自己场上1只表侧表示的「亚马逊」怪兽为对象
function c57312333.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c57312333.atkfilter(chkc) end
	-- 检查自己怪兽区是否存在至少1只可作为对象的表侧「亚马逊」怪兽
	if chk==0 then return Duel.IsExistingTarget(c57312333.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示选择作为效果对象的「亚马逊」怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只表侧表示的「亚马逊」怪兽作为效果对象
	Duel.SelectTarget(tp,c57312333.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：赋予对象怪兽本回合可向对方怪兽全部各攻击1次的效果，同时限制自己场上其他怪兽本回合不能攻击
function c57312333.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选为对象的「亚马逊」怪兽
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
	-- 为自己注册限制其他怪兽攻击的场地全局效果
	Duel.RegisterEffect(e2,tp)
end
-- 攻击限制过滤函数：选出场上ID不等于对象怪兽的所有己方怪兽
function c57312333.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
