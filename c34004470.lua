--The big SATURN
-- 效果：
-- 这张卡不能作从手卡·卡组的特殊召唤。丢弃1张手卡并支付1000基本分。直到结束阶段时这张卡的攻击力上升1000。这个效果1回合只有1次在自己的主要阶段才能使用。对方控制的卡的效果把这张卡破坏送去墓地时，双方受到那个攻击力数值的伤害。
function c34004470.initial_effect(c)
	-- 对应效果原文：“这张卡不能作从手卡·卡组的特殊召唤。”
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件判定值设为false，实际禁止从手卡·卡组进行特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 对应效果原文：“丢弃1张手卡并支付1000基本分。直到结束阶段时这张卡的攻击力上升1000。这个效果1回合只有1次在自己的主要阶段才能使用。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34004470,0))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c34004470.atcost)
	e2:SetOperation(c34004470.atop)
	c:RegisterEffect(e2)
	-- 对应效果原文：“对方控制的卡的效果把这张卡破坏送去墓地时，双方受到那个攻击力数值的伤害。”
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34004470,1))  --"伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c34004470.damcon)
	e3:SetTarget(c34004470.damtg)
	e3:SetOperation(c34004470.damop)
	c:RegisterEffect(e3)
end
-- 代价检查与支付：chk==0时确认玩家能支付1000LP且手牌有可丢弃的卡；满足后丢弃1张手卡并支付1000LP作为发动代价。
function c34004470.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段（chk==0）：确认玩家是否能支付1000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000)
		-- 代价检查阶段（chk==0）：确认手牌中是否存在至少1张可以丢弃的卡。
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：由玩家选择并丢弃1张手卡（因为丢弃原因同时包含代价与丢弃）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
	-- 实际支付代价：扣除玩家1000基本分。
	Duel.PayLPCost(tp,1000)
end
-- 效果处理：若此卡仍表侧表示且与发动效果关联，则给它注册一个攻击力上升1000的临时效果，持续到结束阶段。
function c34004470.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 对应效果原文：“直到结束阶段时这张卡的攻击力上升1000。”
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 伤害诱发条件：本卡被对方控制的效果破坏并送去墓地（破坏原因包含效果），且发动方是对方，被破坏前由效果发动者控制。
function c34004470.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,0x41)==0x41 and rp==1-tp and c:IsPreviousControler(tp)
end
-- 伤害设定：无对象效果的目标设定，取得本卡当前攻击力作为伤害值，存入连锁参数并设置操作信息为对双方造成伤害。
function c34004470.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=e:GetHandler():GetAttack()
	-- 将当前攻击力数值设定为连锁的伤害参数，供后续伤害处理使用。
	Duel.SetTargetParam(dam)
	-- 设定操作信息：本连锁将要造成伤害，伤害对象为双方全体，伤害值为dam（用于效果发动检测与时点判定）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,dam)
end
-- 伤害处理：从连锁信息中取出伤害值，先后给予对方和己方数值相同的效果伤害，并完成伤害步骤的时点触发。
function c34004470.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取之前保存的伤害参数（即攻击力数值）。
	local d=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 给予对方玩家d点效果伤害（分步结算）。
	Duel.Damage(1-tp,d,REASON_EFFECT,true)
	-- 给予自己玩家d点效果伤害（分步结算）。
	Duel.Damage(tp,d,REASON_EFFECT,true)
	-- 通知伤害/回复处理完毕，触发因伤害产生的时点。
	Duel.RDComplete()
end
