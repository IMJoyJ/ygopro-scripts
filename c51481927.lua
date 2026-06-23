--魔法吸収
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，每次自己或者对方把魔法卡发动，自己回复500基本分。
function c51481927.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在魔法与陷阱区域存在，每次自己或者对方把魔法卡发动，自己回复500基本分。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_CHAINING)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetRange(LOCATION_SZONE)
	-- 记录连锁发生时这张卡在场上存在
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- 恢复LP
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51481927,0))  --"恢复LP"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c51481927.condition)
	e2:SetOperation(c51481927.operation)
	c:RegisterEffect(e2)
end
-- 判断是否为魔法卡的发动且不是自身效果，同时确认该连锁已由chainreg记录
function c51481927.condition(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and re:GetHandler()~=e:GetHandler() and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0
end
-- 使玩家回复500基本分
function c51481927.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因使当前控制者回复500基本分
	Duel.Recover(e:GetHandlerPlayer(),500,REASON_EFFECT)
end
