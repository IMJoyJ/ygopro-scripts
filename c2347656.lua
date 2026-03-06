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
-- 连锁处理时，若对方发动的是通常陷阱卡，则设置连锁限制条件。
function c2347656.chainop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():GetType()==TYPE_TRAP and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) and ep==tp then
		-- 设置连锁限制函数，限制对方不能连锁怪兽效果。
		Duel.SetChainLimit(c2347656.chainlm)
	end
end
-- 连锁限制函数，若为对方发动的怪兽效果则禁止连锁。
function c2347656.chainlm(e,rp,tp)
	return tp==rp or not e:IsActiveType(TYPE_MONSTER)
end
-- 过滤函数，用于筛选墓地中的通常陷阱卡。
function c2347656.stfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsSSetable()
end
-- 效果处理时，选择目标墓地中的通常陷阱卡。
function c2347656.sttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c2347656.stfilter(chkc) end
	-- 判断是否满足选择目标的条件，即墓地存在通常陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c2347656.stfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择目标墓地中的通常陷阱卡。
	local g=Duel.SelectTarget(tp,c2347656.stfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，记录将要离开墓地的卡。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果处理时，将目标卡特殊召唤到场上并设置不能发动效果。
function c2347656.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡。
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且成功特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.SSet(tp,tc)~=0 then
		-- 创建一个效果，使盖放的卡不能发动效果。
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
-- 过滤函数，用于筛选场上存在的恶魔族怪兽。
function c2347656.actfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsFaceup()
end
-- 条件函数，判断是否满足盖放卡不能发动的条件。
function c2347656.actcon(e)
	local tp=e:GetHandlerPlayer()
	return not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
		-- 若场上不存在恶魔族怪兽则该效果不能发动。
		and not Duel.IsExistingMatchingCard(c2347656.actfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于筛选因效果离场的怪兽。
function c2347656.cfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
end
-- 条件函数，判断是否满足发动效果的条件。
function c2347656.descon(e,tp,eg,ep,ev,re,r,rp)
	return re and rp==tp and re:IsActiveType(TYPE_TRAP) and re:GetHandler():GetOriginalType()==TYPE_TRAP
		and eg:IsExists(c2347656.cfilter,1,nil)
end
-- 效果处理时，选择对方手卡或场上的卡作为破坏对象。
function c2347656.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足选择破坏对象的条件。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD+LOCATION_HAND)>0 end
	-- 设置操作信息，记录将要破坏的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD+LOCATION_HAND)
end
-- 效果处理时，选择对方手卡或场上的卡进行破坏。
function c2347656.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡。
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	-- 获取对方场上卡。
	local fg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	local g
	-- 若对方手卡存在且场上无卡，则随机选择对方手卡破坏。
	if #hg>0 and (#fg==0 or Duel.SelectOption(tp,aux.Stringid(2347656,3),aux.Stringid(2347656,4))==0) then  --"随机选对方手卡破坏/选对方场上的卡破坏"
		g=hg:RandomSelect(tp,1)
	else
		-- 提示玩家选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上的卡进行破坏。
		g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	end
	if g:GetCount()~=0 then
		-- 显示被选为破坏对象的卡。
		Duel.HintSelection(g)
		-- 将选中的卡破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
