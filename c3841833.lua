--ファーニマル・ベア
-- 效果：
-- 「毛绒动物·熊」的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把手卡的这张卡送去墓地才能发动。从卡组选1张「玩具罐」在自己的魔法与陷阱区域盖放。
-- ②：把这张卡解放，以自己墓地1张「融合」为对象才能发动。那张卡加入手卡。
function c3841833.initial_effect(c)
	-- 「毛绒动物·熊」的①②的效果1回合只能有1次使用其中任意1个。①：把手卡的这张卡送去墓地才能发动。从卡组选1张「玩具罐」在自己的魔法与陷阱区域盖放。
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
	-- 「毛绒动物·熊」的①②的效果1回合只能有1次使用其中任意1个。②：把这张卡解放，以自己墓地1张「融合」为对象才能发动。那张卡加入手卡。
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
-- 效果①的发动代价处理函数：检测手牌中的这张卡是否满足作为代价送去墓地的条件，并实际将其从手牌送去墓地。
function c3841833.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() and e:GetHandler():IsDiscardable() end
	-- 将这张卡从手牌送去墓地，作为发动效果①的代价（REASON_COST）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 定义检索过滤器：卡名必须为「玩具罐」（70245411），且可以被盖放到魔法与陷阱区域。
function c3841833.filter(c)
	return c:IsCode(70245411) and c:IsSSetable()
end
-- 效果①的发动条件检测：检查自己魔陷区是否有空位，以及卡组中是否存在符合条件的「玩具罐」。
function c3841833.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己魔法与陷阱区域是否有可用空格。若没有空格，则效果不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检测卡组中是否存在至少1张满足filter条件的「玩具罐」。由于不取对象，用IsExistingMatchingCard检查。
		and Duel.IsExistingMatchingCard(c3841833.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果①的处理函数：玩家从卡组选择1张「玩具罐」，将其盖放到自己的魔法与陷阱区域。
function c3841833.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家选择要盖放的卡片（HINTMSG_SET）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从自己卡组选择1张符合filter条件的「玩具罐」（不取对象）。
	local g=Duel.SelectMatchingCard(tp,c3841833.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「玩具罐」盖放到自己的魔法与陷阱区域。
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 效果②的代价处理函数：检查这张卡是否可以被解放，并实际将其解放作为代价。
function c3841833.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放这张卡，作为发动效果②的代价（REASON_COST）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义对象筛选器：卡名必须为「融合」（24094653），且可以加入手牌。
function c3841833.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 效果②的目标指定与条件检测：选择自己墓地1张「融合」作为对象，并设置操作信息。
function c3841833.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c3841833.thfilter(chkc) end
	-- 检测自己墓地是否存在至少1张符合条件的「融合」可作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c3841833.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，提示玩家选择要加入手牌的卡片（HINTMSG_ATOHAND）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张符合条件的「融合」作为效果对象（取对象效果）。
	local g=Duel.SelectTarget(tp,c3841833.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，声明本次连锁的效果将把目标卡加入持有者手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的处理函数：取得效果对象，若对象仍与效果关联，则将其加入手牌。
function c3841833.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁效果处理时的第一张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手牌，移动原因为效果（REASON_EFFECT）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
