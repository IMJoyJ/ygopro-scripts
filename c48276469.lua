--連鎖炸薬
-- 效果：
-- 给与发动陷阱卡的玩家基本分1000分的伤害。
function c48276469.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 记录连锁发生时这张卡在场上存在
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	-- 设置效果执行函数为aux.chainreg，用于记录连锁信息
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- 当连锁处理结束时，对发动陷阱卡的玩家造成1000分伤害
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(c48276469.damop)
	c:RegisterEffect(e3)
end
-- 判断是否为陷阱卡发动且该连锁中存在本卡，若满足条件则触发伤害效果
function c48276469.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=re:GetHandler()
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		-- 给与发动陷阱卡的玩家基本分1000分的伤害
		Duel.Damage(rp,1000,REASON_EFFECT)
	end
end
