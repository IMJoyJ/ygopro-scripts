--連鎖炸薬
-- 效果：
-- 给与发动陷阱卡的玩家基本分1000分的伤害。
function c48276469.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对应效果原文中“发动陷阱卡的玩家”部分，即当陷阱卡发动时记录本卡已在场上存在，作为后续伤害判定的前置条件。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	-- 设置连锁发生时的操作函数为aux.chainreg，在陷阱卡发动时记录本卡在场的标志（FLAG_ID_CHAINING），用于连锁结束时判断是否满足伤害条件。
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- 对应效果原文“给与发动陷阱卡的玩家基本分1000分的伤害。”，在连锁结束时调用damop函数根据条件执行伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(c48276469.damop)
	c:RegisterEffect(e3)
end
-- 判断本次连锁中发动的效果是否为陷阱卡的发动（EFFECT_TYPE_ACTIVATE且TYPE_TRAP），并确认本卡在连锁开始时已在场上，若满足则给予发动陷阱卡的玩家1000点伤害。
function c48276469.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=re:GetHandler()
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		-- 以效果原因给予发动陷阱卡的玩家（rp）1000点基本分伤害。
		Duel.Damage(rp,1000,REASON_EFFECT)
	end
end
