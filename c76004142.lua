--不運の爆弾
-- 效果：
-- 「不运的爆弹」在1回合只能发动1张。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。自己受到那只表侧表示怪兽的攻击力一半数值的伤害。那之后，给与对方为和自己受到的伤害相同数值的伤害。
-- ②：场上的这张卡被对方破坏送去墓地的场合发动。给与对方1000伤害。
function c76004142.initial_effect(c)
	-- 「不运的爆弹」在1回合只能发动1张。①：以对方场上1只表侧表示怪兽为对象才能发动。自己受到那只表侧表示怪兽的攻击力一半数值的伤害。那之后，给与对方为和自己受到的伤害相同数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1e1)
	e1:SetCountLimit(1,76004142+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c76004142.target)
	e1:SetOperation(c76004142.activate)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被对方破坏送去墓地的场合发动。给与对方1000伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c76004142.damcon)
	e2:SetTarget(c76004142.damtg)
	e2:SetOperation(c76004142.damop)
	c:RegisterEffect(e2)
end
-- 过滤对方场上表侧表示且攻击力大于0的怪兽
function c76004142.filter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- ①号效果的发动准备（检查对象是否合法、选择对象并设置伤害操作信息）
function c76004142.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c76004142.filter(chkc) end
	-- 检查对方场上是否存在符合条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c76004142.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家发送选择表侧表示卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c76004142.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表示此效果包含对双方玩家造成伤害的处理
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
-- ①号效果的实际处理（自己受伤害，然后给对方相同数值的伤害）
function c76004142.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=math.floor(tc:GetAttack()/2)
		-- 自己受到该怪兽攻击力一半数值的伤害，并记录实际受到的伤害值
		local val=Duel.Damage(tp,atk,REASON_EFFECT)
		-- 如果自己实际受到了伤害且生命值大于0，则继续处理后续效果
		if val>0 and Duel.GetLP(tp)>0 then
			-- 中断效果处理，使后续伤害与之前的伤害不视为同时处理（用于“那之后”的时点）
			Duel.BreakEffect()
			-- 给与对方与自己受到的伤害相同数值的伤害
			Duel.Damage(1-tp,val,REASON_EFFECT)
		end
	end
end
-- 检查②号效果的发动条件：场上的这张卡被对方破坏并送去墓地
function c76004142.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_DESTROY)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- ②号效果的发动准备（设置伤害对象为对方，伤害数值为1000）
function c76004142.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害的参数值为1000
	Duel.SetTargetParam(1000)
	-- 设置操作信息，表示此效果包含给与对方1000伤害的处理
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- ②号效果的实际处理（给与对方1000伤害）
function c76004142.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
