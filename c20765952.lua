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
-- 过滤条件：卡必须为表侧表示且为魔法卡。
function c20765952.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
-- 发动时的目标选择处理：从双方魔陷区选择1张表侧表示的魔法卡作为对象，不能选择此卡自身。
function c20765952.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c20765952.filter(chkc) and chkc~=c end
	-- 检查场上是否存在至少1张符合条件的表侧表示魔法卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c20765952.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,c) end
	-- 向当前玩家显示选择效果对象的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让当前玩家从双方魔陷区选择1张表侧表示的魔法卡作为对象（排除自身），并登记为该效果的对象。
	Duel.SelectTarget(tp,c20765952.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,c)
end
-- 效果处理：若此卡与所选对象均仍与效果关联且对象仍表侧表示，则将此卡设为所选对象的永续对象，用于持续追踪。
function c20765952.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本连锁效果选择的对象卡（第一张）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		c:SetCardTarget(tc)
	end
end
-- 准备阶段伤害的触发条件：存在永续对象，且当前回合玩家为此卡控制者。
function c20765952.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	-- 返回是否满足触发条件：存在永续对象，并且当前回合属于此卡的控制者。
	return tc and Duel.IsTurnPlayer(e:GetHandlerPlayer())
end
-- 伤害效果的目标设定：记录对象卡控制者为受伤玩家，伤害值为500，并写入操作信息。
function c20765952.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetHandler():GetFirstCardTarget()
	-- 将连锁的对象玩家设置为对象卡的控制者。
	Duel.SetTargetPlayer(tc:GetControler())
	-- 将连锁的对象参数设置为伤害值500。
	Duel.SetTargetParam(500)
	-- 设置操作信息：本连锁将造成500点效果伤害，伤害对象为对象卡的控制者。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tc:GetControler(),500)
end
-- 伤害效果的实际处理：从连锁信息中取得目标玩家和伤害值，对目标玩家造成效果伤害。
function c20765952.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出目标玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成500点效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 破坏触发条件：此卡未被预定破坏；存在永续对象；且该对象卡发生了离场事件。
function c20765952.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 破坏效果的实际处理：当对象卡离场时，将这张魔力无力化之假面破坏。
function c20765952.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将这张卡（魔力无力化之假面）破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
