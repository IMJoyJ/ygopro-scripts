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
	-- 怪兽召唤·反转召唤·特殊召唤成功时，名字带有「落穴」的陷阱卡不能发动。
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
	-- 只要这张卡在场上表侧表示存在，
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_CHAIN_END)
	e5:SetOperation(c12755462.cedop2)
	c:RegisterEffect(e5)
end
-- 效果作用
function c12755462.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 设置连锁发动限制，禁止陷阱卡发动
	Duel.SetChainLimitTillChainEnd(c12755462.chlimit1)
end
-- 效果原文内容
function c12755462.chlimit1(re,rp,tp)
	return not re:GetHandler():IsType(TYPE_TRAP) or not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 效果作用
function c12755462.cedcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst()~=e:GetHandler()
end
-- 效果作用
function c12755462.cedop(e,tp,eg,ep,ev,re,r,rp)
	-- 当前连锁为0时
	if Duel.GetCurrentChain()==0 then
		-- 设置连锁发动限制，禁止名字带有「落穴」的陷阱卡发动
		Duel.SetChainLimitTillChainEnd(c12755462.chlimit2)
	-- 当前连锁为1时
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(12755462,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 创建EVENT_CHAINING事件监听效果并注册
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(c12755462.resetop)
		-- 将效果e1注册给玩家tp
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 将效果e2注册给玩家tp
		Duel.RegisterEffect(e2,tp)
	end
end
-- 效果作用
function c12755462.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(12755462)
	e:Reset()
end
-- 效果作用
function c12755462.cedop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(12755462)>0 then
		-- 设置连锁发动限制，禁止名字带有「落穴」的陷阱卡发动
		Duel.SetChainLimitTillChainEnd(c12755462.chlimit2)
	end
	e:GetHandler():ResetFlagEffect(12755462)
end
-- 效果原文内容
function c12755462.chlimit2(re,rp,tp)
	return not re:GetHandler():IsType(TYPE_TRAP) or not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:GetHandler():IsSetCard(0x4c)
end
