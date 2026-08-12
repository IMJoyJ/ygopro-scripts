--ガガガリベンジ
-- 效果：
-- ①：以自己墓地1只「我我我」怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。这张卡从场上离开时那只怪兽破坏。
-- ②：装备怪兽变成超量素材让这张卡被送去墓地的场合发动。自己场上的全部超量怪兽的攻击力上升300。
function c90673413.initial_effect(c)
	-- ①：以自己墓地1只「我我我」怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c90673413.target)
	e1:SetOperation(c90673413.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c90673413.desop)
	c:RegisterEffect(e2)
	-- ②：装备怪兽变成超量素材让这张卡被送去墓地的场合发动。自己场上的全部超量怪兽的攻击力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(90673413,0))  --"攻击上升"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c90673413.atkcon)
	e3:SetOperation(c90673413.atkop)
	c:RegisterEffect(e3)
end
-- 过滤自己墓地中可以特殊召唤的「我我我」怪兽
function c90673413.filter(c,e,tp)
	return c:IsSetCard(0x54) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备：检查怪兽区域空位并选择自己墓地1只「我我我」怪兽作为对象
function c90673413.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c90673413.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的「我我我」怪兽
		and Duel.IsExistingTarget(c90673413.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「我我我」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c90673413.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置效果处理信息：将这张卡作为装备卡装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 限制装备卡只能装备给这张卡的效果所特殊召唤的怪兽
function c90673413.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果①的处理：特殊召唤目标怪兽并装备这张卡，同时设置装备限制
function c90673413.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤，若特殊召唤失败则结束处理
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		-- 将这张卡装备给特殊召唤的怪兽
		Duel.Equip(tp,c,tc)
		-- 把这张卡装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c90673413.eqlimit)
		c:RegisterEffect(e1)
	end
end
-- 装备魔法卡离场时，破坏装备的怪兽
function c90673413.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetEquipTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 因效果破坏装备怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 检查发动条件：装备怪兽成为超量素材导致这张卡失去装备对象而送去墓地
function c90673413.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and tc:IsLocation(LOCATION_OVERLAY)
end
-- 过滤自己场上表侧表示的超量怪兽
function c90673413.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 效果②的处理：使自己场上所有的超量怪兽攻击力上升300
function c90673413.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的超量怪兽
	local g=Duel.GetMatchingGroup(c90673413.atkfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部超量怪兽的攻击力上升300。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
