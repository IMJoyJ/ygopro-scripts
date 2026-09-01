--聖なる心のバリア －マインドフォース－
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- ①：对方场上有表侧表示的卡5张以上存在的场合，这张卡在盖放的回合也能发动，这张卡的发动以及发动的效果不会被无效化。②：对方场上攻击力最高的怪兽攻击宣言时，或者对方把手卡·场上的怪兽的效果发动时（自己回合）或者包含破坏场上的卡的效果发动时才能发动。对方场上的表侧表示的卡的效果全部无效并破坏。这张卡的发动后，直到下个回合结束时自己怪兽不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
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
	-- 对方场上有表侧表示的卡5张以上存在的场合，这张卡在盖放的回合也能发动
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCondition(s.actcon)
	c:RegisterEffect(e3)
	-- 对方场上有表侧表示的卡5张以上存在的场合，这张卡的效果不会被无效
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_DISABLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCondition(s.nbcon)
	c:RegisterEffect(e4)
	-- 对方场上有表侧表示的卡5张以上存在的场合，这张卡的发动以及发动的效果不会被无效化
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_INACTIVATE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetValue(s.efilter)
	-- 为双方注册发动不能被无效的效果
	Duel.RegisterEffect(e5,0)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_CANNOT_DISEFFECT)
	-- 为双方注册发动的效果不能被无效的效果
	Duel.RegisterEffect(e6,0)
end
-- 检查对方场上是否有5张以上表侧表示的卡
function s.nbcon(e)
	-- 检查对方场上表侧表示卡片数量是否达到5张
	return Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),0,LOCATION_ONFIELD,5,nil)
end
-- 过滤不受无效化影响的发动
function s.efilter(e,ct)
	-- 获取连锁效果及发动玩家信息
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	if not te then return false end
	if te:GetOwner()~=e:GetOwner() then return false end
	if not te:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 检查对方场上表侧表示卡片数量是否达到5张
	return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,5,nil)
end
-- 连锁发动时的触发条件检查
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not re:IsActiveType(TYPE_MONSTER) then return false end
	-- 检查是否为自己回合
	if Duel.GetTurnPlayer()==tp then
		-- 获取连锁效果的发动位置
		local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
		if (LOCATION_HAND+LOCATION_ONFIELD)&loc~=0 then return true end
	end
	-- 获取连锁效果中破坏场上卡片的操作信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsOnField,nil)-tg:GetCount()>0
end
-- 攻击宣言时的触发条件检查
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return false end
	local tg=g:GetMaxGroup(Card.GetAttack)
	-- 检查是否为对方回合且攻击怪兽攻击力最高
	return Duel.GetTurnPlayer()~=tp and tg:IsContains(Duel.GetAttacker())
end
-- 效果目标：获取对方场上表侧表示的卡并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在表侧表示的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有表侧表示的卡
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	-- 设置无效效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
	-- 设置破坏的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 效果处理：无效对方场上表侧表示卡的效果并破坏，施加直接攻击限制
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有表侧表示的卡
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	local flag=false
	-- 遍历对方场上所有表侧表示的卡
	for tc in aux.Next(g) do
		if tc:IsCanBeDisabledByEffect(e,false) then
			flag=true
			-- 无效与卡片相关的连锁
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 使卡片的效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 使卡片发动的效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 使陷阱怪兽的效果无效
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e3)
			end
		end
	end
	-- 立即刷新场上卡的无效状态
	Duel.AdjustInstantly()
	if flag and #g>0 then
		-- 破坏对方场上所有表侧表示的卡
		Duel.Destroy(g,REASON_EFFECT)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到下个回合结束时自己怪兽不能直接攻击
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 注册直到下个回合结束时自己怪兽不能直接攻击的限制
		Duel.RegisterEffect(e1,tp)
	end
end
-- 盖放回合发动的条件：对方场上有5张以上表侧表示的卡
function s.actcon(e)
	-- 检查对方场上表侧表示卡片数量是否达到5张
	return Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),0,LOCATION_ONFIELD,5,nil)
end
