--無差別破壊
-- 效果：
-- 每次自己的准备阶段丢1次骰子。和投出来的数目一样等级的怪兽全部破坏。（投出来的数目是6的场合包括6星以上的怪兽）
function c32015116.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 每次自己的准备阶段丢1次骰子。和投出来的数目一样等级的怪兽全部破坏。（投出来的数目是6的场合包括6星以上的怪兽）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32015116,0))  --"投掷骰子"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DICE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c32015116.rdcon)
	e2:SetTarget(c32015116.rdtg)
	e2:SetOperation(c32015116.rdop)
	c:RegisterEffect(e2)
end
-- 效果触发条件：仅在效果持有者的准备阶段且该玩家为当前回合玩家时才满足发动条件。
function c32015116.rdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为这张卡的持有者（发动者），若是则返回true，使效果可以在自己的准备阶段发动。
	return tp==Duel.GetTurnPlayer()
end
-- 效果发动时的目标处理：该效果不取对象，因此合法检查直接返回true；同时向系统登记本次操作包含骰子效果。
function c32015116.rdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁的操作信息为CATEGORY_DICE，表示后续处理中会进行掷骰子，供相关效果（如针对骰子效果的干扰）检测。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 定义骰子结果对应的怪兽过滤条件：点数1-5时选择场上表侧表示且等级等于点数的怪兽；点数6时选择场上表侧表示且等级6星以上的怪兽；其他情况不选择。
function c32015116.rdfilter(c,lv)
	if lv<=5 then
		return c:IsFaceup() and c:IsLevel(lv)
	elseif lv==6 then
		return c:IsFaceup() and c:IsLevelAbove(6)
	else
		return false
	end
end
-- 效果处理：投1次骰子，根据点数筛选场上所有符合条件的表侧表示怪兽，并将其全部以效果原因破坏。
function c32015116.rdop(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家投掷1次骰子，得到点数d1（1-6）。
	local d1=Duel.TossDice(tp,1)
	-- 获取双方怪兽区中所有满足rdfilter条件（等级与骰子点数相符，点数为6时为6星以上）的表侧表示怪兽，作为将要破坏的群体。
	local g=Duel.GetMatchingGroup(c32015116.rdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,d1)
	-- 将筛选出的怪兽全部破坏，破坏原因为效果破坏（REASON_EFFECT）。
	Duel.Destroy(g,REASON_EFFECT)
end
