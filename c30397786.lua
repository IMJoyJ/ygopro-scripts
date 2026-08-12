--白き幻獣－青眼の白龍
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡从卡组加入手卡时或者自己怪兽被战斗破坏时，把手卡的这张卡给对方观看才能发动。这张卡特殊召唤。
-- ②：这张卡从手卡·卡组特殊召唤的场合才能发动。对方场上的怪兽全部破坏。这个回合，自己不用「青眼」怪兽不能直接攻击。
-- ③：场上的这张卡为对象的效果发动时，丢弃1张手卡才能发动。那个效果无效。
local s,id,o=GetID()
-- 初始化卡片效果，注册4个效果：e1为这张卡从卡组加入手卡时发动的特殊召唤效果、e2为自己怪兽被战斗破坏时从手卡发动的特殊召唤效果（共用①效果的1回合1次计数）、e3为从手卡·卡组特殊召唤成功时破坏对方全场怪兽的效果、e4为以场上这张卡为对象的效果发动时使其无效的诱发即时效果
function s.initial_effect(c)
	-- ①：这张卡从卡组加入手卡时或者自己怪兽被战斗破坏时，把手卡的这张卡给对方观看才能发动。这张卡特殊召唤。（这个卡名的①的效果1回合只能使用1次）
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
	-- ①：这张卡从卡组加入手卡时或者自己怪兽被战斗破坏时，把手卡的这张卡给对方观看才能发动。这张卡特殊召唤。（这个卡名的①的效果1回合只能使用1次）
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
	-- ②：这张卡从手卡·卡组特殊召唤的场合才能发动。对方场上的怪兽全部破坏。这个回合，自己不用「青眼」怪兽不能直接攻击。（这个卡名的②的效果1回合只能使用1次）
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
-- ①效果发动条件：检查这张卡是从卡组加入手卡的
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK)
end
-- 过滤器：检查该怪兽被战斗破坏前的控制者是发动玩家自己
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp)
end
-- ①效果发动条件：检查被战斗破坏的怪兽中存在原本由自己控制的怪兽
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 发动代价检查：确认手卡的这张卡尚未公开（发动时将其给对方观看作为代价）
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() end
end
-- 效果对象检查：确认自己主要怪兽区有空位且这张卡可以被特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己主要怪兽区是否存在可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：宣言将特殊召唤这张卡，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与该连锁关联，则将这张卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 把这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果发动条件：检查这张卡是从手卡或卡组特殊召唤的
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_HAND+LOCATION_DECK)
end
-- ②效果对象检查：确认对方场上存在怪兽，取对方场上全部怪兽为破坏对象并设置操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 取得对方场上全部怪兽作为破坏对象
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：宣言将破坏对方场上的全部怪兽，数量为实际怪兽数
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- ②效果处理：破坏对方场上全部怪兽，并注册一个持续到回合结束的效果，使自己场上非「青眼」怪兽不能直接攻击
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得对方场上的全部怪兽
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 将对方场上的全部怪兽以效果原因破坏
	Duel.Destroy(sg,REASON_EFFECT)
	-- 这个回合，自己不用「青眼」怪兽不能直接攻击。③：场上的这张卡为对象的效果发动时，丢弃1张手卡才能发动。那个效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把不能直接攻击的限制效果注册给发动玩家，直到回合结束阶段为止有效
	Duel.RegisterEffect(e1,tp)
end
-- 目标过滤器：限制对象为不是「青眼」系列的怪兽（0xdd为青眼系列代码）
function s.atktg(e,c)
	return not c:IsSetCard(0xdd)
end
-- ③效果发动条件：这张卡未处于战斗破坏状态、该连锁的效果可以被无效、发动的效果取卡为对象且对象中包含场上的这张卡
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 检查该连锁的效果能否被无效，不能被无效则不满足发动条件
	if not Duel.IsChainDisablable(ev) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 取得该连锁发动的效果所取的对象卡组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsContains(c)
end
-- ③效果的代价：检查自己手卡存在可丢弃的卡，然后丢弃1张手卡作为代价
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让自己选择并丢弃1张手卡作为效果代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- ③效果对象：设置操作信息，宣言将该连锁的效果无效
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：宣言将该连锁的效果无效，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ③效果处理：将该连锁的效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的效果无效
	Duel.NegateEffect(ev)
end
