--リンケージ・ホール
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有连接4以上的连接怪兽存在的场合才能发动。选最多有自己场上的连接3以上的连接怪兽数量的对方场上的怪兽破坏。
function c73275815.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有连接4以上的连接怪兽存在的场合才能发动。选最多有自己场上的连接3以上的连接怪兽数量的对方场上的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,73275815+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c73275815.condition)
	e1:SetTarget(c73275815.target)
	e1:SetOperation(c73275815.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示且连接标记在4以上的怪兽
function c73275815.cfilter(c)
	return c:IsFaceup() and c:IsLinkAbove(4)
end
-- 发动条件：自己场上有连接4以上的连接怪兽存在的场合才能发动
function c73275815.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示且连接标记在4以上的怪兽
	return Duel.IsExistingMatchingCard(c73275815.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：自己场上表侧表示且连接标记在3以上的怪兽
function c73275815.filter(c)
	return c:IsFaceup() and c:IsLinkAbove(3)
end
-- 效果发动时的目标选择与合法性检测：计算自己场上连接3以上的怪兽数量，并检查对方场上是否有怪兽，最后设置破坏效果的操作信息
function c73275815.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上表侧表示且连接标记在3以上的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c73275815.filter,tp,LOCATION_MZONE,0,nil)
	-- 获取对方场上的所有怪兽
	local dg=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if chk==0 then return ct>0 and dg:GetCount()>0 end
	-- 设置操作信息，表示该效果会破坏对方场上的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
end
-- 效果处理：计算自己场上连接3以上的怪兽数量，让玩家选择最多该数量的对方场上的怪兽并破坏
function c73275815.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，重新计算自己场上表侧表示且连接标记在3以上的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c73275815.filter,tp,LOCATION_MZONE,0,nil)
	if ct==0 then return end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择1到ct张（最多为自己场上连接3以上怪兽数量）的对方场上的怪兽
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,ct,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽因效果破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
