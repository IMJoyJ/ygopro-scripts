--重力の斧－グラール
-- 效果：
-- 装备这张卡的怪兽攻击力上升500点。只要这张卡在场上存在，对方场上的怪兽不能改变表示形式。
function c32022366.initial_effect(c)
	-- 装备这张卡的怪兽攻击力上升500点。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c32022366.target)
	e1:SetOperation(c32022366.operation)
	c:RegisterEffect(e1)
	-- 装备这张卡的怪兽攻击力上升500点。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 装备这张卡的怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 只要这张卡在场上存在，对方场上的怪兽不能改变表示形式。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e4)
end
-- 发动时的目标选择处理：检查是否指定对象（chkc），检查是否存在合法目标，若满足则提示玩家选择1只表侧表示怪兽作为装备对象，并设置装备类操作信息。
function c32022366.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动合法性检查：确认双方怪兽区存在至少1只表侧表示怪兽可作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示选择提示：“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家从双方怪兽区选择1只表侧表示怪兽作为装备对象，并将其登记为本次连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为“装备”类别，操作对象为本卡，数量1，用于连锁处理时的效果判定。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若本卡和目标怪兽都仍与该效果相关且目标怪兽仍为表侧表示，则执行装备。
function c32022366.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果处理时需要装备到的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 由发动者将本卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
	end
end
