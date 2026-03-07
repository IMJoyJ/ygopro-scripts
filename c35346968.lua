--神の恵み
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，每次自己抽卡，自己回复500基本分。
function c35346968.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，每次自己抽卡，自己回复500基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DRAW)
	e2:SetOperation(c35346968.recop)
	c:RegisterEffect(e2)
end
-- 检测到自己抽卡时触发效果，判断抽卡玩家是否为效果持有者，是则执行回复LP操作
function c35346968.recop(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp then return end
	-- 使效果持有者回复500基本分
	Duel.Recover(tp,500,REASON_EFFECT)
end
