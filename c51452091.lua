--王宮のお触れ
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，场上的其他的陷阱卡的效果无效化。
function c51452091.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，场上的其他的陷阱卡的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e2:SetTarget(c51452091.distarget)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在魔法与陷阱区域存在，场上的其他的陷阱卡的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(c51452091.disop)
	c:RegisterEffect(e3)
	-- ①：只要这张卡在魔法与陷阱区域存在，场上的其他的陷阱卡的效果无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(c51452091.distarget)
	c:RegisterEffect(e4)
end
-- 无效化目标筛选：判定对象卡不是本卡自身且为陷阱卡，即只有场上的其他陷阱卡才会被无效化。
function c51452091.distarget(e,c)
	return c~=e:GetHandler() and c:IsType(TYPE_TRAP)
end
-- 连锁处理时的无效化操作：若当前连锁是魔法与陷阱区域的陷阱卡发动且不是本卡，则将其效果发动无效，对应效果文本中“其他的陷阱卡的效果无效化”。
function c51452091.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在处理的连锁的发生位置，用于确认该连锁是否从魔法与陷阱区域发动。
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if tl==LOCATION_SZONE and re:IsActiveType(TYPE_TRAP) and re:GetHandler()~=e:GetHandler() then
		-- 使该连锁的效果无效，即对发动中的其他陷阱卡的效果进行无效。
		Duel.NegateEffect(ev)
	end
end
