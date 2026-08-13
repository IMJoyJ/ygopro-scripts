--セイバー・スラッシュ
-- 效果：
-- ①：把自己场上的攻击表示的「X-剑士」怪兽数量的场上的表侧表示卡破坏。
function c11052544.initial_effect(c)
	-- ①：把自己场上的攻击表示的「X-剑士」怪兽数量的场上的表侧表示卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c11052544.target)
	e1:SetOperation(c11052544.activate)
	c:RegisterEffect(e1)
end
-- 定义破坏对象的过滤器：只选择场上表侧表示的卡。
function c11052544.filter(c)
	return c:IsFaceup()
end
-- 定义计数用过滤器：自己场上表侧表示且为攻击表示、持有「X-剑士」字段（0x100d）的怪兽。
function c11052544.cfilter(c)
	return c:IsFaceup() and c:IsAttackPos() and c:IsSetCard(0x100d)
end
-- 效果发动时的目标处理：chk==0时统计攻击表示X-剑士数量ct并保存到Label，同时检查场上是否存在至少ct张除本卡外的表侧表示卡；chk!=0时将场上除本卡外的表侧表示卡全体写入操作信息，指定破坏数量为ct。
function c11052544.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 统计自己场上表侧攻击表示的「X-剑士」怪兽数量，作为要破坏的卡牌数量ct。
		local ct=Duel.GetMatchingGroupCount(c11052544.cfilter,tp,LOCATION_MZONE,0,nil)
		e:SetLabel(ct)
		-- 检查双方场上是否存在至少ct张除本卡以外的表侧表示卡，满足才能发动效果。
		return Duel.IsExistingMatchingCard(c11052544.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,c)
	end
	local ct=e:GetLabel()
	-- 获取双方场上除本卡以外的所有表侧表示卡，作为候选破坏对象集合。
	local sg=Duel.GetMatchingGroup(c11052544.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置连锁的操作信息：本次效果属于破坏效果，候选对象为sg，预计破坏数量为ct。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,ct,0,0)
end
-- 效果处理：重新统计攻击表示X-剑士数量ct，获取场上除本卡外的全部表侧表示卡，若候选数不少于ct则由玩家选择ct张并破坏。
function c11052544.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新计算己方场上表侧攻击表示的「X-剑士」怪兽数量，作为实际破坏张数。
	local ct=Duel.GetMatchingGroupCount(c11052544.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取双方场上除本卡以外的所有表侧表示卡，构成可选破坏的卡池。
	local g=Duel.GetMatchingGroup(c11052544.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	if g:GetCount()>=ct then
		-- 向玩家显示选择提示，提示内容为“请选择要破坏的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,ct,ct,nil)
		-- 将选中的卡片显示为选中动画，并标记这些卡为被选择的对象。
		Duel.HintSelection(sg)
		-- 以效果原因（REASON_EFFECT）破坏选中的卡片，执行送入墓地的处理。
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
