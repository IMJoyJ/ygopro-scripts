--星なる影 ゲニウス
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡反转的场合，以自己场上1只「影依」怪兽为对象才能发动。那只表侧表示怪兽直到回合结束时不受自身以外的怪兽的效果影响。
-- ②：这张卡被效果送去墓地的场合，以场上1只效果怪兽为对象才能发动。这个回合，双方不能把那只效果怪兽的场上发动的效果发动。
function c66675911.initial_effect(c)
	-- ①：这张卡反转的场合，以自己场上1只「影依」怪兽为对象才能发动。那只表侧表示怪兽直到回合结束时不受自身以外的怪兽的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66675911,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,66675911)
	e1:SetCost(c66675911.cost)
	e1:SetTarget(c66675911.target)
	e1:SetOperation(c66675911.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合，以场上1只效果怪兽为对象才能发动。这个回合，双方不能把那只效果怪兽的场上发动的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66675911,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,66675911)
	e2:SetCost(c66675911.cost)
	e2:SetCondition(c66675911.actcon)
	e2:SetTarget(c66675911.acttg)
	e2:SetOperation(c66675911.actop)
	c:RegisterEffect(e2)
	c66675911.shadoll_flip_effect=e1
end
-- 效果发动Cost函数，在chk为0时返回true，并在发动时向对方玩家提示所选择发动的效果
function c66675911.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示当前发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 过滤条件：自己场上表侧表示的「影依」怪兽
function c66675911.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9d)
end
-- 效果①的发动准备：检查并选择自己场上1只表侧表示的「影依」怪兽作为效果对象
function c66675911.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c66675911.filter(chkc) end
	-- 检查自己场上是否存在至少1只可以作为对象的表侧表示「影依」怪兽
	if chk==0 then return Duel.IsExistingTarget(c66675911.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置选择卡片时的提示信息为“请选择效果的对象”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择自己场上1只表侧表示的「影依」怪兽作为效果对象
	Duel.SelectTarget(tp,c66675911.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的执行操作：使作为对象的怪兽直到回合结束时不受自身以外的怪兽效果影响
function c66675911.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只表侧表示怪兽直到回合结束时不受自身以外的怪兽的效果影响。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(c66675911.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 免疫效果的过滤函数：判定来源是否为自身以外的怪兽效果
function c66675911.efilter(e,re)
	return e:GetHandler()~=re:GetOwner() and re:IsActiveType(TYPE_MONSTER)
end
-- 效果②的发动条件：这张卡被效果送去墓地
function c66675911.actcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤条件：场上表侧表示的效果怪兽
function c66675911.actfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 效果②的发动准备：检查并选择场上1只表侧表示的效果怪兽作为效果对象
function c66675911.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c66675911.actfilter(chkc) end
	-- 检查场上是否存在至少1只可以作为对象的表侧表示效果怪兽
	if chk==0 then return Duel.IsExistingTarget(c66675911.actfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置选择卡片时的提示信息为“请选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择场上1只表侧表示的效果怪兽作为效果对象
	Duel.SelectTarget(tp,c66675911.actfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果②的执行操作：使作为对象的效果怪兽在这个回合不能发动在场上发动的效果
function c66675911.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的效果怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，双方不能把那只效果怪兽的场上发动的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
