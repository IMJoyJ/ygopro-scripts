--電子光虫－ライノセバス
-- 效果：
-- 昆虫族·光属性7星怪兽×2只以上
-- 这张卡也能从自己场上的5·6阶的昆虫族超量怪兽把2个超量素材取除，在那只超量怪兽上面重叠来超量召唤。
-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。对方场上的守备力最高的怪兽破坏。这个效果在对方回合也能发动。
function c85004150.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,c85004150.mfilter,7,2,c85004150.ovfilter,aux.Stringid(85004150,0),99,c85004150.xyzop)  --"是否在在超量怪兽上面重叠来超量召唤？"
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。对方场上的守备力最高的怪兽破坏。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85004150,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c85004150.descost)
	e2:SetTarget(c85004150.destg)
	e2:SetOperation(c85004150.desop)
	c:RegisterEffect(e2)
	-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
end
-- 过滤自身重叠超量召唤所需的、自己场上的5·6阶昆虫族超量怪兽
function c85004150.ovfilter(c)
	return c:IsFaceup() and c:IsXyzType(TYPE_XYZ) and c:IsRank(5,6) and c:IsRace(RACE_INSECT)
end
-- 过滤正规超量召唤所需的昆虫族·光属性怪兽
function c85004150.mfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 重叠超量召唤时的操作：从作为素材的超量怪兽上取除2个超量素材
function c85004150.xyzop(e,tp,chk,mc)
	if chk==0 then return mc:CheckRemoveOverlayCard(tp,2,REASON_COST) end
	mc:RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 过滤对方场上表侧表示且有守备力数值的怪兽
function c85004150.desfilter(c)
	return c:IsFaceup() and c:IsDefenseAbove(0)
end
-- 破坏效果的Cost：取除这张卡的1个超量素材
function c85004150.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 破坏效果的发动准备：检查对方场上是否存在符合条件的怪兽，并确定守备力最高的怪兽作为破坏对象
function c85004150.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只表侧表示且有守备力的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c85004150.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧表示且有守备力的怪兽
	local g=Duel.GetMatchingGroup(c85004150.desfilter,tp,0,LOCATION_MZONE,nil)
	local dg=g:GetMaxGroup(Card.GetDefense)
	-- 设置效果处理信息：预定破坏对方场上守备力最高的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 破坏效果的执行：找出对方场上守备力最高的怪兽并将其破坏
function c85004150.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，获取对方场上所有表侧表示且有守备力的怪兽
	local g=Duel.GetMatchingGroup(c85004150.desfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local dg=g:GetMaxGroup(Card.GetDefense)
		-- 将守备力最高的怪兽破坏
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
