--進化の宿命
-- 效果：
-- 自己的名字带有「进化虫」的怪兽的效果让怪兽特殊召唤成功时，对方不能把魔法·陷阱·效果怪兽的效果发动。
function c8632967.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己的名字带有「进化虫」的怪兽的效果让怪兽特殊召唤成功时
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(c8632967.sucop)
	c:RegisterEffect(e2)
	-- 对方不能把魔法·陷阱·效果怪兽的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetOperation(c8632967.cedop)
	c:RegisterEffect(e3)
end
-- 连锁限制函数，限制只有自身玩家可以发动效果（即对方不能发动效果）
function c8632967.chainlm(e,rp,tp)
	return tp==rp
end
-- 过滤条件，检查怪兽是否是由名字带有「进化虫」的怪兽的效果特殊召唤
function c8632967.sucfilter(c)
	local typ=c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)
	return c:IsSummonType(SUMMON_VALUE_EVOLTILE) or (typ&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x304e))
end
-- 特殊召唤成功时的处理，若满足条件且在连锁1，则给自身卡片注册标识，并注册用于在后续连锁或效果中断时重置该标识的临时效果
function c8632967.sucop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断特殊召唤的怪兽中是否存在满足「进化虫」效果召唤条件的怪兽，且当前处于连锁1
	if eg:IsExists(c8632967.sucfilter,1,nil) and Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(8632967,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 对方不能把魔法·陷阱·效果怪兽的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(c8632967.resetop)
		-- 注册全局效果，在有新效果发动时重置标识，防止在非时点内限制对方发动
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册全局效果，在效果处理中断时重置标识
		Duel.RegisterEffect(e2,tp)
	end
end
-- 重置函数，清除自身卡片的标识并使该重置效果自身失效
function c8632967.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(8632967)
	e:Reset()
end
-- 连锁结束时的处理，若存在标识则限制对方在当前连锁结束前发动卡或效果，随后重置标识
function c8632967.cedop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(8632967)~=0 then
		-- 设定直到当前连锁结束为止的连锁限制，阻止对方发动任何效果
		Duel.SetChainLimitTillChainEnd(c8632967.chainlm)
	end
	e:GetHandler():ResetFlagEffect(8632967)
end
