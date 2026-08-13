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
-- 筛选「我我我魔术师」：表侧表示、卡号26082117、等级不低于1且与「我我我少女」当前等级不同的怪兽。
function c3606728.lvfilter(c,lv)
	return c:IsFaceup() and c:IsCode(26082117) and not c:IsLevel(lv) and c:IsLevelAbove(1)
end
-- ①效果的目标选择处理：检查是否存在合法对象，并让玩家选择自己场上1只「我我我魔术师」作为对象。
function c3606728.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c3606728.lvfilter(chkc,e:GetHandler():GetLevel()) end
	-- 发动合法性检查：确认自己场上存在至少1只满足条件的「我我我魔术师」可供选择。
	if chk==0 then return Duel.IsExistingTarget(c3606728.lvfilter,tp,LOCATION_MZONE,0,1,nil,e:GetHandler():GetLevel()) end
	-- 向玩家显示“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上1只符合条件的「我我我魔术师」作为效果对象。
	Duel.SelectTarget(tp,c3606728.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,e:GetHandler():GetLevel())
end
-- ①效果处理：若这张卡和目标怪兽都仍关联且表侧表示，则将这张卡的等级变为目标怪兽的当前等级。
function c3606728.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得已经选择的目标「我我我魔术师」。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这张卡的等级变成和那只怪兽相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 筛选素材中不属于「我我我」系列的卡，用于判断素材是否全部为「我我我」怪兽。
function c3606728.ffilter(c)
	return not c:IsSetCard(0x54)
end
-- ②效果触发条件：这张卡作为超量召唤的素材，且所用素材全部为「我我我」怪兽（包含这张卡）。
function c3606728.efcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetReasonCard()
	return not ec:GetMaterial():IsExists(c3606728.ffilter,1,nil) and r==REASON_XYZ
end
-- ②效果处理：将『超量召唤成功时以对方场上1只特殊召唤怪兽为对象，使其攻击力变成0』的效果赋予该超量召唤怪兽；若该怪兽不是效果怪兽，则同时让其变成效果怪兽。
function c3606728.efop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方展示「我我我少女」的卡片动画，提示效果的适用。
	Duel.Hint(HINT_CARD,0,3606728)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这张卡超量召唤时，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽的攻击力变成0。
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
		-- ②：只用包含这张卡的场上的「我我我」怪兽为素材作超量召唤的怪兽得到以下效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 判断该怪兽是否以超量召唤的方式成功出场（召唤类型为超量召唤）。
function c3606728.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 筛选符合条件的对象：对方场上的表侧表示怪兽，且是通过特殊召唤出场的怪兽。
function c3606728.atkfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- ③效果的目标选择处理：检查是否存在合法对象，并让玩家选择对方场上1只特殊召唤的怪兽。
function c3606728.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c3606728.atkfilter(chkc) end
	-- 发动合法性检查：确认对方场上存在至少1只表侧表示且特殊召唤的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c3606728.atkfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择对方场上1只符合条件的特殊召唤怪兽作为效果对象。
	Duel.SelectTarget(tp,c3606728.atkfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- ③效果处理：将对象怪兽的攻击力变成0，持续到离场等重置条件。
function c3606728.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得已经选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
