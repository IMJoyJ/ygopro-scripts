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
-- 发动条件：因对方卡的效果受到1000点以上的伤害
function c5914184.actcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and 1-tp==rp and ev>=1000 and bit.band(r,REASON_EFFECT)~=0
end
-- 发动准备：检查是否能按伤害每满1000放置1个倍倍指示物（0x1a）
function c5914184.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查这张卡是否可以放置计算数量的倍倍指示物
	if chk==0 then return Duel.IsCanAddCounter(tp,0x1a,math.floor(ev/1000),e:GetHandler()) end
end
-- 发动处理：根据伤害计算并放置倍倍指示物，同时注册下次对方回合结束阶段破坏并造成伤害的强制诱发效果
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
		-- 判断发动时是否处于己方回合，以计算下次对方回合的等待回合数
		if Duel.GetTurnPlayer()==tp then
			e1:SetLabel(0)
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		else
			-- 若在对方回合发动，记录当前回合数，避免在当前回合的结束阶段直接触发
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
		end
		c:RegisterEffect(e1)
	end
end
-- 伤害效果触发条件：处于对方回合的结束阶段且非发动当个回合
function c5914184.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前为对方回合且与发动时的回合数不同
	return Duel.GetTurnPlayer()~=tp and Duel.GetTurnCount()~=e:GetLabel()
end
-- 伤害效果发动准备：计算放置指示物数量×2000的伤害数值，并设置破坏与伤害操作信息
function c5914184.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	local dam=e:GetHandler():GetCounter(0x1a)*2000;
	-- 设置伤害数值参数（指示物数量×2000）
	Duel.SetTargetParam(dam)
	-- 设置连锁操作信息：破坏此卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置连锁操作信息：对对方给予计算数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果处理：破坏自身，成功破坏时对对方给予指示物数量×2000的伤害
function c5914184.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡破坏，并判断是否成功破坏
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
		-- 获取目标玩家与伤害数值
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 给与对方计算的伤害数值
		Duel.Damage(p,d,REASON_EFFECT)
	end
end
