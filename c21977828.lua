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
	-- 此外，给怪兽装备的这张卡被送去墓地的场合，可以从自己墓地选择1只名字带有「甲虫装机」的怪兽特殊召唤。
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
-- 检索满足条件的场上怪兽（名字带有「甲虫装机」且表侧表示）
function c21977828.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x56)
end
-- 判断是否满足装备条件（场上是否有满足条件的怪兽，且装备区有空位）
function c21977828.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c21977828.filter(chkc) end
	-- 判断装备区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断场上是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c21977828.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽进行装备
	Duel.SelectTarget(tp,c21977828.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 执行装备操作，将装备卡装备给目标怪兽
function c21977828.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断装备是否失败（装备区无空位、目标怪兽里侧表示、目标怪兽不属于自己或不相关）
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not tc:IsControler(tp) then
		-- 将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 执行装备操作
	Duel.Equip(tp,c,tc)
	-- 设置装备对象限制，确保该装备卡只能装备给特定怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c21977828.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 限制该装备卡只能装备给特定怪兽
function c21977828.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 判断装备卡是否从魔法区域被送去墓地且其装备对象存在且不是因失去装备对象而送去墓地
function c21977828.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousEquipTarget() and not c:IsReason(REASON_LOST_TARGET)
end
-- 检索满足条件的墓地怪兽（名字带有「甲虫装机」且可以特殊召唤）
function c21977828.spfilter(c,e,tp)
	return c:IsSetCard(0x56) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤条件（墓地是否有满足条件的怪兽，且场上怪兽区有空位）
function c21977828.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21977828.spfilter(chkc,e,tp) end
	-- 判断场上怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c21977828.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽进行特殊召唤
	local g=Duel.SelectTarget(tp,c21977828.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c21977828.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
