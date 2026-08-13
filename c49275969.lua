--氷の王 ニードヘッグ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：「冰界王战 尼德霍格王」在自己场上只能有1只表侧表示存在。
-- ②：对方把怪兽特殊召唤之际，把自己场上1只「王战」怪兽或者幻龙族怪兽解放才能发动。那次特殊召唤无效，那些怪兽破坏。
function c49275969.initial_effect(c)
	c:SetUniqueOnField(1,0,49275969)
	-- 这个卡名的②的效果1回合只能使用1次。②：对方把怪兽特殊召唤之际，把自己场上1只「王战」怪兽或者幻龙族怪兽解放才能发动。那次特殊召唤无效，那些怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49275969,0))
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,49275969)
	e1:SetCondition(c49275969.discon)
	e1:SetCost(c49275969.discost)
	e1:SetTarget(c49275969.distg)
	e1:SetOperation(c49275969.disop)
	c:RegisterEffect(e1)
end
-- 发动条件判定函数：仅在对方玩家进行特殊召唤，且当前没有其他连锁处理时，才满足本效果的发动时机。
function c49275969.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果发动者不是进行特殊召唤的玩家（必须是对方特召），并且当前连锁数为0，可直接对应那次特殊召唤发动。
	return tp~=ep and Duel.GetCurrentChain()==0
end
-- 解放素材过滤：怪兽属于「王战」（0x134）字段或幻龙族种族时，可作为本效果的解放代价。
function c49275969.costfilter(c)
	return c:IsSetCard(0x134) or c:IsRace(RACE_WYRM)
end
-- 代价处理函数：发动时从自己场上选择并解放1只符合条件的「王战」或幻龙族怪兽，以此作为发动代价。
function c49275969.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认自己场上是否存在至少1只可解放且满足「王战」/幻龙族条件的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c49275969.costfilter,1,nil) end
	-- 实际发动时，从自己场上选择1只符合条件的可解放怪兽作为代价。
	local g=Duel.SelectReleaseGroup(tp,c49275969.costfilter,1,1,nil)
	-- 将选择的怪兽解放（REASON_COST），完成发动代价的支付。
	Duel.Release(g,REASON_COST)
end
-- 目标处理与信息登记：本效果不取对象，发动时登记将无效这次特殊召唤并破坏那些怪兽的信息。
function c49275969.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记无效召唤操作信息：将当前被特殊召唤的怪兽组（eg）作为无效召唤的对象，数量为eg中的怪兽数。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 登记破坏操作信息：将这些被特殊召唤的怪兽组（eg）作为破坏对象，数量为eg中的怪兽数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 效果处理函数：无效对方的那次特殊召唤，并将其中的怪兽破坏。
function c49275969.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 令这些正在特殊召唤的怪兽的召唤无效，使其特殊召唤不成功。
	Duel.NegateSummon(eg)
	-- 以效果破坏被无效召唤的怪兽，完成“那次特殊召唤无效，那些怪兽破坏”的处理。
	Duel.Destroy(eg,REASON_EFFECT)
end
