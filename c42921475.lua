--妖精伝姫－ターリア
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡反转的场合才能发动。从手卡把1只怪兽特殊召唤。
-- ②：对方把通常魔法·通常陷阱卡发动时，把自己场上1只其他怪兽解放才能发动。那个效果变成「对方场上1只表侧表示怪兽变成里侧守备表示」。
function c42921475.initial_effect(c)
	-- ①：这张卡反转的场合才能发动。从手卡把1只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42921475,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c42921475.sptg)
	e1:SetOperation(c42921475.spop)
	c:RegisterEffect(e1)
	-- ②：对方把通常魔法·通常陷阱卡发动时，把自己场上1只其他怪兽解放才能发动。那个效果变成「对方场上1只表侧表示怪兽变成里侧守备表示」。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42921475,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,42921475)
	e2:SetCondition(c42921475.chcon)
	e2:SetCost(c42921475.chcost)
	e2:SetTarget(c42921475.chtg)
	e2:SetOperation(c42921475.chop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否存在可以特殊召唤的怪兽
function c42921475.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤的条件，包括场上是否有空位和手卡中是否存在可特殊召唤的怪兽
function c42921475.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡中是否存在可特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c42921475.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 处理特殊召唤效果，从手卡选择怪兽并特殊召唤
function c42921475.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c42921475.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断对方发动的是通常魔法或通常陷阱卡
function c42921475.chcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==1-tp and (rc:GetType()==TYPE_SPELL or rc:GetType()==TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 过滤函数，用于判断场上怪兽是否未被战斗破坏
function c42921475.cfilter(c)
	return not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 处理解放怪兽作为费用
function c42921475.chcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c42921475.cfilter,1,e:GetHandler()) end
	-- 选择满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c42921475.cfilter,1,1,e:GetHandler())
	-- 将选中的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 过滤函数，用于判断对方场上的表侧表示怪兽是否可以变为里侧守备表示
function c42921475.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 判断对方场上是否存在满足条件的表侧表示怪兽
function c42921475.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方场上是否存在满足条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c42921475.filter,rp,0,LOCATION_MZONE,1,nil) end
end
-- 处理连锁效果的改变，将目标改为对方场上的怪兽
function c42921475.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 将连锁效果的目标改为对方场上的怪兽
	Duel.ChangeTargetCard(ev,g)
	-- 将连锁效果的处理函数改为改变怪兽表示形式
	Duel.ChangeChainOperation(ev,c42921475.repop)
end
-- 处理连锁效果的改变，选择对方场上的怪兽并将其变为里侧守备表示
function c42921475.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上的表侧表示怪兽
	local g=Duel.SelectMatchingCard(tp,c42921475.filter,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽变为里侧守备表示
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
