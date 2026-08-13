--体温の上昇
-- 效果：
-- 恐龙族怪兽可以装备。装备怪兽的攻击力·守备力上升300。
function c51267887.initial_effect(c)
	-- 恐龙族怪兽可以装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c51267887.target)
	e1:SetOperation(c51267887.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- 装备怪兽的攻击力·守备力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	-- 恐龙族怪兽可以装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c51267887.eqlimit)
	c:RegisterEffect(e4)
end
-- 装备限制条件：仅允许恐龙族怪兽装备此卡。
function c51267887.eqlimit(e,c)
	return c:IsRace(RACE_DINOSAUR)
end
-- 选择目标时的过滤条件：场上表侧表示且种族为恐龙的怪兽。
function c51267887.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR)
end
-- 发动时的目标选择处理：从双方场上选择1只表侧表示恐龙族怪兽作为装备对象，并登记装备操作信息。
function c51267887.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c51267887.filter(chkc) end
	-- 发动合法性检查：确认场上是否存在至少1只符合条件（表侧表示恐龙族）的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c51267887.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择要装备的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 令玩家从双方场上选择1只表侧表示恐龙族怪兽，并设为效果对象。
	Duel.SelectTarget(tp,c51267887.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息，声明将进行装备操作（CATEGORY_EQUIP），以供后续时点检测。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时的装备操作：若装备卡和对象怪兽仍与效果关联且对象仍表侧表示，则将装备卡装备给该怪兽。
function c51267887.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理阶段选定的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备卡装备给对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
