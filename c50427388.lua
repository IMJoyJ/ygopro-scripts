--暴走する魔力
-- 效果：
-- 自己墓地的魔法卡全部从游戏中除外才能发动。持有除外的魔法卡数量×300的数值以下的守备力的对方场上表侧表示存在的怪兽全部破坏。
function c50427388.initial_effect(c)
	-- 效果原文内容：自己墓地的魔法卡全部从游戏中除外才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c50427388.cost)
	e1:SetTarget(c50427388.target)
	e1:SetOperation(c50427388.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：设置成本标签为1，表示已支付成本
function c50427388.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 效果作用：过滤满足条件的魔法卡（类型为魔法且可除外）
function c50427388.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemove()
end
-- 效果作用：过滤满足条件的怪兽（表侧表示且守备力低于指定值）
function c50427388.filter(c,def)
	return c:IsFaceup() and c:IsDefenseBelow(def)
end
-- 效果原文内容：持有除外的魔法卡数量×300的数值以下的守备力的对方场上表侧表示存在的怪兽全部破坏。
function c50427388.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 效果作用：统计自己墓地的魔法卡数量
		local ct=Duel.GetMatchingGroupCount(c50427388.cfilter,tp,LOCATION_GRAVE,0,nil)
		-- 效果作用：检查是否存在满足条件的对方怪兽（守备力不超过除外魔法卡数×300）
		return Duel.IsExistingMatchingCard(c50427388.filter,tp,0,LOCATION_MZONE,1,nil,ct*300)
	end
	-- 效果作用：检索自己墓地的所有魔法卡
	local g=Duel.GetMatchingGroup(c50427388.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 效果作用：将检索到的魔法卡从游戏中除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetCount()*300)
	-- 效果作用：根据除外的魔法卡数量计算破坏上限，检索满足条件的对方怪兽
	local sg=Duel.GetMatchingGroup(c50427388.filter,tp,0,LOCATION_MZONE,nil,g:GetCount()*300)
	-- 效果作用：设置连锁操作信息，标记即将破坏的怪兽数量和目标
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果原文内容：持有除外的魔法卡数量×300的数值以下的守备力的对方场上表侧表示存在的怪兽全部破坏。
function c50427388.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：根据已记录的破坏上限值检索满足条件的对方怪兽
	local sg=Duel.GetMatchingGroup(c50427388.filter,tp,0,LOCATION_MZONE,nil,e:GetLabel())
	-- 效果作用：将满足条件的对方怪兽破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
