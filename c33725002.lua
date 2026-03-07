--Vサラマンダー
-- 效果：
-- 这张卡召唤成功时，可以选择自己墓地1只名字带有「希望皇 霍普」的怪兽特殊召唤。自己的主要阶段时，场上的这只怪兽可以给自己的「混沌No.39 希望皇 霍普雷V」装备。这张卡装备中的场合，1回合1次，把装备怪兽1个超量素材取除才能发动。装备怪兽的效果无效，对方场上的怪兽全部破坏，给与对方基本分那个数量×1000的数值的伤害。
function c33725002.initial_effect(c)
	-- 这张卡召唤成功时，可以选择自己墓地1只名字带有「希望皇 霍普」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33725002,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c33725002.sptg)
	e1:SetOperation(c33725002.spop)
	c:RegisterEffect(e1)
	-- 自己的主要阶段时，场上的这只怪兽可以给自己的「混沌No.39 希望皇 霍普雷V」装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33725002,1))  --"装备"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c33725002.eqtg)
	e2:SetOperation(c33725002.eqop)
	c:RegisterEffect(e2)
	-- 这张卡装备中的场合，1回合1次，把装备怪兽1个超量素材取除才能发动。装备怪兽的效果无效，对方场上的怪兽全部破坏，给与对方基本分那个数量×1000的数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33725002,2))  --"破坏并伤害"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c33725002.descost)
	e3:SetTarget(c33725002.destg)
	e3:SetOperation(c33725002.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断墓地中的怪兽是否为「希望皇 霍普」系列且可以特殊召唤。
function c33725002.spfilter(c,e,tp)
	return c:IsSetCard(0x107f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标选择函数，用于选择墓地中的「希望皇 霍普」怪兽。
function c33725002.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c33725002.spfilter(chkc,e,tp) end
	-- 判断玩家场上是否有足够的怪兽区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家墓地是否存在满足条件的「希望皇 霍普」怪兽。
		and Duel.IsExistingTarget(c33725002.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为特殊召唤目标。
	local g=Duel.SelectTarget(tp,c33725002.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤效果的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作，将目标怪兽特殊召唤到场上的怪兽区域。
function c33725002.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上的怪兽区域。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断场上是否为「混沌No.39 希望皇 霍普雷V」且处于表侧表示。
function c33725002.eqfilter(c)
	return c:IsFaceup() and c:IsCode(66970002)
end
-- 设置装备效果的目标选择函数，用于选择场上的「混沌No.39 希望皇 霍普雷V」。
function c33725002.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c33725002.eqfilter(chkc) end
	-- 判断玩家场上是否有足够的魔法陷阱区域用于装备。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断玩家场上是否存在满足条件的「混沌No.39 希望皇 霍普雷V」。
		and Duel.IsExistingTarget(c33725002.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的场上怪兽作为装备目标。
	Duel.SelectTarget(tp,c33725002.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 执行装备操作，将装备卡装备给目标怪兽。
function c33725002.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断装备条件是否满足，包括区域是否足够、目标是否为己方、是否为表侧表示等。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 若装备条件不满足，则将装备卡送入墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 执行装备操作，将装备卡装备给目标怪兽。
	Duel.Equip(tp,c,tc)
	-- 设置装备限制效果，确保装备卡只能装备给特定怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c33725002.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 装备限制效果的判断函数，确保装备卡只能装备给指定目标。
function c33725002.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 装备效果的费用支付函数，消耗装备怪兽的一个超量素材。
function c33725002.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetEquipTarget() and c:GetEquipTarget():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:GetEquipTarget():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置破坏并伤害效果的目标选择函数，用于确定要破坏的对方怪兽。
function c33725002.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否存在对方场上的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上的所有怪兽作为破坏目标。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置破坏效果的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置伤害效果的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*1000)
end
-- 执行破坏并伤害效果，使装备怪兽效果无效，破坏对方场上所有怪兽并造成伤害。
function c33725002.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if ec then
		-- 使装备怪兽的效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e1)
		-- 使装备怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e2)
	end
	-- 获取对方场上的所有怪兽作为破坏目标。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 将对方场上的所有怪兽破坏。
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 then
		-- 给与对方基本分相应数量×1000的伤害。
		Duel.Damage(1-tp,ct*1000,REASON_EFFECT)
	end
end
