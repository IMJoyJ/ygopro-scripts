--D・コード
-- 效果：
-- 名字带有「变形斗士」的怪兽才能装备。每次装备怪兽的表示形式改变，场上存在的1张魔法或者陷阱卡破坏。
function c70423794.initial_effect(c)
	-- 名字带有「变形斗士」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c70423794.target)
	e1:SetOperation(c70423794.operation)
	c:RegisterEffect(e1)
	-- 每次装备怪兽的表示形式改变，场上存在的1张魔法或者陷阱卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetDescription(aux.Stringid(70423794,0))  --"1张魔法或者陷阱卡破坏"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c70423794.descon)
	e2:SetTarget(c70423794.destg)
	e2:SetOperation(c70423794.desop)
	c:RegisterEffect(e2)
	-- 名字带有「变形斗士」的怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c70423794.eqlimit)
	c:RegisterEffect(e3)
end
-- 装备限制：只能装备给名字带有「变形斗士」的怪兽
function c70423794.eqlimit(e,c)
	return c:IsSetCard(0x26)
end
-- 过滤条件：场上表侧表示的名字带有「变形斗士」的怪兽
function c70423794.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x26)
end
-- 装备魔法卡发动时的效果处理（选择装备对象）
function c70423794.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c70423794.filter(chkc) end
	-- 检查场上是否存在可作为装备对象的、表侧表示的名字带有「变形斗士」的怪兽
	if chk==0 then return Duel.IsExistingTarget(c70423794.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的名字带有「变形斗士」的怪兽作为装备对象
	Duel.SelectTarget(tp,c70423794.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将自身装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功时的效果处理（执行装备）
function c70423794.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将自身作为装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 效果发动条件：装备怪兽的表示形式发生改变
function c70423794.descon(e,tp,eg,ep,ev,re,r,rp)
	local tg=e:GetHandler():GetEquipTarget()
	return tg and eg:IsContains(tg)
end
-- 过滤条件：魔法或陷阱卡
function c70423794.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的发动准备（选择破坏对象）
function c70423794.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c70423794.desfilter(chkc) end
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法或陷阱卡作为破坏对象
	local g=Duel.SelectTarget(tp,c70423794.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的实际处理
function c70423794.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为破坏对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 破坏目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
