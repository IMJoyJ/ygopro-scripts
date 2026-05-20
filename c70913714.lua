--古神ハストール
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡从怪兽区域送去墓地的场合，以对方场上1只表侧表示怪兽为对象才能发动。这张卡当作装备卡使用给那只怪兽装备。装备怪兽不能攻击，效果无效化。
-- ②：用这张卡的效果给对方怪兽装备的这张卡从场上离开的场合发动。得到这张卡装备过的对方怪兽的控制权。
function c70913714.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡从怪兽区域送去墓地的场合，以对方场上1只表侧表示怪兽为对象才能发动。这张卡当作装备卡使用给那只怪兽装备。装备怪兽不能攻击，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70913714,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c70913714.eqcon)
	e1:SetTarget(c70913714.eqtg)
	e1:SetOperation(c70913714.eqop)
	c:RegisterEffect(e1)
end
-- 检查这张卡是否从怪兽区域送去墓地
function c70913714.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
-- 效果①的发动检测与对象选择
function c70913714.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查自己魔陷区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查对方场上是否存在表侧表示怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
		and e:GetHandler():IsRelateToEffect(e) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上1只表侧表示怪兽作为对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：此卡从墓地离开
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 限制装备卡只能装备给作为效果对象的怪兽
function c70913714.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果①的处理：将自身作为装备卡装备，并使装备怪兽效果无效、不能攻击，且注册自身离场时夺取控制权的效果
function c70913714.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若自己魔陷区没有空位，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将自身作为装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 这张卡当作装备卡使用给那只怪兽装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c70913714.eqlimit)
		c:RegisterEffect(e1)
		-- 效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_CANNOT_ATTACK)
		c:RegisterEffect(e3)
		-- ②：用这张卡的效果给对方怪兽装备的这张卡从场上离开的场合发动。得到这张卡装备过的对方怪兽的控制权。
		local e4=Effect.CreateEffect(c)
		e4:SetDescription(aux.Stringid(70913714,1))
		e4:SetCategory(CATEGORY_CONTROL)
		e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e4:SetCode(EVENT_LEAVE_FIELD)
		e4:SetCondition(c70913714.ctcon)
		e4:SetTarget(c70913714.cttg)
		e4:SetOperation(c70913714.ctop)
		e4:SetReset(RESET_EVENT+RESET_OVERLAY+RESET_TOFIELD)
		c:RegisterEffect(e4)
	end
end
-- 检查离场原因是否不是因为装备对象消失
function c70913714.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_LOST_TARGET)
end
-- 效果②的发动检测与对象设置
function c70913714.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ec=e:GetHandler():GetPreviousEquipTarget()
	if ec:IsLocation(LOCATION_MZONE) and ec:IsControlerCanBeChanged() then
		-- 将此前装备的怪兽设为当前效果的对象
		Duel.SetTargetCard(ec)
		-- 设置操作信息：得到该怪兽的控制权
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,ec,1,0,0)
	end
end
-- 效果②的处理：得到此前装备的对方怪兽的控制权
function c70913714.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此前装备的对方怪兽
	local ec=Duel.GetFirstTarget()
	if ec and ec:IsRelateToEffect(e) then
		-- 得到该怪兽的控制权
		Duel.GetControl(ec,tp)
	end
	e:Reset()
end
