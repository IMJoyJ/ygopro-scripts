--Evil★Twin リィラ
-- 效果：
-- 包含「璃拉」怪兽的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，若自己场上有「姬丝基勒」怪兽存在，以场上1张卡为对象才能发动。那张卡破坏。
-- ②：自己·对方的主要阶段，自己场上没有「姬丝基勒」怪兽存在的场合才能发动。从自己墓地把1只「姬丝基勒」怪兽特殊召唤。这个回合，自己不是恶魔族怪兽不能从额外卡组特殊召唤。
function c36609518.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用2个连接素材，且连接素材必须包含「璃拉」怪兽
	aux.AddLinkProcedure(c,nil,2,2,c36609518.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合，若自己场上有「姬丝基勒」怪兽存在，以场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36609518,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_ACTIVATE_CONDITION)
	e1:SetCountLimit(1,36609518)
	e1:SetCondition(c36609518.descon)
	e1:SetTarget(c36609518.destg)
	e1:SetOperation(c36609518.desop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段，自己场上没有「姬丝基勒」怪兽存在的场合才能发动。从自己墓地把1只「姬丝基勒」怪兽特殊召唤。这个回合，自己不是恶魔族怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36609518,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,36609519)
	e2:SetCondition(c36609518.spcon)
	e2:SetTarget(c36609518.sptg)
	e2:SetOperation(c36609518.spop)
	c:RegisterEffect(e2)
end
-- 连接素材必须包含「璃拉」怪兽
function c36609518.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x153)
end
-- 过滤器函数，用于判断场上是否有「姬丝基勒」怪兽
function c36609518.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x152)
end
-- 效果条件函数，判断自己场上是否存在「姬丝基勒」怪兽
function c36609518.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在「姬丝基勒」怪兽
	return Duel.IsExistingMatchingCard(c36609518.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果目标函数，选择场上1张卡作为破坏对象
function c36609518.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在至少1张卡可以作为破坏对象
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，指定破坏对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数，将目标卡破坏
function c36609518.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的破坏对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果条件函数，判断是否在主要阶段且自己场上没有「姬丝基勒」怪兽
function c36609518.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己的主要阶段
	return (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
		-- 判断自己场上不存在「姬丝基勒」怪兽
		and not Duel.IsExistingMatchingCard(c36609518.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤器函数，用于筛选可以特殊召唤的「姬丝基勒」怪兽
function c36609518.spfilter(c,e,tp)
	return c:IsSetCard(0x152) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标函数，检查是否有可特殊召唤的「姬丝基勒」怪兽
function c36609518.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上是否有足够的召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的「姬丝基勒」怪兽
		and Duel.IsExistingMatchingCard(c36609518.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果操作信息，指定特殊召唤对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理函数，从墓地特殊召唤「姬丝基勒」怪兽并设置后续限制
function c36609518.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有足够的召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择墓地中的「姬丝基勒」怪兽进行特殊召唤
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c36609518.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 设置永续效果，限制自己不能从额外卡组特殊召唤非恶魔族怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c36609518.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家环境中
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的目标函数，禁止非恶魔族怪兽从额外卡组特殊召唤
function c36609518.splimit(e,c)
	return not c:IsRace(RACE_FIEND) and c:IsLocation(LOCATION_EXTRA)
end
