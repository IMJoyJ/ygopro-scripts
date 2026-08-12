--星因士 ウヌク
-- 效果：
-- 「星因士 天市右垣七」的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合才能发动。从卡组把「星因士 天市右垣七」以外的1张「星骑士」卡送去墓地。
function c1050186.initial_effect(c)
	-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合才能发动。从卡组把「星因士 天市右垣七」以外的1张「星骑士」卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1050186,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,1050186)
	e1:SetTarget(c1050186.target)
	e1:SetOperation(c1050186.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	c1050186.star_knight_summon_effect=e1
end
-- 过滤函数，用于筛选满足条件的卡片
function c1050186.filter(c)
	return c:IsSetCard(0x9c) and not c:IsCode(1050186) and c:IsAbleToGrave()
end
-- 效果处理时的Target函数，用于判断是否可以发动效果
function c1050186.target(e,tp,eg,ep,ev,re,r,rp,chk,_,exc)
	-- 检查以玩家tp来看的卡组中是否存在至少1张满足filter条件且不等于exc的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c1050186.filter,tp,LOCATION_DECK,0,1,exc) end
	-- 设置当前处理的连锁的操作信息为送去墓地效果
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的Operation函数，用于执行效果
function c1050186.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家tp发送提示信息，提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 让玩家tp从卡组中选择满足filter条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c1050186.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地，原因是由效果造成
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
