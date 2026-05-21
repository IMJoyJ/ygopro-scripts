--ワン・バイ・ワン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·场上把1只怪兽送去墓地，从自己墓地的怪兽以及除外的自己怪兽之中以送去墓地的怪兽以外的1只1星怪兽为对象才能发动。那只怪兽加入手卡。
function c91534476.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·场上把1只怪兽送去墓地，从自己墓地的怪兽以及除外的自己怪兽之中以送去墓地的怪兽以外的1只1星怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,91534476+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c91534476.cost)
	e1:SetTarget(c91534476.target)
	e1:SetOperation(c91534476.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡或场上可以作为代价送去墓地的怪兽
function c91534476.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 发动代价：从自己的手卡·场上把1只怪兽送去墓地，并记录该怪兽
function c91534476.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡或场上是否存在至少1只可以作为代价送去墓地的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c91534476.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1只自己手卡或场上的怪兽
	local g=Duel.SelectMatchingCard(tp,c91534476.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 将选择的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
-- 过滤条件：自己墓地或除外状态的1星怪兽
function c91534476.thfilter(c)
	return c:IsLevel(1) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToHand()
end
-- 效果的目标选择：以自己墓地或除外的、除送去墓地的怪兽以外的1只1星怪兽为对象
function c91534476.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c91534476.thfilter(chkc) and chkc~=e:GetLabelObject() end
	-- 检查自己墓地或除外区是否存在至少1只满足条件的1星怪兽
	if chk==0 then return Duel.IsExistingTarget(c91534476.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1只除作为代价送去墓地的怪兽以外的1星怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c91534476.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,e:GetLabelObject())
	-- 设置效果处理信息为：将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将作为对象的怪兽加入手卡
function c91534476.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
