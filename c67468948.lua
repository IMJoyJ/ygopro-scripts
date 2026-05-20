--救済のレイヤード
-- 效果：
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把反击陷阱卡发动，选除外的2只自己的天使族怪兽加入手卡。
function c67468948.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把反击陷阱卡发动，选除外的2只自己的天使族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c67468948.drop)
	c:RegisterEffect(e1)
end
-- 过滤除外区表侧表示、可以加入手牌的自己的天使族怪兽
function c67468948.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:IsAbleToHand()
end
-- 反击陷阱卡发动连锁处理结束时的效果处理，选择除外的2只自己的天使族怪兽加入手卡
function c67468948.drop(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_COUNTER) then return end
	-- 中断当前效果，使后续的加入手卡处理不与反击陷阱的发动处理视为同时进行
	Duel.BreakEffect()
	-- 获取自己除外区中满足条件的天使族怪兽
	local g=Duel.GetMatchingGroup(c67468948.filter,tp,LOCATION_REMOVED,0,nil)
	if g:GetCount()<2 then return end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local sg=g:Select(tp,2,2,nil)
	-- 将选中的怪兽因效果加入手牌
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
	-- 给对方确认加入手牌的卡片
	Duel.ConfirmCards(1-tp,sg)
end
