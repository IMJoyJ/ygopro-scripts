--Evil★Twin キスキル
-- 效果：
-- 包含「姬丝基勒」怪兽的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，若自己场上有「璃拉」怪兽存在则能发动。自己抽1张。
-- ②：自己·对方的主要阶段，自己场上没有「璃拉」怪兽存在的场合才能发动。从自己墓地把1只「璃拉」怪兽特殊召唤。这个回合，自己不是恶魔族怪兽不能从额外卡组特殊召唤。
function c9205573.initial_effect(c)
	-- 设置连接召唤手续：需要2只怪兽作为素材，且必须包含「姬丝基勒」怪兽
	aux.AddLinkProcedure(c,nil,2,2,c9205573.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合，若自己场上有「璃拉」怪兽存在则能发动。自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9205573,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_ACTIVATE_CONDITION)
	e1:SetCountLimit(1,9205573)
	e1:SetCondition(c9205573.drcon)
	e1:SetTarget(c9205573.drtg)
	e1:SetOperation(c9205573.drop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段，自己场上没有「璃拉」怪兽存在的场合才能发动。从自己墓地把1只「璃拉」怪兽特殊召唤。这个回合，自己不是恶魔族怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9205573,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,92055734)
	e2:SetCondition(c9205573.spcon)
	e2:SetTarget(c9205573.sptg)
	e2:SetOperation(c9205573.spop)
	c:RegisterEffect(e2)
end
-- 检查连接素材中是否包含至少1只「姬丝基勒」怪兽
function c9205573.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x152)
end
-- 过滤条件：自己场上表侧表示的「璃拉」怪兽
function c9205573.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x153)
end
-- 抽卡效果的发动条件：自己场上存在表侧表示的「璃拉」怪兽
function c9205573.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「璃拉」怪兽
	return Duel.IsExistingMatchingCard(c9205573.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 抽卡效果的靶向处理：检查并设置抽卡玩家和抽卡数量（1张）
function c9205573.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果处理的对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的对象参数为1（抽卡张数）
	Duel.SetTargetParam(1)
	-- 设置连锁的操作信息：动作为抽卡，数量为1张
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的具体执行：让目标玩家抽指定张数的卡
function c9205573.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 特殊召唤效果的发动条件：自己或对方的主要阶段，且自己场上没有「璃拉」怪兽
function c9205573.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1或主要阶段2
	return (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
		-- 检查自己场上是否不存在表侧表示的「璃拉」怪兽
		and not Duel.IsExistingMatchingCard(c9205573.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：可以被特殊召唤的「璃拉」怪兽
function c9205573.spfilter(c,e,tp)
	return c:IsSetCard(0x153) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的靶向处理：检查怪兽区域空位及墓地中是否存在可特召的「璃拉」怪兽，并设置操作信息
function c9205573.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足特召条件的「璃拉」怪兽
		and Duel.IsExistingMatchingCard(c9205573.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁的操作信息：动作为从墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 特殊召唤效果的具体执行：选择并特殊召唤墓地的「璃拉」怪兽，并适用本回合不能从额外卡组特召恶魔族以外怪兽的限制
function c9205573.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从墓地选择1只满足特召条件且不受王家长眠之谷影响的「璃拉」怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c9205573.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是恶魔族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c9205573.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该限制效果，使其对玩家生效
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件的具体内容：不能从额外卡组特殊召唤恶魔族以外的怪兽
function c9205573.splimit(e,c)
	return not c:IsRace(RACE_FIEND) and c:IsLocation(LOCATION_EXTRA)
end
