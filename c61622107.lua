--バブル・クラッシュ
-- 效果：
-- 手卡·场上的卡合计有6张以上的玩家，直到合计变成5张为止，把卡送去墓地。
function c61622107.initial_effect(c)
	-- 手卡·场上的卡合计有6张以上的玩家，直到合计变成5张为止，把卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c61622107.condition)
	e1:SetOperation(c61622107.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数
function c61622107.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否有任意一方玩家的手卡·场上的卡合计在6张以上
	return Duel.GetFieldGroupCount(tp,0xe,0)>=6 or Duel.GetFieldGroupCount(tp,0,0xe)>=6
end
-- 定义效果处理函数
function c61622107.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合玩家（回合玩家先处理效果）
	local p=Duel.GetTurnPlayer()
	-- 获取回合玩家的手卡·场上的卡合计数量
	local ct=Duel.GetFieldGroupCount(p,0xe,0)
	local exc=nil
	if ct>=6 then
		if p==tp and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			exc=e:GetHandler()
		else
			exc=nil
		end
		-- 提示回合玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让回合玩家选择超出5张部分的卡片（排除正在发动的此卡）
		local sg=Duel.SelectMatchingCard(p,nil,p,0xe,0,ct-5,ct-5,exc)
		-- 将回合玩家选中的卡因规则送去墓地
		Duel.SendtoGrave(sg,REASON_RULE)
	end
	-- 获取非回合玩家的手卡·场上的卡合计数量
	ct=Duel.GetFieldGroupCount(1-p,0xe,0)
	if ct>=6 then
		if 1-p==tp and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			exc=e:GetHandler()
		else
			exc=nil
		end
		-- 提示非回合玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,1-p,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让非回合玩家选择超出5张部分的卡片（排除正在发动的此卡）
		local sg=Duel.SelectMatchingCard(1-p,nil,1-p,0xe,0,ct-5,ct-5,exc)
		-- 将非回合玩家选中的卡因规则送去墓地
		Duel.SendtoGrave(sg,REASON_RULE)
	end
end
