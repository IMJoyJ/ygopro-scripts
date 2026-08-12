--神聖騎士王アルトリウス
-- 效果：
-- 5星「圣骑士」怪兽×2
-- ①：这张卡超量召唤成功时，以自己墓地的「圣剑」装备魔法卡最多3种类为对象才能发动。作为对象的卡给这张卡装备。
-- ②：1回合1次，把这张卡1个超量素材取除，以这张卡以外的场上1只怪兽为对象才能发动。那只怪兽破坏。
-- ③：这张卡从场上送去墓地的场合，以自己墓地1只4星以上的「圣骑士」怪兽为对象才能发动。那只怪兽特殊召唤。
function c10613952.initial_effect(c)
	-- 添加XYZ召唤手续，使用满足「圣骑士」字段且等级为5的怪兽作为素材，需要2只怪兽进行叠放
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x107a),5,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤成功时，以自己墓地的「圣剑」装备魔法卡最多3种类为对象才能发动。作为对象的卡给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10613952,0))  --"装备"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c10613952.condition)
	e1:SetTarget(c10613952.target)
	e1:SetOperation(c10613952.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除，以这张卡以外的场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10613952,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c10613952.descost)
	e2:SetTarget(c10613952.destg)
	e2:SetOperation(c10613952.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡从场上送去墓地的场合，以自己墓地1只4星以上的「圣骑士」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10613952,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c10613952.spcon)
	e3:SetTarget(c10613952.sptg)
	e3:SetOperation(c10613952.spop)
	c:RegisterEffect(e3)
end
-- 判断此效果是否由XYZ召唤成功触发
function c10613952.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤满足「圣剑」字段且能成为装备对象的墓地卡片
function c10613952.filter(c,e,tp,ec)
	return c:IsSetCard(0x207a) and c:IsCanBeEffectTarget(e) and c:CheckUniqueOnField(tp) and c:CheckEquipTarget(ec)
end
-- 设置效果目标，选择墓地中的「圣剑」装备魔法卡
function c10613952.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c10613952.filter(chkc,e,tp,e:GetHandler()) end
	-- 检查场上是否有足够的装备区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查是否存在满足条件的墓地「圣剑」装备魔法卡
		and Duel.IsExistingMatchingCard(c10613952.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,e:GetHandler()) end
	-- 获取玩家的装备区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 获取满足条件的墓地「圣剑」装备魔法卡组
	local g=Duel.GetMatchingGroup(c10613952.filter,tp,LOCATION_GRAVE,0,nil,e,tp,e:GetHandler())
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 从满足条件的卡组中选择最多3张不同卡名的卡
	local g1=g:SelectSubGroup(tp,aux.dncheck,false,1,math.min(ft,3))
	-- 设置选择的卡片为效果对象
	Duel.SetTargetCard(g1)
	-- 设置操作信息，表示将有卡片离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g1,g1:GetCount(),0,0)
end
-- 执行装备操作
function c10613952.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家的装备区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 获取连锁中设置的目标卡片并筛选出与效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if ft<g:GetCount() then return end
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local tc=g:GetFirst()
	while tc do
		-- 将卡片装备给此卡
		Duel.Equip(tp,tc,c,true,true)
		tc=g:GetNext()
	end
	-- 完成装备过程
	Duel.EquipComplete()
end
-- 设置破坏效果的消耗
function c10613952.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置破坏效果的目标
function c10613952.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查是否存在满足条件的场上怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择场上一只怪兽作为破坏目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
	-- 设置操作信息，表示将有卡片被破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏操作
function c10613952.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设置的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断此效果是否由从场上送去墓地触发
function c10613952.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤满足「圣骑士」字段且等级不低于4的墓地怪兽
function c10613952.spfilter(c,e,tp)
	return c:IsSetCard(0x107a) and c:IsLevelAbove(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标
function c10613952.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10613952.spfilter(chkc,e,tp) end
	-- 检查场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的墓地「圣骑士」怪兽
		and Duel.IsExistingTarget(c10613952.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择一只满足条件的墓地怪兽作为特殊召唤目标
	local g=Duel.SelectTarget(tp,c10613952.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将有卡片被特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c10613952.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设置的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
