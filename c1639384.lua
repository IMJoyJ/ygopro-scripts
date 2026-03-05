--神竜騎士フェルグラント
-- 效果：
-- 8星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以场上1只表侧表示怪兽为对象才能发动。这个回合，作为对象的怪兽效果无效，不受这张卡以外的效果影响。这个效果在对方回合也能发动。
function c1639384.initial_effect(c)
	-- 添加8星等级、需要2只怪兽进行XYZ召唤的手续
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以场上1只表侧表示怪兽为对象才能发动。这个回合，作为对象的怪兽效果无效，不受这张卡以外的效果影响。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1639384,0))  --"效果耐性"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c1639384.cost)
	e1:SetTarget(c1639384.target)
	e1:SetOperation(c1639384.operation)
	c:RegisterEffect(e1)
end
-- 支付1个超量素材作为cost
function c1639384.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选表侧表示的怪兽作为目标
function c1639384.filter(c)
	return c:IsFaceup()
end
-- 选择1只表侧表示的怪兽作为效果对象
function c1639384.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c1639384.filter(chkc) end
	-- 判断是否存在满足条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c1639384.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,c1639384.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 处理效果的发动与结算
function c1639384.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 这个回合，作为对象的怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 这个回合，作为对象的怪兽不受这张卡以外的效果影响
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 这个效果在对方回合也能发动
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetValue(c1639384.efilter)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
-- 效果免疫函数，仅对非自身卡片的效果生效
function c1639384.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
