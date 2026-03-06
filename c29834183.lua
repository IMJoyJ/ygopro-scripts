--グレイドル・イーグル
-- 效果：
-- ①：自己的怪兽区域的这张卡被战斗或者怪兽的效果破坏送去墓地的场合，以对方场上1只表侧表示怪兽为对象才能发动。这张卡当作装备卡使用给那只对方怪兽装备。
-- ②：这张卡的效果让这张卡装备中的场合，得到装备怪兽的控制权。这张卡从场上离开时装备怪兽破坏。
function c29834183.initial_effect(c)
	-- 创建一个诱发效果，当此卡因战斗或怪兽效果破坏送入墓地时发动，效果分类为装备和离开墓地
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c29834183.eqcon)
	e1:SetTarget(c29834183.eqtg)
	e1:SetOperation(c29834183.eqop)
	c:RegisterEffect(e1)
end
-- 此卡被战斗或者怪兽的效果破坏送去墓地的场合
function c29834183.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and re:IsActiveType(TYPE_MONSTER)))
		and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 判断目标怪兽是否为表侧表示且满足装备条件
function c29834183.eqfilter(c,tp)
	if c:IsFacedown() then return false end
	-- 若目标怪兽为陷阱怪兽，则需满足其所在区域有足够空位
	if c:IsType(TYPE_TRAPMONSTER) then return Duel.GetLocationCount(tp,LOCATION_SZONE,tp,LOCATION_REASON_CONTROL)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE,tp,0)>=2 end
	return true
end
-- 设置效果目标，选择对方场上一只表侧表示怪兽作为装备对象
function c29834183.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c29834183.eqfilter(chkc,tp) end
	-- 判断己方魔法陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 确认对方场上是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c29834183.eqfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上一只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,c29834183.eqfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置效果操作信息，记录将要离开墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 装备对象限制效果，确保只能装备给指定怪兽
function c29834183.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 执行装备操作，将此卡装备给目标怪兽
function c29834183.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若己方魔法陷阱区域无空位则不执行装备
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- 将此卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 设置装备对象限制，确保此卡只能装备给指定怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c29834183.eqlimit)
		e1:SetLabelObject(tc)
		c:RegisterEffect(e1)
		-- 装备后获得目标怪兽的控制权
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_SET_CONTROL)
		e2:SetValue(tp)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 当此卡离开场上时触发检查，用于判断是否执行破坏效果
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EVENT_LEAVE_FIELD_P)
		e3:SetOperation(c29834183.checkop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
		-- 当此卡离开场上时触发破坏效果，若未被无效则破坏装备怪兽
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		e4:SetCode(EVENT_LEAVE_FIELD)
		e4:SetOperation(c29834183.desop)
		e4:SetReset(RESET_EVENT+RESET_OVERLAY+RESET_TOFIELD)
		e4:SetLabelObject(e3)
		c:RegisterEffect(e4)
	end
end
-- 检查此卡是否被无效，若无效则标记为1，否则为0
function c29834183.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 执行破坏效果，若未被无效则破坏装备怪兽
function c29834183.desop(e,tp,eg,ep,ev,re,r,rp)
	e:Reset()
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetEquipTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 将装备怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
