--女神の聖剣－エアトス
-- 效果：
-- ①：装备怪兽的攻击力上升500。
-- ②：这张卡从场上送去墓地时，以自己场上1只「守护者·艾托斯」为对象才能发动。那只怪兽的攻击力上升除外中的怪兽数量×500。
function c55569674.initial_effect(c)
	-- （装备魔法卡的发动）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c55569674.target)
	e1:SetOperation(c55569674.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- （装备限制）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ②：这张卡从场上送去墓地时，以自己场上1只「守护者·艾托斯」为对象才能发动。那只怪兽的攻击力上升除外中的怪兽数量×500。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(55569674,0))  --"攻击上升"
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c55569674.atkcon)
	e4:SetTarget(c55569674.atktg)
	e4:SetOperation(c55569674.atkop)
	c:RegisterEffect(e4)
end
-- 装备魔法卡发动时的对象选择与发动准备
function c55569674.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在发动时，确认场上是否存在可以装备的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表示该效果的处理包含装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动后的效果处理，将此卡装备给目标怪兽
function c55569674.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断这张卡是否是从场上送去墓地
function c55569674.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤出自己场上表侧表示的「守护者·艾托斯」
function c55569674.filter(c)
	return c:IsFaceup() and c:IsCode(34022290)
end
-- 送墓效果的发动准备与对象选择
function c55569674.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c55569674.filter(chkc) end
	-- 在发动时，确认自己场上是否存在表侧表示的「守护者·艾托斯」
	if chk==0 then return Duel.IsExistingTarget(c55569674.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「守护者·艾托斯」作为效果对象
	Duel.SelectTarget(tp,c55569674.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 过滤出除外状态的表侧表示怪兽
function c55569674.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 送墓效果的处理，使目标怪兽的攻击力上升
function c55569674.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的「守护者·艾托斯」
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 计算双方除外区中表侧表示怪兽的数量
		local ct=Duel.GetMatchingGroupCount(c55569674.atkfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
		-- 那只怪兽的攻击力上升除外中的怪兽数量×500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(500*ct)
		tc:RegisterEffect(e1)
	end
end
