--使い捨て学習装置
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：装备怪兽的攻击力上升自己墓地的怪兽数量×200。
-- ②：这张卡从场上送去墓地的回合的结束阶段才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
function c42149850.initial_effect(c)
	-- ①：装备怪兽的攻击力上升自己墓地的怪兽数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c42149850.target)
	e1:SetOperation(c42149850.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的回合的结束阶段才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c42149850.atkval)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c42149850.regcon)
	e3:SetOperation(c42149850.regop)
	c:RegisterEffect(e3)
	-- ②：这张卡从场上送去墓地的回合的结束阶段才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(42149850,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCategory(CATEGORY_SSET)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,42149850)
	e4:SetCondition(c42149850.setcon)
	e4:SetTarget(c42149850.settg)
	e4:SetOperation(c42149850.setop)
	c:RegisterEffect(e4)
	-- ①：装备怪兽的攻击力上升自己墓地的怪兽数量×200。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_EQUIP_LIMIT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
-- 选择1只对方场上表侧表示的怪兽作为装备对象。
function c42149850.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查是否满足选择装备对象的条件。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只对方场上表侧表示的怪兽作为装备对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示将要进行装备操作。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 将装备卡装备给选择的怪兽。
function c42149850.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 计算装备怪兽攻击力上升值。
function c42149850.atkval(e,c)
	-- 计算自己墓地怪兽数量并乘以200作为攻击力上升值。
	return Duel.GetMatchingGroupCount(Card.IsType,e:GetHandler():GetControler(),LOCATION_GRAVE,0,nil,TYPE_MONSTER)*200
end
-- 判断此卡是否从场上送去墓地。
function c42149850.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 为该卡注册一个标记，表示其已进入墓地。
function c42149850.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(42149850,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 判断此卡是否已进入墓地。
function c42149850.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(42149850)>0
end
-- 检查此卡是否可以进行盖放操作。
function c42149850.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置效果处理信息，表示将要进行盖放操作。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 将此卡在自己场上盖放。
function c42149850.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 尝试将此卡在自己场上盖放。
		if Duel.SSet(tp,c)~=0 then
			-- 将此卡从场上离开时移至除外区。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1,true)
		end
	end
end
