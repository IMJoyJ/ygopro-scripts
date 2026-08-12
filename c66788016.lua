--地割れ
-- 效果：
-- ①：对方场上1只攻击力最低的怪兽破坏。
function c66788016.initial_effect(c)
	-- ①：对方场上1只攻击力最低的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c66788016.target)
	e1:SetOperation(c66788016.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否为表侧表示
function c66788016.filter(c)
	return c:IsFaceup()
end
-- 效果发动阶段：检测对方场上是否存在表侧表示怪兽，并计算出攻击力最低的怪兽以设置破坏操作信息
function c66788016.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查对方场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c66788016.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(c66788016.filter,tp,0,LOCATION_MZONE,nil)
	local tg=g:GetMinGroup(Card.GetAttack)
	-- 设置当前连锁的处理信息，表明将破坏1张可能成为目标的攻击力最低的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end
-- 效果处理阶段：重新计算对方场上攻击力最低的怪兽，若有多个则由玩家选择1只破坏，否则直接破坏
function c66788016.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，重新获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(c66788016.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local tg=g:GetMinGroup(Card.GetAttack)
		if tg:GetCount()>1 then
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 为选中的怪兽显示被选为对象的动画效果，并向双方玩家展示
			Duel.HintSelection(sg)
			-- 因效果破坏选中的那1只怪兽
			Duel.Destroy(sg,REASON_EFFECT)
		-- 若攻击力最低的怪兽只有1只，则直接因效果破坏该怪兽
		else Duel.Destroy(tg,REASON_EFFECT) end
	end
end
