--インスタント・ネオスペース
-- 效果：
-- 「元素英雄 新宇侠」作为融合素材的融合怪兽才能装备。这张卡装备的融合怪兽在结束阶段时可以不发动回到卡组效果。装备怪兽从场上离开的场合，可以从自己的手卡·卡组·墓地把1只「元素英雄 新宇侠」特殊召唤。
function c11913700.initial_effect(c)
	-- 为卡片注册「元素英雄 新宇侠」的卡片代码，用于后续效果判断
	aux.AddCodeList(c,89943723)
	-- 为卡片注册「元素英雄」系列编码，用于后续系列判断
	aux.AddSetNameMonsterList(c,0x3008)
	-- 「元素英雄 新宇侠」作为融合素材的融合怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c11913700.target)
	e1:SetOperation(c11913700.operation)
	c:RegisterEffect(e1)
	-- 装备对象必须为「元素英雄 新宇侠」作为融合素材的融合怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c11913700.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽从场上离开的场合，可以从自己的手卡·卡组·墓地把1只「元素英雄 新宇侠」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(42015635)
	c:RegisterEffect(e3)
	-- 当装备怪兽离开场上时，可以发动特殊召唤效果。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(11913700,0))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c11913700.spcon)
	e4:SetTarget(c11913700.sptg)
	e4:SetOperation(c11913700.spop)
	c:RegisterEffect(e4)
end
-- 装备对象限制函数，判断是否为「元素英雄 新宇侠」作为融合素材的融合怪兽。
function c11913700.eqlimit(e,c)
	-- 判断目标怪兽是否为融合怪兽且以「元素英雄 新宇侠」为融合素材。
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,89943723)
end
-- 过滤函数，用于选择可装备的目标怪兽。
function c11913700.filter(c)
	-- 筛选出场上正面表示的融合怪兽，且以「元素英雄 新宇侠」为融合素材。
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,89943723)
end
-- 装备效果的处理函数，用于选择目标怪兽。
function c11913700.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c11913700.filter(chkc) end
	-- 检查是否存在满足条件的怪兽作为装备目标。
	if chk==0 then return Duel.IsExistingTarget(c11913700.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择场上满足条件的1只怪兽作为装备目标。
	Duel.SelectTarget(tp,c11913700.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的处理信息。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备效果的执行函数。
function c11913700.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前装备效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 特殊召唤效果的发动条件函数。
function c11913700.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetPreviousEquipTarget()
	return e:GetHandler():IsReason(REASON_LOST_TARGET) and not ec:IsLocation(LOCATION_ONFIELD+LOCATION_OVERLAY)
end
-- 特殊召唤目标过滤函数，筛选「元素英雄 新宇侠」。
function c11913700.spfilter(c,e,tp)
	return c:IsCode(89943723) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标选择函数。
function c11913700.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤的条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否有满足条件的「元素英雄 新宇侠」可特殊召唤。
		and Duel.IsExistingMatchingCard(c11913700.spfilter,tp,0x13,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的处理信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- 特殊召唤效果的执行函数。
function c11913700.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤位置。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的「元素英雄 新宇侠」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的「元素英雄 新宇侠」作为特殊召唤目标。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c11913700.spfilter),tp,0x13,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「元素英雄 新宇侠」特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
