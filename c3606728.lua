--ガガガガール
-- 效果：
-- ①：以自己场上1只「我我我魔术师」为对象才能发动。这张卡的等级变成和那只怪兽相同。
-- ②：只用包含这张卡的场上的「我我我」怪兽为素材作超量召唤的怪兽得到以下效果。
-- ●这张卡超量召唤时，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽的攻击力变成0。
function c3606728.initial_effect(c)
	-- ①：以自己场上1只「我我我魔术师」为对象才能发动。这张卡的等级变成和那只怪兽相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3606728,0))  --"等级变化"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c3606728.lvtg)
	e1:SetOperation(c3606728.lvop)
	c:RegisterEffect(e1)
	-- ②：只用包含这张卡的场上的「我我我」怪兽为素材作超量召唤的怪兽得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c3606728.efcon)
	e2:SetOperation(c3606728.efop)
	c:RegisterEffect(e2)
end
-- 筛选满足条件的「我我我魔术师」怪兽（等级不同且等级大于等于1）
function c3606728.lvfilter(c,lv)
	return c:IsFaceup() and c:IsCode(26082117) and not c:IsLevel(lv) and c:IsLevelAbove(1)
end
-- 设置效果目标为满足条件的「我我我魔术师」怪兽
function c3606728.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c3606728.lvfilter(chkc,e:GetHandler():GetLevel()) end
	-- 检查场上是否存在满足条件的「我我我魔术师」怪兽
	if chk==0 then return Duel.IsExistingTarget(c3606728.lvfilter,tp,LOCATION_MZONE,0,1,nil,e:GetHandler():GetLevel()) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的「我我我魔术师」怪兽作为效果对象
	Duel.SelectTarget(tp,c3606728.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,e:GetHandler():GetLevel())
end
-- 处理等级变化效果，将自身等级设为对象怪兽的等级
function c3606728.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将自身等级设置为对象怪兽的等级
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 筛选非「我我我」系列的怪兽
function c3606728.ffilter(c)
	return not c:IsSetCard(0x54)
end
-- 判断是否为超量召唤且素材中不含非「我我我」系列怪兽
function c3606728.efcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetReasonCard()
	return not ec:GetMaterial():IsExists(c3606728.ffilter,1,nil) and r==REASON_XYZ
end
-- 设置超量召唤成功时触发的效果，使对方特殊召唤的怪兽攻击力变为0
function c3606728.efop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送卡片发动动画提示
	Duel.Hint(HINT_CARD,0,3606728)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 设置诱发效果，当超量召唤成功时发动，选择对方场上一只特殊召唤的怪兽使其攻击力变为0
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(3606728,1))  --"攻击变成0"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c3606728.atkcon)
	e1:SetTarget(c3606728.atktg)
	e1:SetOperation(c3606728.atkop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- 若目标怪兽不具有效果怪兽类型，则为其添加效果怪兽类型
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 判断是否为超量召唤
function c3606728.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 筛选对方场上特殊召唤的表侧表示怪兽
function c3606728.atkfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 设置效果目标为对方场上一只特殊召唤的表侧表示怪兽
function c3606728.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c3606728.atkfilter(chkc) end
	-- 检查对方场上是否存在满足条件的特殊召唤怪兽
	if chk==0 then return Duel.IsExistingTarget(c3606728.atkfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上一只特殊召唤的表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c3606728.atkfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 处理攻击力变为0的效果
function c3606728.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽的攻击力设置为0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
