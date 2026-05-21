--起動指令 ギア・フォース
-- 效果：
-- ①：自己场上的怪兽只有机械族怪兽的场合，自己或者对方的怪兽的攻击宣言时才能发动。选最多有自己场上的机械族怪兽数量的对方场上的攻击表示怪兽破坏。
function c9715126.initial_effect(c)
	-- ①：自己场上的怪兽只有机械族怪兽的场合，自己或者对方的怪兽的攻击宣言时才能发动。选最多有自己场上的机械族怪兽数量的对方场上的攻击表示怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c9715126.condition)
	e1:SetTarget(c9715126.target)
	e1:SetOperation(c9715126.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：里侧表示怪兽或者非机械族怪兽
function c9715126.cfilter(c)
	return c:IsFacedown() or not c:IsRace(RACE_MACHINE)
end
-- 发动条件：自己场上有怪兽存在，且自己场上的怪兽只有机械族怪兽
function c9715126.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)~=0
		-- 检查自己场上不存在里侧表示怪兽和非机械族怪兽（即只有表侧表示的机械族怪兽）
		and not Duel.IsExistingMatchingCard(c9715126.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动时的目标选择与处理：检查对方场上是否存在攻击表示怪兽，并设置破坏操作信息
function c9715126.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查对方场上是否存在至少1只攻击表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsPosition,tp,0,LOCATION_MZONE,1,nil,POS_ATTACK) end
	-- 获取对方场上攻击表示怪兽的数量
	local g=Duel.GetMatchingGroupCount(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_ATTACK)
	-- 设置连锁处理中的破坏操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 过滤条件：自己场上表侧表示的机械族怪兽
function c9715126.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
-- 效果处理：计算自己场上机械族怪兽数量，选择对应数量的对方场上攻击表示怪兽并破坏
function c9715126.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 计算自己场上表侧表示的机械族怪兽数量
	local ct=Duel.GetMatchingGroupCount(c9715126.filter,tp,LOCATION_MZONE,0,nil)
	if ct==0 then return end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择1到ct张（最多为自己场上机械族怪兽数量）对方场上的攻击表示怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsPosition,tp,0,LOCATION_MZONE,1,ct,nil,POS_ATTACK)
	if g:GetCount()>0 then
		-- 为选中的怪兽显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 因效果破坏选中的怪兽
		Duel.Destroy(g,REASON_EFFECT)
	end
end
