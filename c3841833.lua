--ファーニマル・ベア
-- 效果：
-- 「毛绒动物·熊」的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把手卡的这张卡送去墓地才能发动。从卡组选1张「玩具罐」在自己的魔法与陷阱区域盖放。
-- ②：把这张卡解放，以自己墓地1张「融合」为对象才能发动。那张卡加入手卡。
function c3841833.initial_effect(c)
	-- ①：把手卡的这张卡送去墓地才能发动。从卡组选1张「玩具罐」在自己的魔法与陷阱区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3841833,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,3841833)
	e1:SetCost(c3841833.cost)
	e1:SetTarget(c3841833.target)
	e1:SetOperation(c3841833.operation)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放，以自己墓地1张「融合」为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3841833,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,3841833)
	e2:SetCost(c3841833.thcost)
	e2:SetTarget(c3841833.thtg)
	e2:SetOperation(c3841833.thop)
	c:RegisterEffect(e2)
end
-- 效果发动时的费用支付处理，将自身送去墓地作为费用
function c3841833.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() and e:GetHandler():IsDiscardable() end
	-- 将自身送去墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 用于筛选卡组中可盖放的「玩具罐」卡片
function c3841833.filter(c)
	return c:IsCode(70245411) and c:IsSSetable()
end
-- 效果发动时的条件检查，确认场上是否有空置的魔法与陷阱区域，并且卡组中是否存在满足条件的「玩具罐」
function c3841833.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空置的魔法与陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在满足条件的「玩具罐」
		and Duel.IsExistingMatchingCard(c3841833.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果发动时的处理，提示选择并盖放一张「玩具罐」
function c3841833.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的「玩具罐」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选择一张「玩具罐」
	local g=Duel.SelectMatchingCard(tp,c3841833.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「玩具罐」盖放在场上
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 效果发动时的费用支付处理，将自身解放作为费用
function c3841833.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 用于筛选墓地中可加入手牌的「融合」卡片
function c3841833.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 效果发动时的条件检查与处理，选择并指定一张墓地中的「融合」卡片
function c3841833.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c3841833.thfilter(chkc) end
	-- 检查墓地中是否存在满足条件的「融合」卡片
	if chk==0 then return Duel.IsExistingTarget(c3841833.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的「融合」卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从墓地中选择一张「融合」卡片作为对象
	local g=Duel.SelectTarget(tp,c3841833.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，指定将卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果发动时的处理，将指定的「融合」卡片加入手牌
function c3841833.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
