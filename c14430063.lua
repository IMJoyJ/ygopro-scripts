--インターセプト・デーモン
-- 效果：
-- 只要这张卡在自己场上表侧攻击表示存在，对方怪兽的攻击宣言时，给与对方基本分500分伤害。
function c14430063.initial_effect(c)
	-- 只要这张卡在自己场上表侧攻击表示存在，对方怪兽的攻击宣言时，给与对方基本分500分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14430063,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c14430063.damcon)
	e1:SetTarget(c14430063.damtg)
	e1:SetOperation(c14430063.damop)
	c:RegisterEffect(e1)
end
-- 效果发动的条件判断函数
function c14430063.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 满足条件：拦截恶魔必须处于表侧攻击表示且当前回合玩家不是自己
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK) and Duel.GetTurnPlayer()~=tp
end
-- 效果的发动时处理函数
function c14430063.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的目标玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理的目标参数为500点伤害
	Duel.SetTargetParam(500)
	-- 设置连锁操作信息为造成伤害效果，目标玩家为对方，伤害值为500
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果的处理函数
function c14430063.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPosition(POS_FACEUP_ATTACK) and c:IsRelateToEffect(e) then
		-- 从当前连锁中获取目标玩家和目标参数（即伤害值）
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 对目标玩家造成指定数值的伤害，伤害原因为效果
		Duel.Damage(p,d,REASON_EFFECT)
	end
end
