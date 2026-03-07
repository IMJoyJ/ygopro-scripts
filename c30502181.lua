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
	-- 这张卡从卡组被送去墓地时，可以把这张卡给自己场上存在的1只名字带有「光道」的怪兽装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c30502181.eqlimit)
	c:RegisterEffect(e3)
	-- 效果作用
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
-- 装备对象必须为名字带有「光道」的怪兽
function c30502181.eqlimit(e,c)
	return c:IsSetCard(0x38)
end
-- 过滤名字带有「光道」的表侧怪兽
function c30502181.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x38)
end
-- 选择装备对象，要求为名字带有「光道」的表侧怪兽
function c30502181.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c30502181.filter(chkc) end
	-- 判断是否满足装备条件
	if chk==0 then return Duel.IsExistingTarget(c30502181.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择装备对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一名玩家场上名字带有「光道」的表侧怪兽作为装备对象
	Duel.SelectTarget(tp,c30502181.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示将要进行装备操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作
function c30502181.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 装备效果发动条件：此卡从卡组送去墓地
function c30502181.eqcondtion(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
-- 选择装备对象，要求为己方场上名字带有「光道」的表侧怪兽
function c30502181.eqtarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c30502181.filter(chkc) end
	-- 判断己方魔法陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断己方场上是否存在名字带有「光道」的表侧怪兽
		and Duel.IsExistingTarget(c30502181.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择装备对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择己方场上名字带有「光道」的表侧怪兽作为装备对象
	Duel.SelectTarget(tp,c30502181.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，表示将要进行装备操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
