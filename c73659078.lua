--スノーダスト・ジャイアント
-- 效果：
-- 水属性4星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除才能发动。手卡的水属性怪兽任意数量给对方观看，给人观看的数量的冰指示物给场上表侧表示存在的怪兽放置。只要这张卡在场上表侧表示存在，水属性以外的场上的怪兽的攻击力下降场上的冰指示物数量×200的数值。
function c73659078.initial_effect(c)
	-- 设置XYZ召唤手续：水属性4星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),4,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除才能发动。手卡的水属性怪兽任意数量给对方观看，给人观看的数量的冰指示物给场上表侧表示存在的怪兽放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73659078,0))  --"放置指示物"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c73659078.cost)
	e1:SetTarget(c73659078.target)
	e1:SetOperation(c73659078.operation)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上表侧表示存在，水属性以外的场上的怪兽的攻击力下降场上的冰指示物数量×200的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c73659078.atktg)
	e2:SetValue(c73659078.atkval)
	c:RegisterEffect(e2)
end
-- 过滤手卡中未公开的水属性怪兽
function c73659078.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and not c:IsPublic()
end
-- 检查并取除这张卡的1个超量素材作为发动的代价
function c73659078.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检查手卡中是否存在水属性怪兽，以及场上是否存在可以放置冰指示物的怪兽
function c73659078.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张未公开的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c73659078.cfilter,tp,LOCATION_HAND,0,1,nil)
		-- 检查场上是否存在至少1只可以放置冰指示物的怪兽
		and Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x1015,1) end
end
-- 效果处理：让玩家选择手卡任意数量的水属性怪兽给对方观看，并在场上怪兽上放置对应数量的冰指示物
function c73659078.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有可以放置冰指示物的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,0x1015,1)
	if g:GetCount()==0 then return end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择手卡中任意数量的水属性怪兽
	local cg=Duel.SelectMatchingCard(tp,c73659078.cfilter,tp,LOCATION_HAND,0,1,99,nil)
	-- 将选中的怪兽给对方玩家确认
	Duel.ConfirmCards(1-tp,cg)
	-- 洗切手牌
	Duel.ShuffleHand(tp)
	local ct=cg:GetCount()
	for i=1,ct do
		-- 提示玩家选择要放置指示物的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		tc:AddCounter(0x1015,1)
	end
end
-- 过滤水属性以外的场上怪兽作为攻击力下降的目标
function c73659078.atktg(e,c)
	return c:IsNonAttribute(ATTRIBUTE_WATER)
end
-- 计算攻击力下降的数值
function c73659078.atkval(e,c)
	-- 获取场上冰指示物的总数并乘以-200作为攻击力改变量
	return Duel.GetCounter(0,1,1,0x1015)*-200
end
