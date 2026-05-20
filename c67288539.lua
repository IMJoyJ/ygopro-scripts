--ヴァレルコード・ドラゴン
-- 效果：
-- 效果怪兽2只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：连接怪兽所连接区的这张卡不会被效果破坏。
-- ②：怪兽3只为素材作连接召唤的这张卡在和对方怪兽进行战斗的伤害步骤开始时才能发动。场上的怪兽全部破坏。
-- ③：把墓地的这张卡除外才能发动。选场上1只攻击力3000以上的暗属性怪兽除外，从自己的额外卡组·墓地选1只「拓扑」怪兽特殊召唤。
function c67288539.initial_effect(c)
	-- 设置连接召唤的手续，需要2只以上的效果怪兽作为素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	c:EnableReviveLimit()
	-- ①：连接怪兽所连接区的这张卡不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c67288539.immcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：怪兽3只为素材作连接召唤的这张卡在和对方怪兽进行战斗的伤害步骤开始时才能发动。场上的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c67288539.regcon)
	e2:SetOperation(c67288539.regop)
	c:RegisterEffect(e2)
	-- ②：怪兽3只为素材作连接召唤的这张卡在和对方怪兽进行战斗的伤害步骤开始时才能发动。场上的怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(c67288539.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ②：怪兽3只为素材作连接召唤的这张卡在和对方怪兽进行战斗的伤害步骤开始时才能发动。场上的怪兽全部破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(67288539,1))
	e4:SetCategory(CATEGORY_HANDES+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetCountLimit(1,67288539)
	e4:SetCondition(c67288539.descon)
	e4:SetTarget(c67288539.destg)
	e4:SetOperation(c67288539.desop)
	c:RegisterEffect(e4)
	-- ③：把墓地的这张卡除外才能发动。选场上1只攻击力3000以上的暗属性怪兽除外，从自己的额外卡组·墓地选1只「拓扑」怪兽特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(67288539,2))
	e5:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,67288540)
	-- 把墓地的这张卡除外作为发动的代价。
	e5:SetCost(aux.bfgcost)
	e5:SetTarget(c67288539.rmtg)
	e5:SetOperation(c67288539.rmop)
	c:RegisterEffect(e5)
end
-- 检查这张卡是否处于连接怪兽所连接的区域。
function c67288539.immcon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取己方场上所有连接怪兽所连接的怪兽区域的卡片组。
	local lg1=Duel.GetLinkedGroup(tp,1,1)
	-- 获取对方场上所有连接怪兽所连接的怪兽区域的卡片组。
	local lg2=Duel.GetLinkedGroup(1-tp,1,1)
	lg1:Merge(lg2)
	return lg1 and lg1:IsContains(e:GetHandler())
end
-- 检查这张卡是否是通过连接召唤特殊召唤，且素材数量为3。
function c67288539.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel()==1
end
-- 给这张卡注册一个表示“使用3只怪兽作为素材进行连接召唤”的标记（Flag）。
function c67288539.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(67288539,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(67288539,0))  --"怪兽3只为素材作连接召唤"
end
-- 检查连接召唤时使用的素材数量，如果刚好是3只，则将标签值设为1，否则设为0。
function c67288539.valcheck(e,c)
	local g=c:GetMaterial()
	if g:GetCount()==3 then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 检查是否满足破坏效果的发动条件：具有3素材召唤标记，且正在与对方怪兽进行战斗。
function c67288539.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身是否带有3素材召唤标记，且当前战斗存在攻击对象（即与对方怪兽进行战斗）。
	return e:GetHandler():GetFlagEffect(67288539)~=0 and Duel.GetAttackTarget()~=nil
end
-- 破坏效果的发动准备与目标确认，检查场上是否存在怪兽，并设置破坏的操作信息。
function c67288539.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果的步骤，检查双方场上是否存在至少1只怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取双方场上的所有怪兽。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁信息，表示该效果的处理为破坏场上的所有怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的实际处理，获取场上所有怪兽并将其全部破坏。
function c67288539.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上的所有怪兽。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 因效果将获取到的所有怪兽破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 过滤场上表侧表示、攻击力3000以上且为暗属性的怪兽，并检查其是否能被除外以及后续是否能特殊召唤「拓扑」怪兽。
function c67288539.rmfilter(c,e,tp,check)
	return c:IsFaceup() and c:IsAttackAbove(3000) and c:IsAttribute(ATTRIBUTE_DARK)
		-- 检查该怪兽是否不免疫此效果，且在将其除外腾出格子后，自己的额外卡组或墓地是否存在可特殊召唤的「拓扑」怪兽。
		and (check or not c:IsImmuneToEffect(e) and Duel.IsExistingMatchingCard(c67288539.spfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp,c))
end
-- 过滤自己额外卡组或墓地中可以特殊召唤的「拓扑」怪兽，并根据其所在位置检查是否有可用的怪兽区域。
function c67288539.spfilter(c,e,tp,tc)
	if not (c:IsSetCard(0x16e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		-- 检查在将作为除外目标的怪兽送去除外区后，额外怪兽区域或连接端是否有空位来特殊召唤额外卡组的怪兽。
		return Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
	else
		-- 检查在将作为除外目标的怪兽送去除外区后，主怪兽区域是否有空位来特殊召唤墓地的怪兽。
		return Duel.GetMZoneCount(tp,c)>0
	end
end
-- 除外并特殊召唤效果的发动准备，检查是否存在可除外的目标，并设置除外与特殊召唤的操作信息。
function c67288539.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果的步骤，检查场上是否存在满足条件的暗属性怪兽作为除外目标。
	if chk==0 then return Duel.IsExistingMatchingCard(c67288539.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	-- 获取场上所有满足除外条件且不免疫效果的暗属性怪兽。
	local g=Duel.GetMatchingGroup(c67288539.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp,false)
	-- 设置连锁信息，表示该效果会除外1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置连锁信息，表示该效果会从额外卡组或墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
-- 除外并特殊召唤效果的实际处理，选择场上1只满足条件的怪兽除外，并特殊召唤1只「拓扑」怪兽。
function c67288539.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择1只满足除外条件且不免疫效果的怪兽。
	local tg=Duel.SelectMatchingCard(tp,c67288539.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp,false)
	local tc=tg:GetFirst()
	if not tc then
		-- 提示玩家选择要除外的卡片（用于处理免疫效果怪兽的备用选择逻辑）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家选择1只满足除外条件但可能免疫效果的怪兽（用于处理即使免疫也必须选择的特殊情况）。
		local tg2=Duel.SelectMatchingCard(tp,c67288539.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp,true)
		if #tg2>0 then
			-- 将选中的怪兽表侧表示除外（即使其可能免疫效果而导致除外失败）。
			Duel.Remove(tg2,POS_FACEUP,REASON_EFFECT)
		end
		return
	end
	-- 显式地在场上框选并展示被选为除外目标的怪兽。
	Duel.HintSelection(tg)
	-- 将选中的怪兽表侧表示除外，并检查是否成功除外。
	if Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从自己的额外卡组或墓地中选择1只满足条件的「拓扑」怪兽（受王家长眠之谷影响）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c67288539.spfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp,nil)
		if #g>0 then
			-- 将选中的「拓扑」怪兽在己方场上表侧表示特殊召唤。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
