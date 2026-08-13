--絢嵐渦麗ヴァルルーン
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：速攻魔法卡发动的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己墓地有「旋风」存在，对方把怪兽的效果发动时才能发动。那个效果无效。自己墓地有「旋风」2张以上存在的场合，可以再把那只怪兽破坏。
-- ③：这张卡在墓地存在的状态，「旋风」发动的场合才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化此卡的效果注册流程：将卡名「旋风」登记到代码列表，并依次创建并注册①手牌特殊召唤效果、②无效对方怪兽效果（可追加破坏）效果、③墓地特殊召唤效果，且三个效果各自受到同名卡1回合1次的次数限制。
function s.initial_effect(c)
	-- 调用aux.AddCodeList将此卡记为“记载有「旋风」卡名”的卡，用于后续判断该卡名存在。
	aux.AddCodeList(c,5318639)
	-- ①：速攻魔法卡发动的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己墓地有「旋风」存在，对方把怪兽的效果发动时才能发动。那个效果无效。自己墓地有「旋风」2张以上存在的场合，可以再把那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在的状态，「旋风」发动的场合才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：检测到连锁上有卡片发动，且该发动是魔法·陷阱卡的发动，并且该卡为速攻魔法卡。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_QUICKPLAY)
end
-- ③效果的发动条件：检测到连锁上有卡片发动，且该发动是魔法·陷阱卡的发动，并且发动卡卡的卡名是「旋风」。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(5318639)
end
-- ①和③效果共用的特殊召唤发动时点判定：若为效果发动时（chk==0），确认自己主要怪兽区有空位、且这张卡本身能够被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时点检查自己场上主要怪兽区是否拥有至少1个可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设定本次连锁将要进行的操作类别：将这张卡进行特殊召唤，并登记特殊召唤的对象和数量信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：取得这张卡自身，确认其仍与当前连锁相关后，将其表侧攻击表示特殊召唤到己方场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡从手卡以表侧表示特殊召唤到自己场上，不检查召唤条件、不检查苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③效果的处理：取得这张卡自身，在确认其仍与当前连锁相关，且不受王家长眠之谷等墓地效果封印影响的情况下，将其表侧攻击表示特殊召唤到己方场上。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否为本次连锁所对应的效果卡（没有离场导致联系中断），并追加过滤：该卡不受王家长眠之谷效果影响，以免墓地特殊召唤被禁止。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡从墓地以表侧表示特殊召唤到自己场上，不检查召唤条件、不检查苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义过滤器：用于筛选满足条件的「旋风」——表侧表示且卡名是「旋风」（在此被用于检查墓地中是否持有「旋风」）。
function s.confilter(c)
	return c:IsFaceup() and c:IsCode(5318639)
end
-- ②效果的发动条件：自己墓地存在「旋风」，且对方玩家发动了怪兽效果，并且该连锁效果当前能够被无效。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的墓地是否存在至少1张表侧表示的「旋风」，不存在则②效果不能发动。
	if not Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_GRAVE,0,1,nil) then return end
	-- 确认发动效果的玩家是对方、该效果为怪兽效果，且该连锁效果可以被无效化。
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- ②效果的发动时点处理：不取对象，直接允许发动；同时将本次连锁中对方发动的怪兽效果设定为要被无效化的对象。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：将当前连锁的触发源（对方发动的怪兽效果）作为无效对象，表示本效果将进行效果无效化处理。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ②效果的处理：先无效对方发动的那个怪兽效果；再在自己墓地存在2张以上「旋风」、那只怪兽仍与连锁相关且可被破坏时，询问玩家是否追加破坏那只怪兽。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 执行无效化处理，若无效失败（例如已无法无效）则直接结束本次效果处理。
	if not Duel.NegateEffect(ev) then return end
	-- 检查自己的墓地是否存在至少2张表侧表示的「旋风」，用于决定是否追加破坏。
	if Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_GRAVE,0,2,nil)
		and rc:IsRelateToChain(ev) and rc:IsType(TYPE_MONSTER) and rc:IsDestructable()
		-- 询问玩家是否选择使用追加破坏效果，将选择结果作为是否破坏的目标条件。
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把卡破坏？"
		-- 中断当前效果处理，使后续的破坏处理与之前的无效处理不再视为同一时点，避免错过时点。
		Duel.BreakEffect()
		-- 以效果原因破坏那只对方怪兽，将其送去墓地。
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
