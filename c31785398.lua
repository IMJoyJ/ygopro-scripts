--迎撃準備
-- 效果：
-- 场上的1只表侧表示存在的战士族或魔法师族怪兽变成里侧守备表示。
function c31785398.initial_effect(c)
	-- ①：以场上1只表侧表示的战士族·魔法师族怪兽为对象才能发动。该怪兽变成里侧守备表示。
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
-- 过滤场上的表侧表示战士族或魔法师族怪兽
function c31785398.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet() and c:IsRace(RACE_WARRIOR+RACE_SPELLCASTER)
end
-- 效果发动的对象选择与操作设置
function c31785398.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c31785398.filter(chkc) end
	-- 检查场上是否存在符合条件的可改变表示形式的战士族或魔法师族怪兽
	if chk==0 then return Duel.IsExistingTarget(c31785398.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的一只战士族或魔法师族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c31785398.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为将该怪兽的位置变更为里侧守备表示
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理的执行
function c31785398.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将作为效果对象的怪兽变更为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
