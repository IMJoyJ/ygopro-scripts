--さまようミイラ
-- 效果：
-- 这张卡1个回合可以有1次变回里侧守备表示。这个效果使用后，把自己的主要怪兽区域的全部里侧守备表示的怪兽洗切，再次重新里侧守备表示按自己的顺序安排到场上的位置。
function c42994702.initial_effect(c)
	-- 效果原文：这张卡1个回合可以有1次变回里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42994702,0))  --"变成里侧守备"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c42994702.target)
	e1:SetOperation(c42994702.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：检查是否可以变回里侧守备表示且该回合未使用过此效果
function c42994702.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(42994702)==0 end
	c:RegisterFlagEffect(42994702,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 效果作用：设置连锁操作信息，表示将改变卡的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 效果作用：过滤函数，筛选出位于主要怪兽区且为里侧表示的怪兽
function c42994702.filter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
-- 效果作用：执行效果操作，将自身变为里侧守备表示并处理其他里侧守备表示的怪兽
function c42994702.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果作用：判断自身是否与效果相关且处于表侧表示，然后将自身变为里侧守备表示
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)>0 then
		-- 效果作用：获取所有位于主要怪兽区且为里侧表示的怪兽组成组
		local g=Duel.GetMatchingGroup(c42994702.filter,tp,LOCATION_MZONE,0,nil)
		-- 效果作用：对指定怪兽组进行洗切覆盖操作
		Duel.ShuffleSetCard(g)
	end
end
