--魔力無力化の仮面
-- 效果：
-- 选1张场上的表侧表示的魔法卡。被选的魔法卡的控制者在自己的每次准备阶段受到500分的伤害。指定的卡的场上不存在的时候，这张卡破坏。
function c20765952.initial_effect(c)
	-- 选1张场上的表侧表示的魔法卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c20765952.target)
	e1:SetOperation(c20765952.operation)
	c:RegisterEffect(e1)
	-- 被选的魔法卡的控制者在自己的每次准备阶段受到500分的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20765952,0))  --"LP伤害"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c20765952.damcon)
	e2:SetTarget(c20765952.damtg)
	e2:SetOperation(c20765952.damop)
	c:RegisterEffect(e2)
	-- 指定的卡的场上不存在的时候，这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c20765952.descon)
	e3:SetOperation(c20765952.desop)
	c:RegisterEffect(e3)
end
-- 筛选场上的表侧表示的魔法卡
function c20765952.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
-- 设置效果目标为场上的表侧表示的魔法卡
function c20765952.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c20765952.filter(chkc) and chkc~=c end
	-- 判断是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(c20765952.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,c) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上的表侧表示的魔法卡作为效果对象
	Duel.SelectTarget(tp,c20765952.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,c)
end
-- 将选中的魔法卡设置为当前卡的效果对象
function c20765952.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标卡片
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		c:SetCardTarget(tc)
	end
end
-- 判断是否为当前玩家的准备阶段且目标魔法卡存在
function c20765952.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	-- 判断当前玩家是否为准备阶段的玩家且目标魔法卡存在
	return tc and Duel.IsTurnPlayer(e:GetHandlerPlayer())
end
-- 设置伤害效果的目标玩家和伤害值
function c20765952.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetHandler():GetFirstCardTarget()
	-- 设置伤害效果的目标玩家为魔法卡的控制者
	Duel.SetTargetPlayer(tc:GetControler())
	-- 设置伤害效果的伤害值为500
	Duel.SetTargetParam(500)
	-- 设置操作信息为造成伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tc:GetControler(),500)
end
-- 执行伤害效果
function c20765952.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 判断目标魔法卡是否已离开场上的条件
function c20765952.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 破坏自身效果
function c20765952.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自身从场上破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
