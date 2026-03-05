--古代の機械工兵
-- 效果：
-- ①：只要这张卡在怪兽区域存在，这张卡为对象的陷阱卡的效果无效化并破坏。
-- ②：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ③：这张卡攻击的伤害步骤结束时，以对方场上1张魔法·陷阱卡为对象发动。那张对方的魔法·陷阱卡破坏。
function c1953925.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，这张卡为对象的陷阱卡的效果无效化并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(c1953925.distg)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SELF_DESTROY)
	c:RegisterEffect(e2)
	-- ②：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(c1953925.disop)
	c:RegisterEffect(e3)
	-- ③：这张卡攻击的伤害步骤结束时，以对方场上1张魔法·陷阱卡为对象发动。那张对方的魔法·陷阱卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,1)
	e4:SetValue(c1953925.aclimit)
	e4:SetCondition(c1953925.actcon)
	c:RegisterEffect(e4)
	-- 效果作用
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(1953925,0))  --"破坏"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_DAMAGE_STEP_END)
	e5:SetCondition(c1953925.descon)
	e5:SetTarget(c1953925.destg)
	e5:SetOperation(c1953925.desop)
	c:RegisterEffect(e5)
end
-- 检索满足条件的卡片组
function c1953925.distg(e,c)
	if not c:IsType(TYPE_TRAP) or c:GetCardTargetCount()==0 then return false end
	return c:GetCardTarget():IsContains(e:GetHandler())
end
-- 处理连锁中陷阱卡效果的无效化与破坏
function c1953925.disop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if not rc:IsType(TYPE_TRAP) then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	if not e:GetHandler():IsRelateToEffect(re) then return end
	-- 获取当前连锁的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if g and g:IsContains(e:GetHandler()) then
		-- 使连锁效果无效并检查是否能破坏对象卡
		if Duel.NegateEffect(ev,true) and rc:IsRelateToEffect(re) then
			-- 破坏对象陷阱卡
			Duel.Destroy(rc,REASON_EFFECT)
		end
	end
end
-- 限制对方发动魔法·陷阱卡
function c1953925.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 判断是否为攻击状态
function c1953925.actcon(e)
	-- 判断是否为攻击状态
	return Duel.GetAttacker()==e:GetHandler()
end
-- 判断是否为攻击状态且伤害步骤结束
function c1953925.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为攻击状态且伤害步骤结束
	return e:GetHandler()==Duel.GetAttacker() and aux.dsercon(e,tp,eg,ep,ev,re,r,rp)
end
-- 过滤魔法·陷阱卡
function c1953925.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 选择目标魔法·陷阱卡
function c1953925.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c1953925.filter(chkc) end
	if chk==0 then return true end
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标魔法·陷阱卡
	local g=Duel.SelectTarget(tp,c1953925.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏操作
function c1953925.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
