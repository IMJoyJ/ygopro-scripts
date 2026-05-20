--占い魔女 チーちゃん
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡抽到时，把这张卡给对方观看才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡从手卡的特殊召唤成功的场合才能发动。双方玩家各自从卡组抽1张。
function c68078978.initial_effect(c)
	-- ①：把这张卡抽到时，把这张卡给对方观看才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68078978,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DRAW)
	e1:SetCountLimit(1,68078978)
	e1:SetCost(c68078978.spcost)
	e1:SetTarget(c68078978.sptg)
	e1:SetOperation(c68078978.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡的特殊召唤成功的场合才能发动。双方玩家各自从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68078978,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,68078979)
	e2:SetCondition(c68078978.drcon)
	e2:SetTarget(c68078978.drtg)
	e2:SetOperation(c68078978.drop)
	c:RegisterEffect(e2)
end
-- ①号效果的Cost：检查手卡中的这张卡是否未公开（用于给对方观看）
function c68078978.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- ①号效果的Target：检查自身是否可以特殊召唤，并设置特殊召唤的操作信息
function c68078978.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息（将自身特殊召唤1只）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①号效果的Operation：将手卡的这张卡特殊召唤
function c68078978.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②号效果的Condition：检查这张卡是否是从手卡特殊召唤成功的
function c68078978.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- ②号效果的Target：检查双方是否都能抽卡，并设置抽卡的操作信息
function c68078978.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方玩家是否都可以从卡组抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
	-- 设置抽卡的操作信息（双方玩家各抽1张卡）
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
-- ②号效果的Operation：双方玩家各自从卡组抽1张卡
function c68078978.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 自己从卡组抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
	-- 对方从卡组抽1张卡
	Duel.Draw(1-tp,1,REASON_EFFECT)
end
