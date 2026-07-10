--迎撃準備
-- 效果：
-- 场上的1只表侧表示存在的战士族或魔法师族怪兽变成里侧守备表示。
function c31785398.initial_effect(c)
	-- 场上的1只表侧表示存在的战士族或魔法师族怪兽变成里侧守备表示。
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
-- 过滤场上表侧表示且可以变成里侧守备表示的战士族或魔法师族怪兽
function c31785398.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet() and c:IsRace(RACE_WARRIOR+RACE_SPELLCASTER)
end
-- 效果发动时的目标选择与检测阶段函数，选择场上1只符合条件的怪兽作为效果的对象
function c31785398.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c31785398.filter(chkc) end
	-- 在发动效果的检测阶段，检查场上是否存在至少1只可以作为对象的表侧表示的战士族或魔法师族怪兽
	if chk==0 then return Duel.IsExistingTarget(c31785398.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示，指示选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只符合过滤条件的怪兽作为当前连锁的效果对象
	local g=Duel.SelectTarget(tp,c31785398.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息，表示该操作包含改变表示形式分类，影响数量为1，目标为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理阶段函数，获取目标怪兽并将其变成里侧守备表示
function c31785398.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的第一目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽的表示形式改变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
