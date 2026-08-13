--紫水晶
-- 效果：
-- 不死族才能装备。1只装备怪兽的攻击力和守备力上升300。
function c15052462.initial_effect(c)
	-- 不死族才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c15052462.target)
	e1:SetOperation(c15052462.operation)
	c:RegisterEffect(e1)
	-- 1只装备怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- 1只装备怪兽的守备力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	-- 不死族才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c15052462.eqlimit)
	c:RegisterEffect(e4)
end
-- 装备限制判定：只有不死族怪兽才能作为本卡的装备对象。
function c15052462.eqlimit(e,c)
	return c:IsRace(RACE_ZOMBIE)
end
-- 筛选条件：怪兽必须是表侧表示且种族为不死族。
function c15052462.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
-- 发动时的目标选择处理：检查是否有合法对象，提示玩家从双方场上选择1只表侧表示不死族怪兽，并设为效果对象，同时记录装备操作信息。
function c15052462.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c15052462.filter(chkc) end
	-- 发动条件检查：若场上不存在表侧表示的不死族怪兽，则不能发动此卡。
	if chk==0 then return Duel.IsExistingTarget(c15052462.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操控者显示选择装备对象的提示消息，提示内容为“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从己方或对方场上选择1只表侧表示且为不死族的怪兽作为本卡装备的对象（同时登记为连锁对象）。
	Duel.SelectTarget(tp,c15052462.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：效果处理时以本卡自身为对象进行装备分类处理，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：取出装备对象，确认本卡和对象仍与效果相关联且对象仍为表侧表示，满足条件则将本卡装备给该怪兽。
function c15052462.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将本卡作为装备卡装备给对象怪兽（装备成功时装备魔法效果开始适用）。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
