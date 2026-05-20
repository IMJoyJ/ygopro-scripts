--リターナブル瓶
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从自己墓地把1张陷阱卡除外才能发动。从自己墓地选原本卡名和那张卡不同的1张陷阱卡加入手卡。
function c84404797.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 这个卡名的①的效果1回合只能使用1次。①：从自己墓地把1张陷阱卡除外才能发动。从自己墓地选原本卡名和那张卡不同的1张陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,84404797)
	e1:SetCost(c84404797.cost)
	e1:SetTarget(c84404797.target)
	e1:SetOperation(c84404797.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中可以作为发动代价除外的陷阱卡，且墓地中必须存在另一张原本卡名不同的可回收陷阱卡
function c84404797.filter(c,tp)
	-- 检查该卡是否为陷阱卡、能否作为代价除外，且自己墓地中是否存在至少1张原本卡名与该卡不同且能加入手牌的陷阱卡
	return c:IsType(TYPE_TRAP) and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(c84404797.thfilter,tp,LOCATION_GRAVE,0,1,c,c:GetOriginalCodeRule())
end
-- 过滤自己墓地中原本卡名与指定卡名（除外卡）不同且能加入手牌的陷阱卡
function c84404797.thfilter(c,code)
	return c:IsType(TYPE_TRAP) and not c:IsOriginalCodeRule(code) and c:IsAbleToHand()
end
-- 效果发动的代价检查与标记函数，将Label设为100以在target中验证是否为正常发动
function c84404797.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 效果发动时的目标选择与代价支付处理函数
function c84404797.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查自己墓地是否存在满足除外代价且有对应回收目标的陷阱卡
		return Duel.IsExistingMatchingCard(c84404797.filter,tp,LOCATION_GRAVE,0,1,nil,tp)
	end
	-- 给玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张满足条件的陷阱卡作为除外代价
	local g=Duel.SelectMatchingCard(tp,c84404797.filter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	e:SetLabel(0,g:GetFirst():GetCode())
	-- 将选中的卡作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 设置效果处理信息，表示此效果会将自己墓地的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理的执行函数
function c84404797.activate(e,tp,eg,ep,ev,re,r,rp)
	local label,code=e:GetLabel()
	-- 给玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张原本卡名与除外卡不同且不受「王家之谷」影响的陷阱卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c84404797.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,code)
	if g:GetCount()>0 then
		-- 将选中的陷阱卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
