--氷水艇エーギロカシス
-- 效果：
-- 这个卡名的①③的效果1回合只能有1次使用其中任意1个。
-- ①：自己·对方回合，这张卡在手卡·墓地存在的场合，以自己场上1只「冰水」怪兽为对象才能发动。这张卡当作装备卡使用给那只自己怪兽装备。
-- ②：有这张卡装备的怪兽的攻击力·守备力上升除外状态的怪兽数量×400。
-- ③：这张卡装备中的场合才能发动。这张卡特殊召唤。
function c1295442.initial_effect(c)
	-- ①：自己·对方回合，这张卡在手卡·墓地存在的场合，以自己场上1只「冰水」怪兽为对象才能发动。这张卡当作装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,1295442)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c1295442.eqtg)
	e1:SetOperation(c1295442.eqop)
	c:RegisterEffect(e1)
	-- ②：有这张卡装备的怪兽的攻击力·守备力上升除外状态的怪兽数量×400。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c1295442.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ③：这张卡装备中的场合才能发动。这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,1295442)
	e4:SetCondition(c1295442.spcon)
	e4:SetTarget(c1295442.sptg)
	e4:SetOperation(c1295442.spop)
	c:RegisterEffect(e4)
end
-- 判定怪兽是否为表侧表示且为「冰水」字段怪兽，作为①效果可选对象的过滤条件。
function c1295442.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x16c)
end
-- ①效果的发动条件与对象选择判定：检查魔陷区空位、同名卡限制和场上是否存在符合条件的「冰水」怪兽；连锁处理时验证对象是否仍合法。
function c1295442.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c1295442.filter(chkc) end
	-- 效果发动时检查自己魔陷区是否有空位，以保证装备卡能够放置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and e:GetHandler():CheckUniqueOnField(tp)
		-- 检查自己场上是否存在表侧表示的「冰水」怪兽可以作为装备对象。
		and Duel.IsExistingTarget(c1295442.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向发动玩家显示“请选择要装备的卡”的选择消息提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己场上选择1只表侧表示的「冰水」怪兽作为效果对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,c1295442.filter,tp,LOCATION_MZONE,0,1,1,nil)
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		-- 若此卡在墓地发动，设置操作信息为涉及墓地移动，使相关卡（如王家长眠之谷）能正确响应。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end
-- ①效果处理：若此卡仍与效果关联则尝试装备；若无魔陷区空位/对象失控/对象里侧/对象不关联/同名卡限制不满足，则将此卡送去墓地；否则装备给对象并附加仅限该对象的装备限制。
function c1295442.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 取得发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 综合判定装备是否仍可行：魔陷区空位、对象控制权、表示形式、效果关联和同名卡限制。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 装备条件不满足时，将这张卡以效果原因送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 尝试将此卡作为装备卡装备给对象怪兽；若装备失败则结束处理。
	if not Duel.Equip(tp,c,tc) then return end
	-- ①中“这张卡当作装备卡使用给那只自己怪兽装备”：通过装备限制效果，使这张卡只能装备给发动时选择的那只怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c1295442.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 判定某怪兽是否为这张装备卡发动时选择的对象，只有该怪兽能装备这张卡。
function c1295442.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 过滤除外区表侧表示的怪兽，用于计算攻击力/守备力上升数值。
function c1295442.atkfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
-- 计算攻击力上升值：除外状态的表侧怪兽数量×400。
function c1295442.atkval(e,c)
	-- 统计双方除外区表侧表示怪兽总数，并乘以400作为攻击力/守备力上升数值。
	return Duel.GetMatchingGroupCount(c1295442.atkfilter,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)*400
end
-- ③效果的发动条件：这张卡处于装备魔法卡状态，即存在装备对象怪兽。
function c1295442.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end
-- ③效果发动时检查自己主要怪兽区是否有空位，以及此卡是否可以特殊召唤。
function c1295442.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空位，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为特殊召唤，使相关检测能识别此效果将进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③效果处理：若此卡仍与效果关联，则将其特殊召唤到自己场上表侧表示。
function c1295442.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡从魔陷区特殊召唤到自己场上（表侧攻击表示）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
