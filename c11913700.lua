--インスタント・ネオスペース
-- 效果：
-- 「元素英雄 新宇侠」作为融合素材的融合怪兽才能装备。这张卡装备的融合怪兽在结束阶段时可以不发动回到卡组效果。装备怪兽从场上离开的场合，可以从自己的手卡·卡组·墓地把1只「元素英雄 新宇侠」特殊召唤。
function c11913700.initial_effect(c)
	-- 向本卡注册卡名列表，使其效果文本中记载着「元素英雄 新宇侠」这一卡名，供后续相关融合素材等判定使用。
	aux.AddCodeList(c,89943723)
	-- 向本卡注册系列字段0x3008，用于识别效果文本中涉及的特定系列怪兽，使相关系列判定能够正常生效。
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
	-- 「元素英雄 新宇侠」作为融合素材的融合怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c11913700.eqlimit)
	c:RegisterEffect(e2)
	-- 这张卡装备的融合怪兽在结束阶段时可以不发动回到卡组效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(42015635)
	c:RegisterEffect(e3)
	-- 装备怪兽从场上离开的场合，可以从自己的手卡·卡组·墓地把1只「元素英雄 新宇侠」特殊召唤。
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
-- 定义装备限制判定函数：判定装备对象是否为融合怪兽，并且其融合素材包含「元素英雄 新宇侠」。
function c11913700.eqlimit(e,c)
	-- 判断c是否为融合怪兽且其融合素材包含「元素英雄 新宇侠」，返回真则允许本卡装备给c。
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,89943723)
end
-- 定义选择可装备对象的过滤函数：对象需是表侧表示的融合怪兽，并且其融合素材包含「元素英雄 新宇侠」。
function c11913700.filter(c)
	-- 返回对象是否同时满足表侧表示、融合怪兽类型、融合素材包含「元素英雄 新宇侠」这三个条件。
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,89943723)
end
-- 发动时的目标选择处理：检查场上是否存在合法装备对象，若有则让玩家选择1只符合条件的融合怪兽作为装备对象，并设置装备类操作信息。
function c11913700.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c11913700.filter(chkc) end
	-- 发动合法性检查：场上是否存在至少1只满足过滤条件的融合怪兽，存在才能发动。
	if chk==0 then return Duel.IsExistingTarget(c11913700.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出提示，要求玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家从双方怪兽区域选择1只符合条件的融合怪兽作为这张装备卡的装备对象，并使其与效果建立关联。
	Duel.SelectTarget(tp,c11913700.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本连锁的操作信息，声明此次处理包含装备分类，且操作对象为这张装备卡本身，用于后续时点与效果判定。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时的操作：若这张卡仍与该效果关联、目标怪兽仍与效果关联且为表侧表示，则将这张卡装备给目标怪兽。
function c11913700.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中第一个被选择的目标，即要装备的融合怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备魔法卡装备给目标怪兽，完成装备动作。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 离场特召的发动条件判定：这张装备卡由于失去装备对象而离场，且原装备怪兽不在场上也不在超量素材中，满足时允许发动特召效果。
function c11913700.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetPreviousEquipTarget()
	return e:GetHandler():IsReason(REASON_LOST_TARGET) and not ec:IsLocation(LOCATION_ONFIELD+LOCATION_OVERLAY)
end
-- 定义特召对象的过滤函数：检索符合条件的「元素英雄 新宇侠」，并确认它能够被当前效果特殊召唤。
function c11913700.spfilter(c,e,tp)
	return c:IsCode(89943723) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特召效果的发动前检查：我方主要怪兽区有空位，且手卡·卡组·墓地中存在可特殊召唤的「元素英雄 新宇侠」。
function c11913700.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区域是否有可用的空格，没有则无法发动特召效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡、卡组、墓地中是否存在至少1张符合特召条件的「元素英雄 新宇侠」。
		and Duel.IsExistingMatchingCard(c11913700.spfilter,tp,0x13,0,1,nil,e,tp) end
	-- 设置本连锁的操作信息，声明包含特殊召唤分类，预期从手卡·卡组·墓地中选择1只怪兽进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- 特召效果处理：选择1张符合条件的「元素英雄 新宇侠」（排除王家长眠之谷影响），以表侧表示特殊召唤到自己场上。
function c11913700.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认我方主要怪兽区是否有空位，若没有则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡、卡组、墓地中选择1张符合条件的「元素英雄 新宇侠」，并排除因王家长眠之谷效果而不能特殊召唤的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c11913700.spfilter),tp,0x13,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「元素英雄 新宇侠」以表侧表示特殊召唤到自己的主要怪兽区域。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
