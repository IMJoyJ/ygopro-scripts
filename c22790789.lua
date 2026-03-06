--巨大戦艦 クリスタル・コア
-- 效果：
-- ①：这张卡召唤的场合发动。给这张卡放置3个指示物。
-- ②：这张卡不会被战斗破坏。
-- ③：1回合1次，以对方场上1只表侧攻击表示怪兽为对象才能发动。那只对方的表侧攻击表示怪兽变成表侧守备表示。
-- ④：这张卡进行战斗的伤害步骤结束时发动。这张卡1个指示物取除。不能取除的场合，这张卡破坏。
function c22790789.initial_effect(c)
	c:EnableCounterPermit(0x1f)
	-- 效果原文：①：这张卡召唤的场合发动。给这张卡放置3个指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22790789,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c22790789.addct)
	e1:SetOperation(c22790789.addc)
	c:RegisterEffect(e1)
	-- 效果原文：②：这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 注册一个在伤害步骤结束时触发的效果，用于处理战斗后指示物的取除或破坏判定。
	aux.EnableBESRemove(c)
	-- 效果原文：③：1回合1次，以对方场上1只表侧攻击表示怪兽为对象才能发动。那只对方的表侧攻击表示怪兽变成表侧守备表示。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(22790789,3))  --"改变表示形式"
	e5:SetCategory(CATEGORY_POSITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(c22790789.postg)
	e5:SetOperation(c22790789.posop)
	c:RegisterEffect(e5)
end
-- 设置效果处理时的操作信息，用于提示将要放置3个指示物。
function c22790789.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，指定将要放置3个指示物。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x1f)
end
-- 执行放置指示物的操作，为卡片添加3个指示物。
function c22790789.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1f,3)
	end
end
-- 过滤函数，用于筛选对方场上表侧攻击表示且可以改变表示形式的怪兽。
function c22790789.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 设置效果目标选择函数，用于选择对方场上表侧攻击表示的怪兽。
function c22790789.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c22790789.filter(chkc) end
	-- 检查是否存在符合条件的目标怪兽。
	if chk==0 then return Duel.IsExistingTarget(c22790789.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，提示选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择符合条件的对方怪兽作为效果目标。
	local g=Duel.SelectTarget(tp,c22790789.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，指定将要改变表示形式的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 执行改变表示形式的操作，将目标怪兽变为表侧守备表示。
function c22790789.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsPosition(POS_FACEUP_ATTACK) and tc:IsRelateToEffect(e) then
		-- 将目标怪兽改变为表侧守备表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end
