--犀子の王様
-- 效果：
-- ①：1回合1次，卡的效果发动时才能发动（伤害步骤也能发动）。掷1次骰子。这个效果的发动时积累的连锁数量的以下效果适用。
-- ●2个：这张卡的攻击力直到回合结束时上升出现的数目×500。
-- ●3个：给与对方为出现的数目×500伤害。
-- ●4个以上：把最多有出现的数目数量的场上的卡破坏。
function c74289646.initial_effect(c)
	-- ①：1回合1次，卡的效果发动时才能发动（伤害步骤也能发动）。掷1次骰子。这个效果的发动时积累的连锁数量的以下效果适用。●2个：这张卡的攻击力直到回合结束时上升出现的数目×500。●3个：给与对方为出现的数目×500伤害。●4个以上：把最多有出现的数目数量的场上的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCategory(CATEGORY_DICE+CATEGORY_ATKCHANGE+CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c74289646.target)
	e1:SetOperation(c74289646.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的可行性检测与操作信息设置函数，根据当前连锁数动态调整效果分类、效果属性以及操作信息
function c74289646.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前正在处理的连锁序号（即当前积累的连锁数量）
	local cl=Duel.GetCurrentChain()
	if chk==0 then return true end
	if cl==2 then
		e:SetCategory(CATEGORY_DICE+CATEGORY_ATKCHANGE)
	end
	if cl==3 then
		e:SetCategory(CATEGORY_DICE+CATEGORY_DAMAGE)
		e:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET)
		-- 将当前连锁的对象玩家设置为对方玩家
		Duel.SetTargetPlayer(1-tp)
		-- 设置当前连锁的操作信息为：玩家掷1次骰子
		Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
		-- 设置当前连锁的操作信息为：给与对方玩家伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
	end
	if cl>=4 then
		e:SetCategory(CATEGORY_DICE+CATEGORY_DESTROY)
		-- 获取双方场上的所有卡片
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		-- 设置当前连锁的操作信息为：破坏场上的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果处理函数，首先掷1次骰子，然后根据发动时的连锁数适用对应的效果（上升攻击力、给与伤害或破坏场上的卡）
function c74289646.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前正在处理的连锁序号（即当前积累的连锁数量）
	local cl=Duel.GetCurrentChain()
	-- 让玩家掷1次骰子，并获取出现的数目
	local d=Duel.TossDice(tp,1)
	-- 获取当前连锁的对象玩家（即受到伤害的玩家）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取双方场上的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if cl==2 and c:IsRelateToEffect(e) then
		-- ●2个：这张卡的攻击力直到回合结束时上升出现的数目×500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(d*500)
		c:RegisterEffect(e1)
	end
	if cl==3 then
		-- 以效果伤害的形式给与目标玩家出现的数目×500的伤害
		Duel.Damage(p,d*500,REASON_EFFECT)
	end
	if cl>=4 and g:GetCount()>0 then
		local ct=math.min(g:GetCount(),d)
		-- 给发动效果的玩家发送“请选择要破坏的卡”的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,ct,nil)
		-- 手动为选中的卡片显示被选为对象的动画效果
		Duel.HintSelection(sg)
		-- 以效果原因破坏选中的卡片
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
