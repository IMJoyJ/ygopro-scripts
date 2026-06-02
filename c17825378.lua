--捕食植物トリアンティス
--not fully implemented
-- 效果：
-- （注：暂时无法正常使用）
-- 
-- ←8 【灵摆】 8→
-- ①：只要这张卡在灵摆区域存在，自己把暗属性融合怪兽融合召唤的场合，自己的灵摆区域存在的融合素材怪兽也能作为场上的怪兽来作为融合素材使用。
-- 【怪兽效果】
-- ①：这张卡成为融合召唤的素材，被送去墓地的场合或者表侧加入额外卡组的场合才能发动。选最多有自己场上的怪兽数量的场上的表侧表示怪兽。给那些怪兽各放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
function c17825378.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性与灵摆召唤手续
	aux.EnablePendulumAttribute(c)
	-- ①：只要这张卡在灵摆区域存在，自己把暗属性融合怪兽融合召唤的场合，自己的灵摆区域存在的融合素材怪兽也能作为场上的怪兽来作为融合素材使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_PZONE,0)
	e1:SetValue(c17825378.mtval)
	c:RegisterEffect(e1)
	-- ①：这张卡成为融合召唤的素材，被送去墓地的场合或者表侧加入额外卡组的场合才能发动。选最多有自己场上的怪兽数量的场上的表侧表示怪兽。给那些怪兽各放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c17825378.ctcon)
	e2:SetTarget(c17825378.cttg)
	e2:SetOperation(c17825378.ctop)
	c:RegisterEffect(e2)
end
-- 灵摆融合素材代用效果的属性设置函数
function c17825378.mtval(e,c)
	if not c then return true end
	return true
end
-- 怪兽效果①的发动条件判断：作为融合素材送墓或加入额外卡组
function c17825378.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE+LOCATION_EXTRA) and r==REASON_FUSION and not c:IsReason(REASON_RETURN)
end
-- 怪兽效果①的发动目标判断：检查我方场上是否有怪兽以及场上是否有可以放置指示物的卡
function c17825378.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时，检查自己场上是否存在怪兽
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 在效果发动时，检查场上是否存在可以放置捕食指示物的卡片
		and Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x1041,1) end
end
-- 怪兽效果①的效果处理：给场上的表侧表示怪兽放置捕食指示物并将其等级变为1星
function c17825378.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的怪兽数量，作为放置指示物的最大上限数量
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	-- 获取场上所有可以放置捕食指示物的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,0x1041,1)
	if ct>0 then
		-- 提示玩家选择要放置指示物的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		local sg=g:Select(tp,1,ct,nil)
		local sc=sg:GetFirst()
		while sc do
			if sc:AddCounter(0x1041,1) and sc:GetLevel()>1 then
				-- 给放置了捕食指示物的2星以上的怪兽注册使其等级变成1星的效果
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetCondition(c17825378.lvcon)
				e1:SetValue(1)
				sc:RegisterEffect(e1)
			end
			sc=sg:GetNext()
		end
	end
end
-- 等级改变效果的使能条件函数：卡片上必须存有至少1个捕食指示物
function c17825378.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
