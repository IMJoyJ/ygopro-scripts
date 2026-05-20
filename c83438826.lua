--聖剣アロンダイト
-- 效果：
-- 战士族怪兽才能装备。这个卡名的③的效果1回合只能使用1次。
-- ①：「圣剑 阿隆戴特」在自己场上只能有1张表侧表示存在。
-- ②：1回合1次，以对方场上盖放的1张卡为对象才能发动。装备怪兽的攻击力下降500，那张盖放的对方的卡破坏。
-- ③：场上的表侧表示的这张卡被破坏送去墓地的场合，以自己场上1只战士族「圣骑士」怪兽为对象才能发动。那只自己怪兽把这张卡装备。
function c83438826.initial_effect(c)
	c:SetUniqueOnField(1,0,83438826)
	-- 战士族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c83438826.target)
	e1:SetOperation(c83438826.operation)
	c:RegisterEffect(e1)
	-- 战士族怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c83438826.eqlimit)
	c:RegisterEffect(e3)
	-- ②：1回合1次，以对方场上盖放的1张卡为对象才能发动。装备怪兽的攻击力下降500，那张盖放的对方的卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(83438826,0))  --"魔陷破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c83438826.destg)
	e4:SetOperation(c83438826.desop)
	c:RegisterEffect(e4)
	-- ③：场上的表侧表示的这张卡被破坏送去墓地的场合，以自己场上1只战士族「圣骑士」怪兽为对象才能发动。那只自己怪兽把这张卡装备。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(83438826,1))  --"装备"
	e5:SetCategory(CATEGORY_EQUIP)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,83438826)
	e5:SetCondition(c83438826.eqcon)
	e5:SetTarget(c83438826.eqtg)
	e5:SetOperation(c83438826.operation2)
	c:RegisterEffect(e5)
end
-- 装备限制：只能装备于战士族怪兽
function c83438826.eqlimit(e,c)
	return c:IsRace(RACE_WARRIOR)
end
-- 过滤条件：场上表侧表示的战士族怪兽
function c83438826.eqfilter1(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 装备魔法卡发动时的对象选择与效果处理准备
function c83438826.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c83438826.eqfilter1(chkc) end
	-- 检查场上是否存在可以装备的表侧表示战士族怪兽
	if chk==0 then return Duel.IsExistingTarget(c83438826.eqfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只表侧表示的战士族怪兽作为装备对象
	Duel.SelectTarget(tp,c83438826.eqfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功后的装备处理
function c83438826.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() and c:CheckUniqueOnField(tp) then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 过滤条件：里侧表示的卡
function c83438826.desfilter(c)
	return c:IsFacedown()
end
-- 破坏效果的发动准备与对象选择
function c83438826.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c83438826.desfilter(chkc) end
	local eq=e:GetHandler():GetEquipTarget()
	if chk==0 then return eq and eq:IsAttackAbove(500)
		-- 检查对方场上是否存在里侧表示的卡
		and Duel.IsExistingTarget(c83438826.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张里侧表示的卡作为破坏对象
	local g=Duel.SelectTarget(tp,c83438826.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的处理：降低装备怪兽攻击力并破坏目标卡
function c83438826.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为破坏对象的卡
	local tc=Duel.GetFirstTarget()
	local eq=c:GetEquipTarget()
	if not c:IsRelateToEffect(e) or eq:IsImmuneToEffect(e) or not eq:IsAttackAbove(500) then return end
	-- 装备怪兽的攻击力下降500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	eq:RegisterEffect(e1)
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and tc:IsFacedown() then
		-- 破坏作为对象的对方里侧表示的卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 触发条件：场上表侧表示的这张卡被破坏送去墓地
function c83438826.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_DESTROY) and c:CheckUniqueOnField(tp)
end
-- 过滤条件：自己场上表侧表示的战士族「圣骑士」怪兽
function c83438826.eqfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x107a) and c:IsRace(RACE_WARRIOR)
end
-- 墓地诱发效果的发动准备与对象选择
function c83438826.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c83438826.eqfilter2(chkc) end
	-- 检查此卡是否仍存在于墓地且自己魔陷区有空位
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在可以装备的战士族「圣骑士」怪兽
		and Duel.IsExistingTarget(c83438826.eqfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只战士族「圣骑士」怪兽作为装备对象
	Duel.SelectTarget(tp,c83438826.eqfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置效果处理信息为将此卡移出墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 墓地诱发效果的处理：将此卡作为装备卡装备给目标怪兽
function c83438826.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为装备对象的「圣骑士」怪兽
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup()
		and tc:IsControler(tp) and c83438826.eqlimit(nil,tc) and c:CheckUniqueOnField(tp) then
		-- 将墓地的这张卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
