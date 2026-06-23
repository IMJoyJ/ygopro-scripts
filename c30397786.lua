--白き幻獣－青眼の白龍
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡从卡组加入手卡时或者自己怪兽被战斗破坏时，把手卡的这张卡给对方观看才能发动。这张卡特殊召唤。
-- ②：这张卡从手卡·卡组特殊召唤的场合才能发动。对方场上的怪兽全部破坏。这个回合，自己不用「青眼」怪兽不能直接攻击。
-- ③：场上的这张卡为对象的效果发动时，丢弃1张手卡才能发动。那个效果无效。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- ①：这张卡从卡组加入手卡时，把手卡的这张卡给对方观看才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon1)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ①：自己怪兽被战斗破坏时，把手卡的这张卡给对方观看才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon2)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡从手卡·卡组特殊召唤的场合才能发动。对方场上的怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	-- ③：场上的这张卡为对象的效果发动时，丢弃1张手卡才能发动。那个效果无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"效果无效"
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.discon)
	e4:SetCost(s.discost)
	e4:SetTarget(s.distg)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
end
-- 特殊召唤效果①的发动条件：本卡之前的位置在卡组（即从卡组加入手牌）。
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK)
end
-- 被战斗破坏的怪兽过滤条件：原本控制者为己方。
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp)
end
-- 特殊召唤效果①的另一个发动条件：己方怪兽被战斗破坏。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 特殊召唤效果的Cost处理函数：确认手牌中的这张卡片未公开（给对方观看）。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() end
end
-- 特殊召唤效果的Target处理函数：检查己方主要怪兽区域是否有空位、本卡是否能特殊召唤，并设置特殊召唤操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查己方主要怪兽区域是否还有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为：从手牌特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的Operation处理函数：将这张卡特殊召唤到场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将卡片以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 破坏效果的发动条件：此卡是从手牌或卡组被特殊召唤的。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_HAND+LOCATION_DECK)
end
-- 破坏效果的Target处理函数：检查对方场上是否存在怪兽，并设置破坏这些怪兽的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有的怪兽卡。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置当前连锁的操作信息为：破坏对方场上的全部怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 破坏效果的Operation处理函数：破坏对方场上的全部怪兽，并注册本回合己方非「青眼」怪兽不能直接攻击的限制效果。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上的所有怪兽。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 因效果破坏对方场上的怪兽。
	Duel.Destroy(sg,REASON_EFFECT)
	-- 这个回合，自己不用「青眼」怪兽不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册本回合对玩家的不能直接攻击的限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 攻击限制过滤函数：若怪兽不属于「青眼」字段（0xdd），则受到该不能直接攻击的限制影响。
function s.atktg(e,c)
	return not c:IsSetCard(0xdd)
end
-- 效果无效的发动条件：场上的本卡没有因战斗被破坏，当前连锁效果可被无效，且该连锁是取本卡为对象发动的效果。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 检查发生效果的连锁是否能够被无效。
	if not Duel.IsChainDisablable(ev) then return false end
	-- 确认发动的效果是取对象效果，且其对象包含这张卡。
	return re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):IsContains(c)
end
-- 无效效果的Cost处理函数：检查并丢弃1张手牌。
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可以丢弃的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择1张可丢弃的手牌并作为Cost送去墓地。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 无效效果的Target处理函数：设置无效触发连锁卡片效果的操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为：使该发动连锁的效果无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 无效效果的Operation处理函数：无效触发连锁的效果。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前触发效果的连锁效果无效。
	Duel.NegateEffect(ev)
end
