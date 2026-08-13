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
	-- 这张卡当作装备卡使用而装备中的场合，装备怪兽的攻击力上升这张卡的攻击力数值
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 这张卡当作装备卡使用而装备中的场合，装备怪兽的守备力上升这张卡的守备力数值
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(100)
	c:RegisterEffect(e3)
	-- 这张卡当作装备卡使用而装备中的场合，装备怪兽的等级上升2星
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
-- 定义可选择为装备卡的怪兽条件：名字带有「甲虫装机」的怪兽且未被禁止
function c2461031.filter(c)
	return c:IsSetCard(0x56) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 起动效果的发动条件：自己魔陷区有空位，且手卡·墓地存在至少1只满足条件的「甲虫装机」怪兽
function c2461031.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔陷区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查手卡·墓地中是否存在至少1只符合条件的「甲虫装机」怪兽
		and Duel.IsExistingMatchingCard(c2461031.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	-- 设置操作信息，标明可能涉及从墓地离开（配合王家长眠之谷等效果检测）
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果处理：若魔陷区无空位或自身不在场/不关联则终止；从手卡·墓地选择符合条件的「甲虫装机」怪兽装备给自身，并给装备卡设置只能装备给这张卡的限制
function c2461031.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理前再确认魔陷区仍有空位
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 向玩家提示选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择手卡·墓地中1只符合条件的「甲虫装机」怪兽（已规避王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c2461031.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 执行装备操作，若装备失败则终止后续处理
		if not Duel.Equip(tp,tc,c) then return end
		-- 当作装备卡使用给这张卡装备
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c2461031.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制判定：装备卡的持有者（即原装备怪兽）必须为这张卡
function c2461031.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 代价：检查自身能否作为代价送去墓地，然后将其送去墓地
function c2461031.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将装备中的这张卡作为代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 定义可选择对象条件：自己场上的表侧表示怪兽
function c2461031.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(0)
end
-- 取对象效果的目标判定：自身必须装备中，且自己场上存在可选择的表侧表示怪兽；并校验选择的目标
function c2461031.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c2461031.lvfilter(chkc) end
	if chk==0 then return e:GetHandler():GetEquipTarget()
		-- 检查自己场上是否存在至少1只符合条件的表侧表示怪兽
		and Duel.IsExistingTarget(c2461031.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上选择1只表侧表示怪兽作为对象
	Duel.SelectTarget(tp,c2461031.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：取得对象，若对象仍关联且表侧表示，则让玩家选择等级上升1星或2星，并赋予对应等级上升效果
function c2461031.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 让玩家选择等级上升1星或2星
		local opt=Duel.SelectOption(tp,aux.Stringid(2461031,2),aux.Stringid(2461031,3))  --"等级上升１星/等级上升２星"
		-- 等级上升最多2星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(opt+1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
