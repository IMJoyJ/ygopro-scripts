--ライトロード・レイピア
-- 效果：
-- 名字带有「光道」的怪兽才能装备。装备怪兽的攻击力上升700。这张卡从卡组被送去墓地时，可以把这张卡给自己场上存在的1只名字带有「光道」的怪兽装备。
function c30502181.initial_effect(c)
	-- 名字带有「光道」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c30502181.target)
	e1:SetOperation(c30502181.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升700。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(700)
	c:RegisterEffect(e2)
	-- 名字带有「光道」的怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c30502181.eqlimit)
	c:RegisterEffect(e3)
	-- 这张卡从卡组被送去墓地时，可以把这张卡给自己场上存在的1只名字带有「光道」的怪兽装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetDescription(aux.Stringid(30502181,0))  --"装备"
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c30502181.eqcondtion)
	e4:SetTarget(c30502181.eqtarget)
	e4:SetOperation(c30502181.operation)
	c:RegisterEffect(e4)
end
-- 装备限制函数：判断怪兽是否为名字带有「光道」的怪兽，只有满足条件才能装备这张卡。
function c30502181.eqlimit(e,c)
	return c:IsSetCard(0x38)
end
-- 对象过滤函数：判断怪兽是否表侧表示且为名字带有「光道」的怪兽，用于选择可装备对象。
function c30502181.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x38)
end
-- 发动时的目标处理：确认存在合法装备对象后，让玩家选择1只表侧表示的光道怪兽作为装备对象，并设置本次操作为装备。
function c30502181.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c30502181.filter(chkc) end
	-- 发动合法性检查：检查场上是否存在至少1只表侧表示且名字带有「光道」的怪兽可作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(c30502181.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择要装备的卡”的提示，用于选择装备对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择1只自己或对方场上的表侧表示光道怪兽作为这张装备卡的对象。
	Duel.SelectTarget(tp,c30502181.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次效果处理将进行装备，对象为这张卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时的操作：取得装备对象，若这张卡和对象仍与效果关联且对象表侧表示，则将这张卡装备给该怪兽。
function c30502181.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这张卡发动效果时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 把这张卡装备给选择的对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 诱发条件：这张卡从卡组被送去墓地时才能发动。
function c30502181.eqcondtion(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
-- 诱发效果的发动时处理：确认魔陷区有空位且自己场上有表侧表示光道怪兽，然后选择1只作为装备对象。
function c30502181.eqtarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c30502181.filter(chkc) end
	-- 发动合法性检查：自己的魔陷区需要有可用空位，才能装备这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 且自己场上存在至少1只表侧表示且名字带有「光道」的怪兽可作为装备对象。
		and Duel.IsExistingTarget(c30502181.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择要装备的卡”的提示，用于选择装备对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择自己场上的1只表侧表示光道怪兽作为装备对象。
	Duel.SelectTarget(tp,c30502181.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本次效果处理将进行装备，对象为这张卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
