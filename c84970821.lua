--暗黒の呪縛
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，每次自己或者对方把魔法卡发动给与那个发动的玩家1000伤害。
function c84970821.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，每次自己或者对方把魔法卡发动给与那个发动的玩家1000伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	-- 设置效果操作为：在连锁发生时，记录这张卡在场上存在。
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在魔法与陷阱区域存在，每次自己或者对方把魔法卡发动给与那个发动的玩家1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(c84970821.damop)
	c:RegisterEffect(e3)
end
-- 在连锁处理结束时，判断发动的卡是否为魔法卡，且本卡在连锁开始时是否已在场，若是则给与发动的玩家伤害。
function c84970821.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=re:GetHandler()
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		-- 给与发动该魔法卡的玩家1000点效果伤害。
		Duel.Damage(rp,1000,REASON_EFFECT)
	end
end
