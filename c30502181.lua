--ライトロード・レイピア
-- 效果：
-- 名字带有「光道」的怪兽才能装备。装备怪兽的攻击力上升700。这张卡从卡组被送去墓地时，可以把这张卡给自己场上存在的1只名字带有「光道」的怪兽装备。
function c30502181.initial_effect(c)
	-- 装备魔法卡的效果注册（名字带有「光道」的怪兽才能装备）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c30502181.target)
	e1:SetOperation(c30502181.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升700
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(700)
	c:RegisterEffect(e2)
	-- 装备限制效果注册（名字带有「光道」的怪兽才能装备）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c30502181.eqlimit)
	c:RegisterEffect(e3)
	-- 从卡组被送去墓地时的装备诱发效果注册
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
-- 装备限制函数：检查装备对象是否为光道（0x38）
function c30502181.eqlimit(e,c)
	return c:IsSetCard(0x38)
end
-- 筛选函数：返回场上表侧表示的光道怪兽
function c30502181.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x38)
end
-- 装备魔法卡发动时的目标选择处理
function c30502181.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c30502181.filter(chkc) end
	-- 检查是否存在可作为装备对象的光道怪兽
	if chk==0 then return Duel.IsExistingTarget(c30502181.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择1只场上的光道怪兽作为装备对象
	Duel.SelectTarget(tp,c30502181.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，指定装备操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡的处理操作
function c30502181.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前选择的目标卡
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备，将这张卡装备给选中的怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 诱发条件：检查此卡是否从卡组被送去墓地
function c30502181.eqcondtion(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
-- 从墓地装备时的目标选择处理
function c30502181.eqtarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c30502181.filter(chkc) end
	-- 检查玩家魔陷区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在光道怪兽
		and Duel.IsExistingTarget(c30502181.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择1只自己场上的光道怪兽
	Duel.SelectTarget(tp,c30502181.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，指定装备操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
