--霊獣の連契
-- 效果：
-- ①：把最多有自己场上的「灵兽」怪兽数量的场上的怪兽破坏。
function c11556339.initial_effect(c)
	-- ①：把最多有自己场上的「灵兽」怪兽数量的场上的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(c11556339.condition)
	e1:SetTarget(c11556339.target)
	e1:SetOperation(c11556339.activate)
	c:RegisterEffect(e1)
end
-- 判断怪兽是否为表侧表示且属于「灵兽」系列（卡名含有0xb5对应的「灵兽」字段）。
function c11556339.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb5)
end
-- 效果发动条件：自己场上存在至少1只表侧表示的「灵兽」怪兽。
function c11556339.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足条件的「灵兽」怪兽。
	return Duel.IsExistingMatchingCard(c11556339.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动时进行目标设定：确认场上存在可被破坏的怪兽，并收集场上所有怪兽作为破坏效果的操作信息。
function c11556339.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：场上必须存在至少1只可被选择为破坏对象的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有怪兽的集合，用于后续操作信息中记录可能被破坏的对象。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置本连锁的破坏操作信息：将场上所有怪兽作为可能被破坏的对象，数量记为1（实际数量效果处理时再确定）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：根据自己场上「灵兽」怪兽的数量决定最大破坏数，从场上怪兽中选择1到该数量的怪兽并破坏。
function c11556339.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 计算自己场上表侧表示「灵兽」怪兽的数量，作为本次最多可以破坏的怪兽数量。
	local ct=Duel.GetMatchingGroupCount(c11556339.cfilter,tp,LOCATION_MZONE,0,nil)
	if ct==0 then return end
	-- 向玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上所有怪兽中选择1到ct张卡作为破坏对象。
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,ct,nil)
	if g:GetCount()>0 then
		-- 为选中的卡显示对象选择动画，并记录这些卡被选为效果对象。
		Duel.HintSelection(g)
		-- 将所选怪兽以效果原因（REASON_EFFECT）破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
