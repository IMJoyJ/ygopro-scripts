--インターセプト・デーモン
-- 效果：
-- 只要这张卡在自己场上表侧攻击表示存在，对方怪兽的攻击宣言时，给与对方基本分500分伤害。
function c14430063.initial_effect(c)
	-- 对应效果原文：只要这张卡在自己场上表侧攻击表示存在，对方怪兽的攻击宣言时，给与对方基本分500分伤害。
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
-- 定义伤害诱发效果的发动条件函数：检查此卡是否表侧攻击表示，且当前为对方回合的攻击宣言。
function c14430063.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件：此卡处于表侧攻击表示，且当前回合玩家不是这张卡的控制者（即对方回合）。
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK) and Duel.GetTurnPlayer()~=tp
end
-- 定义效果的发动目标处理函数：在效果发动时记录伤害对象、伤害数值，并登记连锁的操作信息。
function c14430063.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的对象玩家设为对方玩家（1-tp），即伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将效果的对象参数设为500，即造成的伤害数值为500。
	Duel.SetTargetParam(500)
	-- 登记连锁操作信息：宣告将给予对方500点效果伤害，供后续时点与连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 定义效果处理函数：在效果结算时确认此卡仍为表侧攻击表示且与效果关联后，实际执行伤害。
function c14430063.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPosition(POS_FACEUP_ATTACK) and c:IsRelateToEffect(e) then
		-- 从当前连锁信息中取出此前设定的对象玩家和伤害参数。
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 以效果原因对对象玩家造成对应数值的伤害。
		Duel.Damage(p,d,REASON_EFFECT)
	end
end
