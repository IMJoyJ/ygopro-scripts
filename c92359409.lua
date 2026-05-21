--超弩級砲塔列車グスタフ・ロケット
-- 效果：
-- 10星怪兽×3
-- 「超重型炮塔列车 古斯塔夫火箭大炮」1回合1次也能丢弃1张手卡，在自己场上的「超重型炮塔列车 古斯塔夫最大炮」上面重叠来超量召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡持有超量素材，对方把怪兽的效果发动时才能发动。那个效果无效并破坏。那之后，给与对方1000伤害。
-- ②：自己结束阶段发动。这张卡1个超量素材取除或这张卡破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含超量召唤手续、①效果（无效并破坏+伤害）和②效果（结束阶段取除素材或破坏）
function s.initial_effect(c)
	-- 注册该卡关联的卡片密码（「超重型炮塔列车 古斯塔夫最大炮」的卡号56910167）
	aux.AddCodeList(c,56910167)
	aux.AddXyzProcedure(c,nil,10,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)  --"是否在「超重型炮塔列车 古斯塔夫最大炮」上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡持有超量素材，对方把怪兽的效果发动时才能发动。那个效果无效并破坏。那之后，给与对方1000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- ②：自己结束阶段发动。这张卡1个超量素材取除或这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"取除超量素材"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.rmcon)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手牌中可以因特殊召唤而丢弃的卡
function s.cfilter(c)
	return c:IsDiscardable(REASON_SPSUMMON)
end
-- 过滤条件：自己场上表侧表示的「超重型炮塔列车 古斯塔夫最大炮」
function s.ovfilter(c)
	return c:IsFaceup() and c:IsCode(56910167)
end
-- 叠放超量召唤的操作函数，处理丢弃1张手卡作为代替召唤手续的代价，并注册回合发动次数限制
function s.xyzop(e,tp,chk)
	-- 检查本回合是否未使用过该方法进行超量召唤，且手牌中是否存在可丢弃的卡
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家从手牌选择1张卡作为丢弃的代价
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD)
	-- 注册玩家本回合已使用该方法进行超量召唤的标记（1回合1次限制）
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- ①效果的发动条件：此卡未被战斗破坏、发动的效果可以被无效、此卡持有超量素材、对方发动怪兽效果
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否未被战斗破坏，且该连锁效果是否可以被无效
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainDisablable(ev)
		and c:GetOverlayCount()>0 and ep==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- ①效果的靶向/操作信息设置函数，设置无效、破坏和伤害的操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
		-- 设置操作信息：给与对方1000点伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
	end
end
-- ①效果的执行函数：无效并破坏发动的卡，之后给与对方1000点伤害
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功无效该效果，且该卡在连锁中关系成立
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToChain(ev)
		-- 且成功将该卡因效果破坏
		and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		-- 中断效果处理，使后续的伤害处理不与破坏同时进行（用于“那之后”的时点处理）
		Duel.BreakEffect()
		-- 给与对方1000点效果伤害
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end
-- ②效果的发动条件：当前回合玩家是自己
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- ②效果的执行函数：选择取除1个超量素材，否则将这张卡破坏
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果此卡持有超量素材，且玩家选择取除超量素材
	if c:GetOverlayCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否取除超量素材？"
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	else
		-- 将这张卡因效果破坏
		Duel.Destroy(c,REASON_EFFECT)
	end
end
