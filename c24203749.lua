--天下独歩の大義賊
local s,id,o=GetID()
-- 定义卡片初始化效果函数，用于注册卡牌的效果。
function s.initial_effect(c)
	-- ①：这张卡在自己场上表侧表示存在的场合，可以把手卡的1只怪兽当作祭品召唤。此效果一回合只能使用一次。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e0:SetCondition(s.sumcon)
	e0:SetTargetRange(LOCATION_HAND,LOCATION_MZONE)
	e0:SetTarget(s.sumtg)
	e0:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e0)
	-- ②：对方的连锁发动时，若这张卡在场上存在，则可以使那次连锁无效，并破坏对方场上的所有怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- ③：自己主要阶段，若为战斗阶段，则可以把自己的1只表侧攻击表示怪兽变成里侧守备表示。此效果一回合只能使用一次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.cpcon)
	e2:SetCost(s.cpcost)
	e2:SetTarget(s.cptg)
	e2:SetOperation(s.cpop)
	c:RegisterEffect(e2)
end
-- 定义特殊召唤的条件函数。
function s.sumcon(e)
	-- 检索满足条件的卡片组，判断场上是否已有怪兽存在。
	return not Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 定义特殊召唤的目标选择函数。
function s.sumtg(e,c)
	return c~=e:GetHandler() and c:IsType(TYPE_MONSTER)
end
-- 定义连锁无效和破坏效果的条件函数。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁发动的地点。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	-- 检查当前卡是否为战斗破坏状态，以及连锁是否可以被无效。
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainDisablable(ev)
		and c:IsSummonType(SUMMON_TYPE_NORMAL) and ep==1-tp
		and loc and bit.band(loc,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)~=0
end
-- 定义连锁无效和破坏效果的目标选择函数。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示要使连锁无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，表示要破坏目标怪兽。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义连锁无效和破坏效果的处理函数。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使连锁无效并且目标卡与连锁相关联，则执行后续的破坏操作。
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 以REASON_EFFECT原因破坏目标卡片。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 定义改变表示形式的条件函数。
function s.cpcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为战斗阶段。
	return Duel.IsBattlePhase()
end
-- 定义改变表示形式的费用支付函数。
function s.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手牌卡组。
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 检查手牌数量是否大于0，并且是否存在公开的手牌。
	if chk==0 then return g:GetCount()>0 and not Duel.IsExistingMatchingCard(Card.IsPublic,tp,LOCATION_HAND,0,1,nil) end
	-- 确认玩家需要舍弃的手牌。
	Duel.ConfirmCards(1-tp,g)
	-- 洗切玩家的手牌。
	Duel.ShuffleHand(tp)
end
-- 定义怪兽表示形式的过滤函数。
function s.posfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 定义改变表示形式的目标选择函数。
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在表侧攻击表示且可以改变表示形式的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取满足条件的怪兽卡组。
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息，表示要改变目标怪兽的表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 定义改变表示形式的处理函数。
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的怪兽卡组。
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		-- 将满足条件的怪兽变为里侧守备表示。
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
end
