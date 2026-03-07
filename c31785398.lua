--迎撃準備
-- 效果：
-- 场上的1只表侧表示存在的战士族或魔法师族怪兽变成里侧守备表示。
function c31785398.initial_effect(c)
	-- 效果原文内容
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_PHASE,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_PHASE)
	e1:SetTarget(c31785398.target)
	e1:SetOperation(c31785398.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组
function c31785398.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet() and c:IsRace(RACE_WARRIOR+RACE_SPELLCASTER)
end
-- 效果作用
function c31785398.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c31785398.filter(chkc) end
	-- 检查是否有满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c31785398.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一个满足条件的目标怪兽
	local g=Duel.SelectTarget(tp,c31785398.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息为改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果作用
function c31785398.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽变成里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
