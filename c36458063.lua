--魔女の一撃
-- 效果：
-- ①：对方把怪兽的召唤·特殊召唤无效的场合或者对方把魔法·陷阱·怪兽的效果的发动无效的场合才能发动。对方的手卡·场上的卡全部破坏。
function c36458063.initial_effect(c)
	-- ①：对方把怪兽的召唤·特殊召唤无效的场合或者对方把魔法·陷阱·怪兽的效果的发动无效的场合才能发动。对方的手卡·场上的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_NEGATED)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c36458063.condition1)
	e1:SetTarget(c36458063.target)
	e1:SetOperation(c36458063.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_NEGATED)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_CUSTOM+36458063)
	c:RegisterEffect(e3)
	if not c36458063.global_check then
		c36458063.global_check=true
		-- 或者对方把魔法·陷阱·怪兽的效果的发动无效的场合。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_NEGATED)
		ge1:SetOperation(c36458063.checkop)
		-- 将ge1以场地持续效果的形式注册到整个决斗中（持有者0），使双方每次连锁被无效时都会触发checkop，用于检测对方无效魔法·陷阱·怪兽效果的发动。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 定义checkop函数：当场上发生连锁被无效的事件时，读取该连锁的无效方玩家dp，然后以魔女的一击为事件源触发自定义事件EVENT_CUSTOM+36458063，并将dp作为原因玩家传入，从而为e3提供‘对方把魔法·陷阱·怪兽的效果的发动无效’的时点。
function c36458063.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 从被无效的连锁信息中取出无效方玩家dp（即对方玩家），以此判断本次无效是由对方发动。
	local dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_PLAYER)
	-- 以魔女的一击为事件对象触发自定义事件EVENT_CUSTOM+36458063，并将无效方玩家dp作为原因玩家（rp）传入，使e3的condition可以根据rp判断是否满足‘对方发动无效’的条件。
	Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+36458063,e,0,dp,0,0)
end
-- 定义condition1：判定进行无效操作的玩家是否为对方（rp==1-tp），即只有对方把怪兽的召唤/特殊召唤或魔法/陷阱/怪兽效果发动无效时，才满足本卡的发动条件。
function c36458063.condition1(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 定义target：在效果发动前检查对方手卡·场上是否存在卡，并获取对方手卡·场上的全部卡，将破坏这些卡的信息写入连锁（不取对象）。
function c36458063.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法检查阶段（chk==0），确认对方手卡·场上存在至少1张卡，保证有可被破坏的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_HAND+LOCATION_ONFIELD,1,nil) end
	-- 获取对方手卡和场上的全部卡组成集合g，作为本次效果将要破坏的候选卡（不取对象，效果处理时以当时的卡为准）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_HAND+LOCATION_ONFIELD,nil)
	-- 将连锁的操作信息设为破坏集合g中的所有卡，数量为g:GetCount()，向系统宣告本效果将破坏对方手卡·场上的全部卡，供其他卡进行时点响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 定义activate：效果处理时，重新获取对方手卡和场上的全部卡，并将这些卡全部以效果原因破坏。
function c36458063.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次获取对方手卡·场上的全部卡，保证实际被破坏的是效果处理时仍然存在于对方手卡和场上的卡。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_HAND+LOCATION_ONFIELD,nil)
	-- 以效果原因REASON_EFFECT将集合g中的卡全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
