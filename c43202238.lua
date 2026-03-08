--邪竜星－ガイザー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：场上的这张卡不会成为对方的效果的对象。
-- ②：以自己场上1只「龙星」怪兽和对方场上1张卡为对象才能发动。那些卡破坏。
-- ③：自己场上的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把1只幻龙族怪兽守备表示特殊召唤。
function c43202238.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：场上的这张卡不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置效果值为aux.tgoval函数，用于判断是否成为对方效果的对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只「龙星」怪兽和对方场上1张卡为对象才能发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43202238,0))  --"卡片破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,43202238)
	e2:SetTarget(c43202238.destg)
	e2:SetOperation(c43202238.desop)
	c:RegisterEffect(e2)
	-- ③：自己场上的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把1只幻龙族怪兽守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43202238,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1,43202239)
	e3:SetCondition(c43202238.spcon)
	e3:SetTarget(c43202238.sptg)
	e3:SetOperation(c43202238.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选场上正面表示的「龙星」怪兽
function c43202238.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9e)
end
-- 效果处理时的判断条件，检查是否满足选择目标的条件
function c43202238.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在至少1只正面表示的「龙星」怪兽
	if chk==0 then return Duel.IsExistingTarget(c43202238.desfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少1张卡
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只正面表示的「龙星」怪兽作为目标
	local g1=Duel.SelectTarget(tp,c43202238.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为目标
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置连锁操作信息，指定将要破坏的2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 效果处理函数，获取连锁中的目标卡组并进行破坏
function c43202238.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将目标卡组中的卡以效果原因进行破坏
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- 效果发动条件函数，判断该卡是否因破坏而进入墓地且为己方控制
function c43202238.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数，用于筛选可以特殊召唤的幻龙族怪兽
function c43202238.spfilter(c,e,tp)
	return c:IsRace(RACE_WYRM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤效果处理时的判断条件，检查是否有满足条件的卡可以特殊召唤
function c43202238.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方卡组中是否存在满足条件的幻龙族怪兽
		and Duel.IsExistingMatchingCard(c43202238.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，指定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果处理函数，从卡组选择幻龙族怪兽进行特殊召唤
function c43202238.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方卡组中选择1只幻龙族怪兽作为特殊召唤目标
	local g=Duel.SelectMatchingCard(tp,c43202238.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡以守备表示特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
