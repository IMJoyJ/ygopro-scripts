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
-- 过滤条件：场上表侧表示、可转为里侧表示的战士族或魔法师族怪兽
function c31785398.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet() and c:IsRace(RACE_WARRIOR+RACE_SPELLCASTER)
end
-- 效果选择目标判定与设置
function c31785398.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c31785398.filter(chkc) end
	-- 检查场上是否存在可以成为效果对象的战士族或魔法师族怪兽
	if chk==0 then return Duel.IsExistingTarget(c31785398.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 发送“请选择表侧表示的卡”提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只符合条件的目标怪兽
	local g=Duel.SelectTarget(tp,c31785398.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：表示形式变更，数量为1
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果执行函数
function c31785398.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽变成里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
