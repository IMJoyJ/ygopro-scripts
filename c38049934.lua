--炎塵爆発
-- 效果：
-- 把自己墓地存在的名字带有「熔岩」的怪兽全部从游戏中除外发动。把最多有除外的怪兽数量的场上存在的卡破坏。
function c38049934.initial_effect(c)
	-- 把自己墓地存在的名字带有「熔岩」的怪兽全部从游戏中除外发动。把最多有除外的怪兽数量的场上存在的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c38049934.cost)
	e1:SetTarget(c38049934.target)
	e1:SetOperation(c38049934.activate)
	c:RegisterEffect(e1)
end
c38049934.check=false
-- 代价筛选函数：选择自己墓地中满足「熔岩」字段且可以作为代价除外的怪兽。
function c38049934.cfilter(c)
	return c:IsSetCard(0x39) and c:IsAbleToRemoveAsCost()
end
-- 代价处理函数：先判断墓地是否存在至少1张可除外的「熔岩」怪兽；若存在，则将墓地所有满足条件的「熔岩」怪兽全部除外，并把除外数量记录到效果标签中，作为后续最多可破坏卡数的依据。
function c38049934.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	c38049934.check=true
	-- 代价合法性检查：确认墓地存在至少1张可以作为代价除外的「熔岩」怪兽，才能发动此卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c38049934.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 获取墓地中所有可作为代价除外的「熔岩」怪兽，组成一组用于全部除外。
	local g=Duel.GetMatchingGroup(c38049934.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 将上述选中的所有「熔岩」怪兽以表侧表示从游戏中除外，作为发动这张卡的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetCount())
end
-- 目标处理函数：确认已经通过代价处理标志，且场上存在除本卡以外能成为破坏对象的卡；如果满足，则将场上除本卡外的所有卡作为可能破坏的对象，并登记破坏的操作信息。
function c38049934.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if not c38049934.check then return false end
		c38049934.check=false
		-- 检查场上是否存在除本卡以外的卡，保证至少能有1个破坏对象。
		return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
	end
	c38049934.check=false
	-- 获取场上除本卡以外的所有卡（包括双方怪兽区域和魔法陷阱区域的卡），作为潜在破坏对象集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置本次连锁的操作信息：登记为破坏效果，对象为场上除本卡外的所有卡，处理数量记为1，供其他效果判断本连锁是否可能破坏卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数：根据代价除外的怪兽数量，从场上选择最多相应数量的卡（本卡除外）并破坏。
function c38049934.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示“请选择要破坏的卡”的选择提示，并缓存选择用消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1到除外怪兽数量（e:GetLabel()）张的卡（本卡除外）作为破坏对象，数量上限由代价除外的怪兽数决定。
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetLabel(),aux.ExceptThisCard(e))
	-- 以效果破坏所选择的卡，将那些卡送去墓地。
	Duel.Destroy(g,REASON_EFFECT)
end
