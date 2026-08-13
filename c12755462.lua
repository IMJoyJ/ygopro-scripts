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
	-- 此外，只要这张卡在场上表侧表示存在，怪兽召唤·反转召唤·特殊召唤成功时，名字带有「落穴」的陷阱卡不能发动。
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
	-- 此外，只要这张卡在场上表侧表示存在，怪兽召唤·反转召唤·特殊召唤成功时，名字带有「落穴」的陷阱卡不能发动。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_CHAIN_END)
	e5:SetOperation(c12755462.cedop2)
	c:RegisterEffect(e5)
end
-- 召唤成功时的处理函数：为当前连锁设置直到连锁结束的限制，使陷阱卡不能发动。
function c12755462.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 调用 SetChainLimitTillChainEnd，以 chlimit1 作为限制条件，使本次连锁内不能发动陷阱卡。
	Duel.SetChainLimitTillChainEnd(c12755462.chlimit1)
end
-- 连锁限制条件：仅当该效果是陷阱卡的发动（EFFECT_TYPE_ACTIVATE）时返回 false 禁止发动，其他效果允许。
function c12755462.chlimit1(re,rp,tp)
	return not re:GetHandler():IsType(TYPE_TRAP) or not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 条件判断：仅当怪兽召唤成功的对象不是这张卡自身时，本效果才适用（排除这张卡自己召唤成功的场合，避免与第一个效果重复）。
function c12755462.cedcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst()~=e:GetHandler()
end
-- 处理怪兽召唤/反转召唤/特殊召唤成功时对「落穴」的限制：若不在连锁中则直接设置限制；若在连锁中则通过标记与临时效果在连锁结束时再设置限制，以保证在连锁处理结束后依然适用。
function c12755462.cedop(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前没有正在处理的连锁（即召唤成功不入连锁，如通常召唤成功），则直接设置限制。
	if Duel.GetCurrentChain()==0 then
		-- 设置连锁限制：直到连锁结束，禁止名字带有「落穴」的陷阱卡发动。
		Duel.SetChainLimitTillChainEnd(c12755462.chlimit2)
	-- 若当前连锁数为1，说明召唤成功是在连锁处理中发生的，需要延迟到连锁结束时再设置限制。
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(12755462,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 此外，只要这张卡在场上表侧表示存在，怪兽召唤·反转召唤·特殊召唤成功时，名字带有「落穴」的陷阱卡不能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(c12755462.resetop)
		-- 将监听 EVENT_CHAINING 的临时效果注册到玩家 tp 的场上，当连锁中有效果发动时执行 resetop，清除标记。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 将监听 EVENT_BREAK_EFFECT 的临时效果注册到玩家 tp 的场上，当效果处理中断时执行 resetop，清除标记。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 重置函数：清除哥布林埋穴部队的标记效果，并销毁自身；用于在连锁继续处理时取消延迟设置的标记。
function c12755462.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(12755462)
	e:Reset()
end
-- 连锁结束时的处理：若标记存在，则设置直到连锁结束的连锁限制，禁止「落穴」陷阱卡发动；然后清除标记。
function c12755462.cedop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(12755462)>0 then
		-- 设置连锁限制：直到连锁结束，禁止名字带有「落穴」的陷阱卡发动。
		Duel.SetChainLimitTillChainEnd(c12755462.chlimit2)
	end
	e:GetHandler():ResetFlagEffect(12755462)
end
-- 连锁限制条件：仅当效果是名字带有「落穴」的陷阱卡的发动（EFFECT_TYPE_ACTIVATE）时返回 false 禁止发动，其他效果允许。
function c12755462.chlimit2(re,rp,tp)
	return not re:GetHandler():IsType(TYPE_TRAP) or not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:GetHandler():IsSetCard(0x4c)
end
