--No.21 氷結のレディ・ジャスティス
-- 效果：
-- 6星怪兽×2
-- 这张卡也能从自己场上的5阶超量怪兽把1个超量素材取除，在那只超量怪兽上面重叠来超量召唤。
-- ①：这张卡的攻击力上升这张卡的超量素材数量×1000。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。对方场上的守备表示怪兽全部破坏。
function c57707471.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,nil,6,2,c57707471.ovfilter,aux.Stringid(57707471,0),2,c57707471.xyzop)  --"是否在5阶的超量怪兽上面重叠超量召唤？"
	-- ①：这张卡的攻击力上升这张卡的超量素材数量×1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c57707471.atkval)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。对方场上的守备表示怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(57707471,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c57707471.descost)
	e3:SetTarget(c57707471.destg)
	e3:SetOperation(c57707471.desop)
	c:RegisterEffect(e3)
end
-- 设置该卡为「No.」怪兽，其编号为21
aux.xyz_number[57707471]=21
-- 过滤用于重叠超量召唤的怪兽：自己场上表侧表示的5阶超量怪兽
function c57707471.ovfilter(c)
	return c:IsFaceup() and c:IsXyzType(TYPE_XYZ) and c:IsRank(5)
end
-- 重叠超量召唤时的操作：取除作为超量素材的怪兽的1个超量素材
function c57707471.xyzop(e,tp,chk,mc)
	if chk==0 then return mc:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	mc:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 计算并返回攻击力上升值：自身超量素材数量×1000
function c57707471.atkval(e,c)
	return c:GetOverlayCount()*1000
end
-- 破坏效果的代价：取除这张卡的1个超量素材
function c57707471.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤对方场上满足破坏条件的怪兽：守备表示怪兽
function c57707471.desfilter(c)
	return c:IsDefensePos()
end
-- 破坏效果的发动准备：检查对方场上是否存在守备表示怪兽，并设置破坏的操作信息
function c57707471.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查对方场上是否存在至少1只守备表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c57707471.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有的守备表示怪兽
	local g=Duel.GetMatchingGroup(c57707471.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置效果处理的操作信息：破坏对方场上所有的守备表示怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的处理：获取并破坏对方场上所有的守备表示怪兽
function c57707471.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上所有的守备表示怪兽
	local g=Duel.GetMatchingGroup(c57707471.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 因效果破坏获取到的怪兽组
	Duel.Destroy(g,REASON_EFFECT)
end
