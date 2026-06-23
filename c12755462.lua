--ゴブリン穴埋め部隊
-- 效果：
-- 这张卡召唤成功时，陷阱卡不能发动。此外，只要这张卡在场上表侧表示存在，怪兽召唤·反转召唤·特殊召唤成功时，名字带有「落穴」的陷阱卡不能发动。
function c12755462.initial_effect(c)
	-- 这张卡召唤成功时，陷阱卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c12755462.sumsuc)
	c:RegisterEffect(e1)
	-- 怪兽特殊召唤成功时，名字带有「落穴」的陷阱卡不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(c12755462.cedop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(c12755462.cedcon)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- 只要这张卡在场上表侧表示存在，怪兽召唤·反转召唤·特殊召唤成功时，名字带有「落穴」的陷阱卡不能发动。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_CHAIN_END)
	e5:SetOperation(c12755462.cedop2)
	c:RegisterEffect(e5)
end
-- 定义当这张卡召唤成功时触发的操作，设置连锁限制直到连锁结束。
function c12755462.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 设置连锁限制，使用chlimit1函数作为条件，禁止陷阱卡发动。
	Duel.SetChainLimitTillChainEnd(c12755462.chlimit1)
end
-- 定义连锁限制条件chlimit1，允许非陷阱卡或非发动效果的卡发动。
function c12755462.chlimit1(re,rp,tp)
	return not re:GetHandler():IsType(TYPE_TRAP) or not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 定义条件cedcon，检查事件中的怪兽是否不是自身，以避免自身召唤时触发第二效果。
function c12755462.cedcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst()~=e:GetHandler()
end
-- 定义操作cedop，处理召唤成功事件，根据当前连锁状态设置限制或注册重置效果。
function c12755462.cedop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁是否为0，即没有连锁在处理。
	if Duel.GetCurrentChain()==0 then
		-- 设置连锁限制，使用chlimit2函数作为条件，禁止名字带有「落穴」的陷阱卡发动。
		Duel.SetChainLimitTillChainEnd(c12755462.chlimit2)
	-- 检查当前连锁是否为1，即连锁1中。
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(12755462,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 只要这张卡在场上表侧表示存在，怪兽召唤·反转召唤·特殊召唤成功时，名字带有「落穴」的陷阱卡不能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(c12755462.resetop)
		-- 将效果e1注册给全局环境，用于玩家tp，以监听连锁发动事件。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 将效果e2注册给全局环境，用于玩家tp，以监听连锁中断事件。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 定义操作resetop，重置标志效果并重置自身效果。
function c12755462.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(12755462)
	e:Reset()
end
-- 定义操作cedop2，在连锁结束时如果标志存在则设置连锁限制，并重置标志。
function c12755462.cedop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(12755462)>0 then
		-- 设置连锁限制，使用chlimit2函数作为条件，禁止名字带有「落穴」的陷阱卡发动。
		Duel.SetChainLimitTillChainEnd(c12755462.chlimit2)
	end
	e:GetHandler():ResetFlagEffect(12755462)
end
-- 定义连锁限制条件chlimit2，允许非陷阱卡、非发动效果或非名字带有「落穴」的卡发动。
function c12755462.chlimit2(re,rp,tp)
	return not re:GetHandler():IsType(TYPE_TRAP) or not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:GetHandler():IsSetCard(0x4c)
end
