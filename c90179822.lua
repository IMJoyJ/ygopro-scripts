--喜劇のデスピアン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上的表侧表示的「死狱乡」卡为对象的魔法·陷阱·怪兽的效果由对方发动时，把这张卡从手卡丢弃才能发动。那个效果无效。
-- ②：自己·对方回合，这张卡在墓地存在的场合，把自己场上1只融合怪兽解放才能发动。这张卡特殊召唤。
function c90179822.initial_effect(c)
	-- ①：自己场上的表侧表示的「死狱乡」卡为对象的魔法·陷阱·怪兽的效果由对方发动时，把这张卡从手卡丢弃才能发动。那个效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90179822,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,90179822)
	e1:SetCondition(c90179822.discon)
	e1:SetCost(c90179822.discost)
	e1:SetTarget(c90179822.distg)
	e1:SetOperation(c90179822.disop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，这张卡在墓地存在的场合，把自己场上1只融合怪兽解放才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90179822,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,90179822)
	e2:SetCost(c90179822.spcost)
	e2:SetTarget(c90179822.sptg)
	e2:SetOperation(c90179822.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「死狱乡」卡
function c90179822.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x164) and c:IsControler(tp) and c:IsOnField()
end
-- 效果①的发动条件：对方发动了以自己场上表侧表示的「死狱乡」卡为对象的效果，且该效果可以被无效
function c90179822.discon(e,tp,eg,ep,ev,re,r,rp)
	if not (rp==1-tp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)) then return false end
	-- 获取当前连锁的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 检查对象卡片组中是否存在自己场上表侧表示的「死狱乡」卡，且该连锁效果可以被无效
	return g and g:IsExists(c90179822.cfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
-- 效果①的代价：把手牌的这张卡丢弃
function c90179822.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身作为发动代价丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 效果①的靶向：确认发动，并设置效果无效的操作信息
function c90179822.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果①的效果处理：使该连锁的效果无效
function c90179822.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的效果无效
	Duel.NegateEffect(ev)
end
-- 过滤条件：自己场上可解放的融合怪兽（且解放后有空余怪兽区域）
function c90179822.rfilter(c,tp)
	-- 检查卡片是否为融合怪兽，是否由自己控制（或表侧表示），且解放后能留出至少1个怪兽区域
	return c:IsType(TYPE_FUSION) and (c:IsControler(tp) or c:IsFaceup()) and Duel.GetMZoneCount(tp,c)>0
end
-- 效果②的代价：解放自己场上1只融合怪兽
function c90179822.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可解放的融合怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c90179822.rfilter,1,nil,tp) end
	-- 选择自己场上1只融合怪兽解放
	local rg=Duel.SelectReleaseGroup(tp,c90179822.rfilter,1,1,nil,tp)
	-- 解放选中的怪兽
	Duel.Release(rg,REASON_COST)
end
-- 效果②的靶向：确认自身可以特殊召唤，并设置特殊召唤的操作信息
function c90179822.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：将墓地的这张卡特殊召唤
function c90179822.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
