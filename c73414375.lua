--ディメンション・ポッド
-- 效果：
-- 反转：双方均可以从对方墓地中选至多3张卡从游戏中除外。
function c73414375.initial_effect(c)
	-- 反转：双方均可以从对方墓地中选至多3张卡从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73414375,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c73414375.target)
	e1:SetOperation(c73414375.operation)
	c:RegisterEffect(e1)
end
-- 反转效果的目标确认函数，不作任何限制直接返回true
function c73414375.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 反转效果的效果处理，依次让双方玩家选择对方墓地的卡片并合并到卡组中，最后同时除外
function c73414375.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 检查对方（非回合玩家）墓地是否存在可除外的卡，并询问回合玩家是否选择卡片除外
	if Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(73414375,1)) then  --"是否要选择卡从游戏中除外？"
		-- 提示回合玩家选择要除外的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让回合玩家从对方（非回合玩家）墓地选择1到3张卡片
		local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,3,nil)
		g:Merge(rg)
	end
	-- 检查自己（回合玩家）墓地是否存在可除外的卡，并询问非回合玩家是否选择卡片除外
	if Duel.IsExistingMatchingCard(Card.IsAbleToRemove,1-tp,0,LOCATION_GRAVE,1,nil,1-tp) and Duel.SelectYesNo(1-tp,aux.Stringid(73414375,1)) then  --"是否要选择卡从游戏中除外？"
		-- 提示非回合玩家选择要除外的卡片
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让非回合玩家从对方（回合玩家）墓地选择1到3张卡片
		local rg=Duel.SelectMatchingCard(1-tp,Card.IsAbleToRemove,1-tp,0,LOCATION_GRAVE,1,3,nil,1-tp)
		g:Merge(rg)
	end
	-- 将双方玩家选出的所有卡片同时以表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
