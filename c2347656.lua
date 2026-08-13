--白銀の城のラビュリンス
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：对方不能对应自己的通常陷阱卡的发动把怪兽的效果发动。
-- ②：以自己墓地1张通常陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡在自己场上没有恶魔族怪兽存在的场合不能发动。
-- ③：自己的通常陷阱卡的效果让怪兽从场上离开的场合才能发动。对方的手卡·场上1张卡破坏（从手卡是随机选）。
function c2347656.initial_effect(c)
	-- ①：对方不能对应自己的通常陷阱卡的发动把怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c2347656.chainop)
	c:RegisterEffect(e1)
	-- ②：以自己墓地1张通常陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡在自己场上没有恶魔族怪兽存在的场合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2347656,0))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,2347656)
	e2:SetTarget(c2347656.sttg)
	e2:SetOperation(c2347656.stop)
	c:RegisterEffect(e2)
	-- ③：自己的通常陷阱卡的效果让怪兽从场上离开的场合才能发动。对方的手卡·场上1张卡破坏（从手卡是随机选）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(2347656,1))  --"选对方的手卡·场上1张卡破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,2347657)
	e3:SetCondition(c2347656.descon)
	e3:SetTarget(c2347656.destg)
	e3:SetOperation(c2347656.desop)
	c:RegisterEffect(e3)
end
-- 当自己发动通常陷阱卡时，设置连锁限制条件，使对方不能对应这次发动把怪兽的效果发动。
function c2347656.chainop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():GetType()==TYPE_TRAP and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) and ep==tp then
		-- 将chainlm设为当前连锁的连锁限制条件，后续对方想要连锁发动效果时必须满足该条件才能进行。
		Duel.SetChainLimit(c2347656.chainlm)
	end
end
-- 作为连锁限制条件：若对方要发动的效果是怪兽效果则不能连锁；即对方不能对应自己的通常陷阱卡的发动来发动怪兽效果。
function c2347656.chainlm(e,rp,tp)
	return tp==rp or not e:IsActiveType(TYPE_MONSTER)
end
-- 筛选出类型为通常陷阱且可以盖放到场上的卡（用于选择对象）。
function c2347656.stfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsSSetable()
end
-- ②效果的发动条件与目标处理：判定自己墓地是否有1张可盖放的通常陷阱卡，若有则让玩家选择其中1张作为对象，并记录操作信息。
function c2347656.sttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c2347656.stfilter(chkc) end
	-- 发动时点合法性检查：自己墓地存在至少1张可以盖放的通常陷阱卡时才可发动该效果。
	if chk==0 then return Duel.IsExistingTarget(c2347656.stfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向当前玩家显示提示消息，要求选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己墓地选择1张满足条件的通常陷阱卡作为效果对象，并设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c2347656.stfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本次效果将把选择的卡从墓地移动到场上（盖放），涉及墓地卡离开墓地的处理，供相关卡检测。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ②效果处理：确认对象卡仍与效果关联后，将其盖放到自己场上；盖放成功时给那张卡附加一个‘不能发动效果’的限制，该限制在自己场上没有恶魔族怪兽时生效。
function c2347656.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这次效果的对象（之前从墓地选择的通常陷阱卡）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与当前效果关联，并尝试将其盖放到自己场上；若盖放成功则继续附加不能发动的限制。
	if tc:IsRelateToEffect(e) and Duel.SSet(tp,tc)~=0 then
		-- 这个效果盖放的卡在自己场上没有恶魔族怪兽存在的场合不能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetDescription(aux.Stringid(2347656,2))  --"「白银之城的拉比林斯」效果适用中"
		e1:SetCondition(c2347656.actcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 判断一张卡是否为表侧表示的恶魔族怪兽，用于检测自己场上是否存在恶魔族怪兽。
function c2347656.actfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsFaceup()
end
-- 作为附加限制的效果条件：当盖放的那张卡效果有效且自己场上不存在表侧表示的恶魔族怪兽时，该卡不能发动效果。
function c2347656.actcon(e)
	local tp=e:GetHandlerPlayer()
	return not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
		-- 并且自己场上不存在表侧表示的恶魔族怪兽。
		and not Duel.IsExistingMatchingCard(c2347656.actfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 判断怪兽是否因效果而从场上（主要怪兽区）离开，用于判定是否满足③效果的触发条件。
function c2347656.cfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
end
-- ③效果的触发条件：怪兽离场的原因是自己发动的通常陷阱卡的效果，且确实有怪兽因此离场。
function c2347656.descon(e,tp,eg,ep,ev,re,r,rp)
	return re and rp==tp and re:IsActiveType(TYPE_TRAP) and re:GetHandler():GetOriginalType()==TYPE_TRAP
		and eg:IsExists(c2347656.cfilter,1,nil)
end
-- ③效果的发动时点处理：判断对方手卡·场上是否有卡；若有则设置破坏的操作信息（目标为对方手卡·场上共1张）。
function c2347656.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点合法性检查：对方手卡·场上合计至少有1张卡存在时才可发动③效果。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD+LOCATION_HAND)>0 end
	-- 设置操作信息：将破坏对方手卡·场上合计1张卡，目标在效果处理时确定，不取对象。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD+LOCATION_HAND)
end
-- ③效果处理：若对方手卡不为空且（对方场上无卡或玩家选择随机破坏手卡），则从对方手卡随机选1张破坏；否则从对方场上选择1张破坏。
function c2347656.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡中的所有卡。
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	-- 获取对方场上的所有卡。
	local fg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	local g
	-- 判断是否选择随机破坏手卡：当对方有手卡且（对方场上没有卡，或玩家选择‘随机选对方手卡破坏’）时，进入随机破坏手卡分支；否则从场上选卡破坏。
	if #hg>0 and (#fg==0 or Duel.SelectOption(tp,aux.Stringid(2347656,3),aux.Stringid(2347656,4))==0) then  --"随机选对方手卡破坏/选对方场上的卡破坏"
		g=hg:RandomSelect(tp,1)
	else
		-- 提示玩家选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从对方场上选择1张要破坏的卡（不取对象，在效果处理时选择）。
		g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	end
	if g:GetCount()~=0 then
		-- 为选中的破坏目标显示选中动画，并记录这些卡被选为对象。
		Duel.HintSelection(g)
		-- 以效果破坏选中的卡，将其送去墓地。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
