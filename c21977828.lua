--甲虫装機 ギガウィービル
-- 效果：
-- 这张卡可以从手卡当作装备卡使用给自己场上的名字带有「甲虫装机」的怪兽装备。这张卡当作装备卡使用而装备中的场合，装备怪兽的原本守备力变成2600。此外，给怪兽装备的这张卡被送去墓地的场合，可以从自己墓地选择1只名字带有「甲虫装机」的怪兽特殊召唤。「甲虫装机 吉咖象鼻虫」的这个效果1回合只能使用1次。
function c21977828.initial_effect(c)
	-- 这张卡可以从手卡当作装备卡使用给自己场上的名字带有「甲虫装机」的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21977828,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(c21977828.eqtg)
	e1:SetOperation(c21977828.eqop)
	c:RegisterEffect(e1)
	-- 这张卡当作装备卡使用而装备中的场合，装备怪兽的原本守备力变成2600。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	e2:SetValue(2600)
	c:RegisterEffect(e2)
	-- 此外，给怪兽装备的这张卡被送去墓地的场合，可以从自己墓地选择1只名字带有「甲虫装机」的怪兽特殊召唤。「甲虫装机 吉咖象鼻虫」的这个效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21977828,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,21977828)
	e3:SetCondition(c21977828.spcon)
	e3:SetTarget(c21977828.sptg)
	e3:SetOperation(c21977828.spop)
	c:RegisterEffect(e3)
end
-- 用于选择装备目标的过滤条件：对象必须为表侧表示且卡名含有「甲虫装机」。
function c21977828.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x56)
end
-- 装备效果的发动判定与目标选择：要求自己魔陷区有空位，且场上存在表侧表示的「甲虫装机」怪兽；若处于选择对象阶段，则验证所选卡是否合法。
function c21977828.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c21977828.filter(chkc) end
	-- 检查自己的魔陷区是否存在空位，以决定是否满足从手卡装备的条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查场上是否存在至少1只表侧表示且卡名含有「甲虫装机」的怪兽，作为可装备目标。
		and Duel.IsExistingTarget(c21977828.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发出选择提示，要求选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从自己场上选择1只符合条件的「甲虫装机」怪兽作为装备对象，并设为效果对象。
	Duel.SelectTarget(tp,c21977828.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 发动处理：确认本卡在手牌仍与效果关联后，取得装备对象；若魔陷区无空位或对象不合法，则将本卡送去墓地，否则执行装备并附加装备对象限制。
function c21977828.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 取得效果对象（即选择的装备目标怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 判定装备是否可继续：若魔陷区无空位、目标变成里侧表示、目标与效果失去关联或目标不在自己场上，则装备失败。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not tc:IsControler(tp) then
		-- 因装备条件不满足，将这张卡从手牌送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给选择的怪兽。
	Duel.Equip(tp,c,tc)
	-- 给自己场上的名字带有「甲虫装机」的怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c21977828.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 装备限制判定：只有与记录的对象相同的那只怪兽才能装备这张卡。
function c21977828.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 特殊召唤的触发条件：这张卡作为装备卡从魔陷区被送去墓地，且不是由于失去装备对象（如装备怪兽离场）而送入墓地的场合。
function c21977828.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousEquipTarget() and not c:IsReason(REASON_LOST_TARGET)
end
-- 特殊召唤对象的过滤条件：墓地中卡名含有「甲虫装机」且能够被特殊召唤的怪兽。
function c21977828.spfilter(c,e,tp)
	return c:IsSetCard(0x56) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动判定与目标选择：要求自己主要怪兽区有空位，且墓地存在符合条件的「甲虫装机」怪兽；若选择对象，验证其合法。
function c21977828.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21977828.spfilter(chkc,e,tp) end
	-- 检查自己的主要怪兽区是否有空位，以决定能否特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1只符合条件的「甲虫装机」怪兽作为特殊召唤候选。
		and Duel.IsExistingTarget(c21977828.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发出选择提示，要求选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的「甲虫装机」怪兽作为特殊召唤对象。
	local g=Duel.SelectTarget(tp,c21977828.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，告知系统本效果将进行特殊召唤，并指定对象与数量。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤处理：取得效果对象，若对象仍与效果关联，则将其以表侧表示特殊召唤到自己场上。
function c21977828.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得特殊召唤对象（墓地中选择的怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上（无召唤条件/苏生限制检查）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
