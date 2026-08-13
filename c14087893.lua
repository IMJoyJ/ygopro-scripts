--月の書
-- 效果：
-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
function c14087893.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_PHASE,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_PHASE)
	e1:SetTarget(c14087893.target)
	e1:SetOperation(c14087893.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断怪兽是否为表侧表示且可以转为里侧表示。
function c14087893.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果发动时的目标处理：选择场上1只满足条件的表侧表示怪兽作为对象，并设置操作信息为改变表示形式。
function c14087893.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c14087893.filter(chkc) end
	-- 发动合法性检查：场上是否存在至少1只可被选择为对象的表侧表示且能转为里侧表示的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c14087893.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只场上表侧表示且可转为里侧表示的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c14087893.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息：将改变1只怪兽的表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理时的操作：取得对象怪兽，若其仍与效果关联且在场上表侧表示，则将其变为里侧守备表示。
function c14087893.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		-- 将该怪兽的表示形式变为里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
