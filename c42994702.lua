--さまようミイラ
-- 效果：
-- 这张卡1个回合可以有1次变回里侧守备表示。这个效果使用后，把自己的主要怪兽区域的全部里侧守备表示的怪兽洗切，再次重新里侧守备表示按自己的顺序安排到场上的位置。
function c42994702.initial_effect(c)
	-- 这张卡1个回合可以有1次变回里侧守备表示。这个效果使用后，把自己的主要怪兽区域的全部里侧守备表示的怪兽洗切，再次重新里侧守备表示按自己的顺序安排到场上的位置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42994702,0))  --"变成里侧守备"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c42994702.target)
	e1:SetOperation(c42994702.operation)
	c:RegisterEffect(e1)
end
-- 发动前检查：自己场上的此卡能够变更为里侧守备表示，且本回合尚未发动过本效果（flag为0）；满足条件后将一回合一次的限制标记注册到自身（该标记在离场、回手、回卡组、除外、送墓及结束阶段等时重置）。
function c42994702.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(42994702)==0 end
	c:RegisterFlagEffect(42994702,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置本连锁的操作信息为“改变表示形式”，对象为自身，数量为1，供其他卡的效果进行联动判定。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 筛选条件：卡为里侧守备表示，且所在区域为主要怪兽区（序号<5，排除额外怪兽区）。
function c42994702.filter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
-- 效果处理时，先确认此卡仍与发动效果关联、处于表侧表示，并将自身成功变更为里侧守备表示；随后取出自己主要怪兽区域全部里侧守备表示的怪兽，将它们洗切并重新里侧守备表示安排回主要怪兽区域。
function c42994702.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否仍与本次发动效果相关、仍是表侧表示，且成功变更为里侧守备表示（变更成功才继续后续洗切重排）。
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)>0 then
		-- 获取自己主要怪兽区域中全部里侧守备表示的怪兽（包括刚变为里侧的自身），作为后续洗切重排的对象。
		local g=Duel.GetMatchingGroup(c42994702.filter,tp,LOCATION_MZONE,0,nil)
		-- 将选中的里侧守备怪兽洗切，再以里侧守备表示随机重新排列回主要怪兽区域。
		Duel.ShuffleSetCard(g)
	end
end
