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
-- 检查发动条件：自己因对方卡片效果受到1000以上的伤害
function c5914184.actcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and 1-tp==rp and ev>=1000 and bit.band(r,REASON_EFFECT)~=0
end
-- 检查是否能向这张卡放置对应数量的倍倍指示物
function c5914184.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能向这张卡放置受到的伤害每满1000对应的倍倍指示物数量
	if chk==0 then return Duel.IsCanAddCounter(tp,0x1a,math.floor(ev/1000),e:GetHandler()) end
end
-- 效果处理：给这张卡放置对应数量的倍倍指示物，并注册下次对方回合结束阶段时发动破坏并造成伤害的效果
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
		-- 判断当前是否为自己回合，以确定“下次的对方回合”的重置和生效时机
		if Duel.GetTurnPlayer()==tp then
			e1:SetLabel(0)
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		else
			-- 记录当前回合数，用于在对方回合结束阶段判断是否为“下次”的对方回合
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
		end
		c:RegisterEffect(e1)
	end
end
-- 检查是否为下次的对方回合的结束阶段
function c5914184.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 必须是对方回合，且回合数不能是发动效果时的当前回合（确保是“下次的对方回合”）
	return Duel.GetTurnPlayer()~=tp and Duel.GetTurnCount()~=e:GetLabel()
end
-- 伤害效果的目标确认，设置伤害对象为对方，并计算伤害数值
function c5914184.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	local dam=e:GetHandler():GetCounter(0x1a)*2000;
	-- 设置伤害的数值参数
	Duel.SetTargetParam(dam)
	-- 设置操作信息：破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置操作信息：给与对方伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果的处理：破坏自身，并给与对方对应数值的伤害
function c5914184.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试因效果破坏自身，若破坏成功则继续处理
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
		-- 获取预设的伤害对象玩家和伤害数值
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 因效果给与目标玩家伤害
		Duel.Damage(p,d,REASON_EFFECT)
	end
end
