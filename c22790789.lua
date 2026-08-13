--巨大戦艦 クリスタル・コア
-- 效果：
-- ①：这张卡召唤的场合发动。给这张卡放置3个指示物。
-- ②：这张卡不会被战斗破坏。
-- ③：1回合1次，以对方场上1只表侧攻击表示怪兽为对象才能发动。那只对方的表侧攻击表示怪兽变成表侧守备表示。
-- ④：这张卡进行战斗的伤害步骤结束时发动。这张卡1个指示物取除。不能取除的场合，这张卡破坏。
function c22790789.initial_effect(c)
	c:EnableCounterPermit(0x1f)
	-- ①：这张卡召唤的场合发动。给这张卡放置3个指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22790789,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c22790789.addct)
	e1:SetOperation(c22790789.addc)
	c:RegisterEffect(e1)
	-- ②：这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 启用“B.E.S.”系列通用效果：这张卡进行战斗的伤害步骤结束时，有指示物则去除1个指示物，不能取除的场合自身破坏（对应④）。
	aux.EnableBESRemove(c)
	-- ③：1回合1次，以对方场上1只表侧攻击表示怪兽为对象才能发动。那只对方的表侧攻击表示怪兽变成表侧守备表示。
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
-- 效果①的发动条件判定与操作信息设置：召唤成功时触发（必发），并登记放置3个指示物的操作信息。
function c22790789.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本次效果处理为给这张卡放置3个0x1f类型的指示物（CATEGORY_COUNTER，数量3，指示物类型0x1f）。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x1f)
end
-- 效果①的实际处理：若这张卡仍与效果关联，则给这张卡放置3个0x1f类型的指示物。
function c22790789.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1f,3)
	end
end
-- 筛选对方场上符合条件的怪兽：要求表侧攻击表示且可以被效果改变表示形式。
function c22790789.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 效果③的发动条件与取对象处理：确认对方场上存在符合条件的表侧攻击表示怪兽，由发动者选择其中1只作为对象，并登记变更表示形式的操作信息。
function c22790789.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c22790789.filter(chkc) end
	-- 启动判定：检查对方场上是否存在至少1只满足条件且可被选择为对象的表侧攻击表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c22790789.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示“请选择要改变表示形式的怪兽”，并写入选择消息缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让发动者从对方怪兽区域选择1只符合条件的表侧攻击表示怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c22790789.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记操作信息：本次效果将改变表示形式，对象为已选择的1只怪兽（CATEGORY_POSITION）。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果③的处理：对象怪兽若仍与效果关联且仍为表侧攻击表示，则将其变更为表侧守备表示。
function c22790789.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次连锁中记录的第一只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsPosition(POS_FACEUP_ATTACK) and tc:IsRelateToEffect(e) then
		-- 将取得的对象怪兽的表示形式变成表侧守备表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end
