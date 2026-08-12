--グレイドル・コブラ
-- 效果：
-- ①：自己的怪兽区域的这张卡被战斗或者陷阱卡的效果破坏送去墓地的场合，以对方场上1只表侧表示怪兽为对象才能发动。这张卡当作装备卡使用给那只对方怪兽装备。
-- ②：这张卡的效果让这张卡装备中的场合，得到装备怪兽的控制权。这张卡从场上离开时装备怪兽破坏。
function c93445074.initial_effect(c)
	-- ①：自己的怪兽区域的这张卡被战斗或者陷阱卡的效果破坏送去墓地的场合，以对方场上1只表侧表示怪兽为对象才能发动。这张卡当作装备卡使用给那只对方怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c93445074.eqcon)
	e1:SetTarget(c93445074.eqtg)
	e1:SetOperation(c93445074.eqop)
	c:RegisterEffect(e1)
end
-- 判定这张卡是否在自己的怪兽区域被战斗或陷阱卡的效果破坏并送去墓地
function c93445074.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and re:IsActiveType(TYPE_TRAP)))
		and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 过滤对方场上合法的表侧表示怪兽，并对陷阱怪兽进行特殊的格子数量判定
function c93445074.eqfilter(c,tp)
	if c:IsFacedown() then return false end
	-- 若目标是陷阱怪兽，则需要判定是否有足够的魔陷区格子来容纳装备卡以及控制权转移所需的格子
	if c:IsType(TYPE_TRAPMONSTER) then return Duel.GetLocationCount(tp,LOCATION_SZONE,tp,LOCATION_REASON_CONTROL)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE,tp,0)>=2 end
	return true
end
-- 效果发动的对象选择与合法性检测
function c93445074.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c93445074.eqfilter(chkc,tp) end
	-- 检查自身魔陷区是否有可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查对方场上是否存在可以作为装备对象的表侧表示怪兽
		and Duel.IsExistingTarget(c93445074.eqfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果的对象
	Duel.SelectTarget(tp,c93445074.eqfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置操作信息，表示此效果包含将墓地的卡移出墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 限制装备卡的装备对象为所选择的怪兽
function c93445074.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 效果处理：将自身作为装备卡装备给目标怪兽，并适用控制权转移和离场破坏的效果
function c93445074.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查魔陷区是否仍有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 这张卡当作装备卡使用给那只对方怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c93445074.eqlimit)
		e1:SetLabelObject(tc)
		c:RegisterEffect(e1)
		-- ②：这张卡的效果让这张卡装备中的场合，得到装备怪兽的控制权。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_SET_CONTROL)
		e2:SetValue(tp)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 这张卡从场上离开时装备怪兽破坏。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EVENT_LEAVE_FIELD_P)
		e3:SetOperation(c93445074.checkop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
		-- 这张卡从场上离开时装备怪兽破坏。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		e4:SetCode(EVENT_LEAVE_FIELD)
		e4:SetOperation(c93445074.desop)
		e4:SetReset(RESET_EVENT+RESET_OVERLAY+RESET_TOFIELD)
		e4:SetLabelObject(e3)
		c:RegisterEffect(e4)
	end
end
-- 在装备卡准备离场时，检查其效果是否被无效，并记录状态
function c93445074.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 装备卡离场时，若未被无效，则破坏装备怪兽
function c93445074.desop(e,tp,eg,ep,ev,re,r,rp)
	e:Reset()
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetEquipTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 因效果破坏装备怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
