--聖なる心のバリア －マインドフォース－
-- 效果：
-- 对方场上有表侧表示卡5张以上存在的场合，这张卡的发动和效果不会被无效化，这张卡在盖放的回合也能发动。
-- ①：以下其中任意种之时才能发动。对方场上的全部表侧表示卡的效果无效并破坏。这张卡的发动后，直到下个回合的结束时自己怪兽不能直接攻击。
-- ●对方场上的攻击力最高的怪兽的攻击宣言时
-- ●要让场上的卡破坏的怪兽的效果由对方发动时
-- ●自己回合对方把手卡·场上的怪兽的效果发动时
local s,id,o=GetID()
-- 注册卡片效果
function s.initial_effect(c)
	-- ①：以下其中任意种之时才能发动。对方场上的全部表侧表示卡的效果无效并破坏。这张卡的发动后，直到下个回合的结束时自己怪兽不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCondition(s.condition2)
	c:RegisterEffect(e2)
	-- 对方场上有表侧表示卡5张以上存在的场合，这张卡在盖放的回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"适用「神圣心灵防护罩 -心灵之力-」的效果来发动"
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCondition(s.actcon)
	c:RegisterEffect(e3)
	-- 对方场上有表侧表示卡5张以上存在的场合，这张卡的发动和效果不会被无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_DISABLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCondition(s.nbcon)
	c:RegisterEffect(e4)
	-- 对方场上有表侧表示卡5张以上存在的场合，这张卡的发动和效果不会被无效化。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_INACTIVATE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetValue(s.efilter)
	-- 注册发动不能被无效的全局效果
	Duel.RegisterEffect(e5,0)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_CANNOT_DISEFFECT)
	-- 注册发动的效果不能被无效的全局效果
	Duel.RegisterEffect(e6,0)
end
-- 效果不会被无效的适用条件：对方场上有表侧表示卡5张以上
function s.nbcon(e)
	-- 判断对方场上是否存在5张以上表侧表示的卡
	return Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),0,LOCATION_ONFIELD,5,nil)
end
-- 发动与效果不会被无效的过滤条件：本卡发动且对方场上有5张以上表侧表示卡
function s.efilter(e,ct)
	-- 获取连锁的发动效果与发动玩家
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	if not te then return false end
	if te:GetOwner()~=e:GetOwner() then return false end
	if not te:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 判断对方场上是否存在5张以上表侧表示卡
	return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,5,nil)
end
-- 发动条件1：怪兽效果由对方发动，且满足自己回合手卡·场上发动或要让场上的卡破坏
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not re:IsActiveType(TYPE_MONSTER) then return false end
	-- 判断当前是否为自己的回合
	if Duel.GetTurnPlayer()==tp then
		-- 获取触发效果发动的位置
		local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
		if (LOCATION_HAND+LOCATION_ONFIELD)&loc~=0 then return true end
	end
	if re:IsHasCategory(CATEGORY_NEGATE)
		-- 若上一连锁为魔法·陷阱卡发动且当前连锁为无效发动的效果则不满足条件
		and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取连锁效果中涉及破坏操作的信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsOnField,nil)-tg:GetCount()>0
end
-- 发动条件2：对方场上的攻击力最高的怪兽攻击宣言时
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return false end
	local tg=g:GetMaxGroup(Card.GetAttack)
	-- 判断是否为对方回合且攻击怪兽为对方场上攻击力最高的怪兽之一
	return Duel.GetTurnPlayer()~=tp and tg:IsContains(Duel.GetAttacker())
end
-- 发动目标：对方场上存在表侧表示的卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方场上是否存在表侧表示的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有表侧表示的卡
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：使对方场上全部表侧表示卡的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
	-- 设置操作信息：破坏对方场上全部表侧表示卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 效果处理：使对方场上全部表侧表示卡的效果无效并破坏，直到下个回合结束时自己怪兽不能直接攻击
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有表侧表示的卡
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	local flag=false
	-- 遍历对方场上所有表侧表示的卡
	for tc in aux.Next(g) do
		if tc:IsCanBeDisabledByEffect(e,false) then
			flag=true
			-- 无效与该卡相关的连锁
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 对方场上的全部表侧表示卡的效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 对方场上的全部表侧表示卡的效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 对方场上的全部表侧表示卡的效果无效
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e3)
			end
		end
	end
	-- 刷新场上卡的无效状态
	Duel.AdjustInstantly()
	if flag and #g>0 then
		-- 破坏对方场上全部表侧表示的卡
		Duel.Destroy(g,REASON_EFFECT)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到下个回合的结束时自己怪兽不能直接攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 注册直到下个回合结束时自己怪兽不能直接攻击的限制效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 盖放回合发动的适用条件：对方场上有表侧表示卡5张以上
function s.actcon(e)
	-- 判断对方场上是否存在5张以上表侧表示卡
	return Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),0,LOCATION_ONFIELD,5,nil)
end
