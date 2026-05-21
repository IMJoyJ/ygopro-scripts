--パイナップル爆弾
-- 效果：
-- 自己召唤怪兽成功时发动。若对方场上的怪兽数比自己控制的怪兽数多，则破坏对方场上的怪兽直到与自己的怪兽数量相同为止。破坏哪些怪兽由对方选择。
function c90669991.initial_effect(c)
	-- 自己召唤怪兽成功时发动。若对方场上的怪兽数比自己控制的怪兽数多，则破坏对方场上的怪兽直到与自己的怪兽数量相同为止。破坏哪些怪兽由对方选择。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c90669991.condition)
	e1:SetTarget(c90669991.target)
	e1:SetOperation(c90669991.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数
function c90669991.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己召唤怪兽成功，且对方场上的怪兽数量大于自己场上的怪兽数量
	return ep==tp and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end
-- 定义效果发动时的目标选择与操作信息设置函数
function c90669991.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 计算对方场上怪兽数量与自己场上怪兽数量的差值（即需要破坏的怪兽数量）
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	-- 设置效果处理的操作信息，表示将破坏对方场上的怪兽，数量为双方怪兽数量之差
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
end
-- 定义效果处理（运行）函数
function c90669991.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 计算当前对方场上怪兽数量与自己场上怪兽数量的差值
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	if ct>0 then
		-- 给对方玩家发送提示信息，提示其选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local dg=g:Select(1-tp,ct,ct,nil)
		-- 因效果破坏对方选择的怪兽
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
