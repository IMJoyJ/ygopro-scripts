--ゴゴゴアリステラ＆デクシア
-- 效果：
-- ①：只要这张卡和这张卡以外的「隆隆隆」怪兽在怪兽区域存在，对方不能选择「隆隆隆」怪兽作为攻击对象，也不能作为效果的对象。
-- ②：只用包含这张卡的「隆隆隆」怪兽为素材的超量怪兽得到以下效果。
-- ●这次超量召唤成功时，以对方场上1只表侧攻击表示怪兽为对象才能发动。那只怪兽变成守备表示并把守备力变成0。
function c91718579.initial_effect(c)
	-- ①：只要这张卡和这张卡以外的「隆隆隆」怪兽在怪兽区域存在，对方不能选择「隆隆隆」怪兽作为攻击对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(c91718579.tgcon)
	e1:SetValue(c91718579.atlimit)
	c:RegisterEffect(e1)
	-- 也不能作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置不能成为效果对象的影响对象为「隆隆隆」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x59))
	e2:SetCondition(c91718579.tgcon)
	-- 设置不能成为对方的卡的效果对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ②：只用包含这张卡的「隆隆隆」怪兽为素材的超量怪兽得到以下效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(c91718579.effcon)
	e3:SetOperation(c91718579.effop)
	c:RegisterEffect(e3)
end
-- 过滤场上表侧表示的「隆隆隆」怪兽
function c91718579.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x59)
end
-- 检查场上是否存在这张卡以外的「隆隆隆」怪兽的条件函数
function c91718579.tgcon(e)
	-- 检查场上是否存在除自身以外的表侧表示「隆隆隆」怪兽
	return Duel.IsExistingMatchingCard(c91718579.cfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
end
-- 限制对方不能选择表侧表示的「隆隆隆」怪兽作为攻击对象
function c91718579.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x59)
end
-- 检查是否作为超量素材，且超量素材全部为「隆隆隆」怪兽
function c91718579.effcon(e,tp,eg,ep,ev,re,r,rp)
	local mg=e:GetHandler():GetReasonCard():GetMaterial()
	return r==REASON_XYZ and mg:IsExists(Card.IsSetCard,mg:GetCount(),nil,0x59)
end
-- 为超量召唤的怪兽赋予效果，若其不是效果怪兽则为其添加效果怪兽类型
function c91718579.effop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动了本卡的效果（显示卡片动画）
	Duel.Hint(HINT_CARD,0,91718579)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这次超量召唤成功时，以对方场上1只表侧攻击表示怪兽为对象才能发动。那只怪兽变成守备表示并把守备力变成0。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(91718579,0))  --"对方场上1只怪兽变成守备表示并把守备力变成0。"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c91718579.poscon)
	e1:SetTarget(c91718579.postg)
	e1:SetOperation(c91718579.posop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ②：只用包含这张卡的「隆隆隆」怪兽为素材的超量怪兽得到以下效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 检查该怪兽是否是通过超量召唤特殊召唤的
function c91718579.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤对方场上表侧攻击表示且可以改变表示形式的怪兽
function c91718579.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 改变表示形式效果的靶向/发动准备函数
function c91718579.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c91718579.filter(chkc) end
	-- 检查对方场上是否存在可以改变表示形式的表侧攻击表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c91718579.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 玩家选择对方场上1只表侧攻击表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c91718579.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 改变表示形式效果的执行函数
function c91718579.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsDefensePos() or not tc:IsRelateToEffect(e) then return end
	-- 将对象怪兽变成表侧守备表示，若失败则结束处理
	if Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)==0 then return end
	-- 并把守备力变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(0)
	tc:RegisterEffect(e1)
end
