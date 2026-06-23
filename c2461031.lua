--甲虫装機 グルフ
-- 效果：
-- 1回合1次，可以从自己的手卡·墓地把1只名字带有「甲虫装机」的怪兽当作装备卡使用给这张卡装备。这张卡当作装备卡使用而装备中的场合，装备怪兽的等级上升2星，攻击力·守备力上升这张卡的各自数值。此外，可以把当作装备卡使用而装备中的这张卡送去墓地，选择自己场上1只怪兽，等级上升最多2星。
function c2461031.initial_effect(c)
	-- 1回合1次，可以从自己的手卡·墓地把1只名字带有「甲虫装机」的怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(2461031,0))  --"装备"
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c2461031.eqtg)
	e1:SetOperation(c2461031.eqop)
	c:RegisterEffect(e1)
	-- 这张卡当作装备卡使用而装备中的场合，装备怪兽的攻击力上升这张卡的攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 这张卡当作装备卡使用而装备中的场合，装备怪兽的守备力上升这张卡的守备力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(100)
	c:RegisterEffect(e3)
	-- 这张卡当作装备卡使用而装备中的场合，装备怪兽的等级上升2星。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_LEVEL)
	e4:SetValue(2)
	c:RegisterEffect(e4)
	-- 此外，可以把当作装备卡使用而装备中的这张卡送去墓地，选择自己场上1只怪兽，等级上升最多2星。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(2461031,1))  --"等级上升"
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCost(c2461031.lvcost)
	e5:SetTarget(c2461031.lvtg)
	e5:SetOperation(c2461031.lvop)
	c:RegisterEffect(e5)
end
-- 过滤函数，用于筛选名字带有「甲虫装机」的怪兽卡。
function c2461031.filter(c)
	return c:IsSetCard(0x56) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 效果处理时的判断条件，检查玩家场上是否有空余的魔法陷阱区域，并且手卡或墓地是否存在满足条件的怪兽。
function c2461031.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空余的魔法陷阱区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查玩家手卡或墓地是否存在满足条件的怪兽。
		and Duel.IsExistingMatchingCard(c2461031.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	-- 设置连锁操作信息，表示将要从手卡或墓地送入墓地的卡。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 装备效果的处理函数，用于选择并装备满足条件的怪兽。
function c2461031.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查玩家场上是否有空余的魔法陷阱区域。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c2461031.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 尝试将选中的怪兽装备给此卡。
		if not Duel.Equip(tp,tc,c) then return end
		-- 设置装备对象限制效果，确保只有此卡能装备该怪兽。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c2461031.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备对象限制的判断函数，确保只能装备给此卡。
function c2461031.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 等级上升效果的费用支付函数，将此卡送去墓地作为费用。
function c2461031.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送去墓地作为费用。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 等级上升效果的目标筛选函数，用于筛选场上表侧表示的怪兽。
function c2461031.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(0)
end
-- 等级上升效果的处理函数，检查是否有满足条件的目标怪兽。
function c2461031.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c2461031.lvfilter(chkc) end
	if chk==0 then return e:GetHandler():GetEquipTarget()
		-- 检查玩家场上是否存在满足条件的怪兽。
		and Duel.IsExistingTarget(c2461031.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要提升等级的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上满足条件的怪兽作为目标。
	Duel.SelectTarget(tp,c2461031.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 等级上升效果的处理函数，选择提升1星或2星。
function c2461031.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 选择提升1星或2星。
		local opt=Duel.SelectOption(tp,aux.Stringid(2461031,2),aux.Stringid(2461031,3))  --"等级上升１星/等级上升２星"
		-- 设置目标怪兽等级上升的效果。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(opt+1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
