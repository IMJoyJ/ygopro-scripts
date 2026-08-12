--聖騎士王アルトリウス
-- 效果：
-- 4星「圣骑士」怪兽×2
-- ①：这张卡超量召唤成功时，以自己墓地最多3张「圣剑」装备魔法卡为对象才能发动（同名卡最多1张）。那些卡给这张卡装备。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。选最多有自己场上的「圣剑」装备魔法卡数量的场上的魔法·陷阱卡破坏。
function c21223277.initial_effect(c)
	-- 为卡片添加超量召唤手续，需要满足条件的4星「圣骑士」怪兽叠放2只以上进行超量召唤
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x107a),4,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤成功时，以自己墓地最多3张「圣剑」装备魔法卡为对象才能发动（同名卡最多1张）。那些卡给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21223277,0))  --"装备"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c21223277.condition)
	e1:SetTarget(c21223277.target)
	e1:SetOperation(c21223277.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。选最多有自己场上的「圣剑」装备魔法卡数量的场上的魔法·陷阱卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21223277,1))  --"魔陷破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c21223277.descost)
	e2:SetTarget(c21223277.destg)
	e2:SetOperation(c21223277.desop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否为超量召唤成功
function c21223277.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤满足条件的墓地「圣剑」装备魔法卡，包括可作为效果对象、卡名唯一性检查和装备目标检查
function c21223277.filter(c,e,tp,ec)
	return c:IsSetCard(0x207a) and c:IsCanBeEffectTarget(e) and c:CheckUniqueOnField(tp) and c:CheckEquipTarget(ec)
end
-- 设置效果目标为墓地满足条件的卡，检查是否满足条件并选择装备卡
function c21223277.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c21223277.filter(chkc,e,tp,e:GetHandler()) end
	if chk==0 then
		-- 检查场上魔法陷阱区域是否还有空位
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return false end
		-- 检查场上是否存在满足条件的墓地「圣剑」装备魔法卡
		return Duel.IsExistingMatchingCard(c21223277.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,e:GetHandler())
	end
	-- 获取玩家场上可用的魔法陷阱区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 获取满足条件的墓地「圣剑」装备魔法卡组
	local g=Duel.GetMatchingGroup(c21223277.filter,tp,LOCATION_GRAVE,0,nil,e,tp,e:GetHandler())
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从满足条件的卡组中选择最多3张不重复卡名的卡
	local g1=g:SelectSubGroup(tp,aux.dncheck,false,1,math.min(ft,3))
	-- 设置选中的卡为效果对象
	Duel.SetTargetCard(g1)
	-- 设置效果操作信息，表示将从墓地装备卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g1,g1:GetCount(),0,0)
end
-- 执行装备操作，将选中的卡装备给此卡
function c21223277.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的魔法陷阱区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 获取连锁中设置的目标卡组并过滤出与效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if ft<g:GetCount() then return end
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local tc=g:GetFirst()
	while tc do
		-- 将卡装备给此卡，保持装备卡的表示形式
		Duel.Equip(tp,tc,c,true,true)
		tc=g:GetNext()
	end
	-- 完成装备过程的时点处理
	Duel.EquipComplete()
end
-- 设置效果消耗，移除1个超量素材作为代价
function c21223277.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤满足条件的场上「圣剑」装备魔法卡
function c21223277.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x207a) and c:IsType(TYPE_EQUIP) and c:IsType(TYPE_SPELL)
end
-- 过滤满足条件的魔法·陷阱卡
function c21223277.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置效果目标，检查场上是否存在「圣剑」装备魔法卡和可破坏的魔法·陷阱卡
function c21223277.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的「圣剑」装备魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c21223277.cfilter,tp,LOCATION_SZONE,0,1,nil)
		-- 检查场上是否存在可破坏的魔法·陷阱卡
		and Duel.IsExistingMatchingCard(c21223277.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有可破坏的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c21223277.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置效果操作信息，表示将破坏魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏操作，选择并破坏魔法·陷阱卡
function c21223277.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上「圣剑」装备魔法卡的数量
	local ct=Duel.GetMatchingGroupCount(c21223277.cfilter,tp,LOCATION_SZONE,0,nil)
	if ct==0 then return end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择最多场上「圣剑」装备魔法卡数量的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c21223277.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	if g:GetCount()>0 then
		-- 将选中的魔法·陷阱卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
