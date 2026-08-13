--倍返し
-- 效果：
-- 对方的卡的效果让自己受到1000以上的伤害时才能发动。那个时候受到的伤害每有1000，给这张卡放置1个倍倍指示物。下次的对方回合的结束阶段时，这张卡破坏并给与对方基本分这张卡放置的倍倍指示物数量×2000的数值的伤害。
function c5914184.initial_effect(c)
	c:EnableCounterPermit(0x1a)
	-- 对方的卡的效果让自己受到1000以上的伤害时才能发动。那个时候受到的伤害每有1000，给这张卡放置1个倍倍指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetCondition(c5914184.actcon)
	e1:SetTarget(c5914184.acttg)
	e1:SetOperation(c5914184.actop)
	c:RegisterEffect(e1)
end
c5914184.mentioned_counter={
	[0x1a]=true,
}
-- 发动条件：受到伤害的玩家是自己（ep==tp）、伤害来源于对方的卡的效果（1-tp==rp 且 r 含 REASON_EFFECT），且伤害数值在1000以上。
function c5914184.actcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and 1-tp==rp and ev>=1000 and bit.band(r,REASON_EFFECT)~=0
end
-- 发动对象的检查：确认自己能否给这张卡放置「受到的伤害÷1000（向下取整）」个倍倍指示物，能放置才能发动。
function c5914184.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己能否给这张卡放置伤害数值每1000对应的1个倍倍指示物。
	if chk==0 then return Duel.IsCanAddCounter(tp,0x1a,math.floor(ev/1000),e:GetHandler()) end
end
-- 效果处理：若这张卡仍与效果相关联，则按受到的伤害每1000放置1个倍倍指示物，并给这张卡注册一个在下次对方回合结束阶段触发的破坏并给与伤害的效果（根据当前回合玩家设置标签与重置时机）。
function c5914184.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local ct=math.floor(ev/1000)
		c:AddCounter(0x1a,ct)
		-- 下次的对方回合的结束阶段时，这张卡破坏并给与对方基本分这张卡放置的倍倍指示物数量×2000的数值的伤害。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(5914184,0))  --"伤害"
		e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetRange(LOCATION_SZONE)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCondition(c5914184.damcon)
		e1:SetTarget(c5914184.damtg)
		e1:SetOperation(c5914184.damop)
		-- 判断当前回合玩家是否是自己（自己回合发动与对方回合发动时，「下次的对方回合」对应的回合数不同）。
		if Duel.GetTurnPlayer()==tp then
			e1:SetLabel(0)
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		else
			-- 记录当前回合数作为标签，用于后续判断是否已经轮到「下次的对方回合」。
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
		end
		c:RegisterEffect(e1)
	end
end
-- 伤害效果的发动条件：当前是对方的回合，且当前回合数不是发动时记录的回合数（即已轮到下次的对方回合）。
function c5914184.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家是对方，且不是发动时的那个回合（确保在下次的对方回合的结束阶段才触发）。
	return Duel.GetTurnPlayer()~=tp and Duel.GetTurnCount()~=e:GetLabel()
end
-- 伤害效果的对象设定：以对方玩家为对象，计算这张卡放置的倍倍指示物数量×2000的伤害数值，并设置破坏这张卡与给与对方伤害的操作信息。
function c5914184.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 把当前连锁的对象玩家设置为对方。
	Duel.SetTargetPlayer(1-tp)
	local dam=e:GetHandler():GetCounter(0x1a)*2000;
	-- 把当前连锁的对象参数设置为计算出的伤害数值（倍倍指示物数量×2000）。
	Duel.SetTargetParam(dam)
	-- 设置操作信息：这个效果将以效果原因破坏这张卡自身（1张）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置操作信息：这个效果将给与对方玩家dam点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理：若以效果原因成功破坏了这张卡，则取出连锁的对象玩家与伤害数值，给与对方该数值的伤害。
function c5914184.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因破坏这张卡，破坏成功（数量不为0）才继续处理伤害。
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
		-- 从当前连锁信息中取出之前设置的对象玩家和伤害数值。
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 以效果原因给与对象玩家p造成d点基本分伤害。
		Duel.Damage(p,d,REASON_EFFECT)
	end
end
