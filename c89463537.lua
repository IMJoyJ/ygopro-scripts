--ユニコールの影霊衣
-- 效果：
-- 「影灵衣」仪式魔法卡降临
-- 这张卡不用仪式召唤不能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：把这张卡从手卡丢弃，以「尤尼科之影灵衣」以外的自己墓地1张「影灵衣」卡为对象才能发动。那张卡加入手卡。
-- ②：只要这张卡在怪兽区域存在，从额外卡组特殊召唤的表侧表示怪兽的效果无效化。
function c89463537.initial_effect(c)
	c:EnableReviveLimit()
	-- 「影灵衣」仪式魔法卡降临。这张卡不用仪式召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制为只能通过仪式召唤特殊召唤
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：把这张卡从手卡丢弃，以「尤尼科之影灵衣」以外的自己墓地1张「影灵衣」卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89463537,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,89463537)
	e2:SetCost(c89463537.cost)
	e2:SetTarget(c89463537.target)
	e2:SetOperation(c89463537.operation)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，从额外卡组特殊召唤的表侧表示怪兽的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c89463537.distg)
	c:RegisterEffect(e3)
end
-- ①的效果的发动代价（Cost）判定与执行
function c89463537.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 作为发动代价，将自身从手牌丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤自己墓地中「尤尼科之影灵衣」以外的「影灵衣」卡片的条件
function c89463537.filter(c)
	return c:IsSetCard(0xb4) and not c:IsCode(89463537) and c:IsAbleToHand()
end
-- ①的效果的发动准备（Target）：选择墓地中符合条件的卡片作为对象，并设置操作信息
function c89463537.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c89463537.filter(chkc) end
	-- 在发动阶段，判定自己墓地是否存在符合条件的「影灵衣」卡片
	if chk==0 then return Duel.IsExistingTarget(c89463537.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张符合条件的「影灵衣」卡片作为效果对象
	local g=Duel.SelectTarget(tp,c89463537.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息为“将选中的卡片加入手牌”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①的效果的处理（Operation）：将作为对象的卡片加入手牌
function c89463537.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤出从额外卡组特殊召唤的怪兽
function c89463537.distg(e,c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
