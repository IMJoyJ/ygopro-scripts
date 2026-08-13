--Lマジマージ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段，这张卡在手卡存在的场合，把自己场上1只电子界族怪兽或连接怪兽解放才能发动。这张卡特殊召唤。
-- ②：这张卡的攻击力上升自己墓地的连接怪兽的连接标记合计×400。
local s,id,o=GetID()
-- 在卡的初始化时注册两个效果：①效果为手牌中可在自己·对方主要阶段发动的诱发即时效果，通过解放自己场上1只电子界族或连接怪兽来把自身特殊召唤，且1回合只能使用1次；②效果为自身在怪兽区表侧表示存在时，攻击力上升自己墓地连接怪兽连接标记合计×400的永续效果。
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己·对方的主要阶段，这张卡在手卡存在的场合，把自己场上1只电子界族怪兽或连接怪兽解放才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升自己墓地的连接怪兽的连接标记合计×400。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：只有在主要阶段1或主要阶段2（即自己·对方的主要阶段）时才能发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于判断是否处于主要阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 解放代价的筛选条件：被解放的怪兽必须是连接怪兽或电子界族怪兽；且解放后自己场上仍有怪兽区可空出用于特殊召唤；同时该怪兽为表侧表示或由自己控制，确保是可解放的对象。
function s.cfilter(c,tp)
	return (c:IsType(TYPE_LINK) or c:IsRace(RACE_CYBERSE))
		-- 并且检查解放该怪兽后自己场上是否有空的怪兽区；以及该怪兽要么是表侧表示、要么由自己控制，才能作为解放代价。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsFaceup() or c:IsControler(tp))
end
-- ①效果的解放代价处理：发动时先检查是否有满足条件的怪兽可解放；然后选择自己场上1只连接怪兽或电子界族怪兽进行解放，以支付特殊召唤的代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在合法性检查阶段（chk==0），返回自己场上是否存在至少1只满足cfilter条件的可解放怪兽，以判断能否支付解放代价。
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,tp) end
	-- 从自己场上选择恰好1只满足cfilter条件的怪兽作为要解放的代价。
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,tp)
	-- 将选择到的怪兽以解放代价（REASON_COST）方式解放，完成COST支付。
	Duel.Release(g,REASON_COST)
end
-- ①效果的无对象目标处理：在检查阶段确认这张卡能够被特殊召唤；随后设置操作信息，表明本次效果将把这张卡特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次连锁要处理的分类为特殊召唤，对象为本卡，数量为1，供系统进行连锁判定与效果处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果实际处理：取得这张卡，确认它仍与本次效果关联（未离场导致关系重置）后，将其特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以sumtype=0、需检查召唤条件与苏生限制、表侧表示的形式，特殊召唤到tp的场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果使用的墓地筛选条件：只选择连接怪兽。
function s.atkfilter(c)
	return c:IsType(TYPE_LINK)
end
-- ②效果的攻击力上升值计算：取自己墓地的全部连接怪兽，将每只的连接标记数值求和后乘以400，作为攻击力增加量。
function s.atkval(e,c)
	-- 获取自己墓地中满足atkfilter（连接怪兽）的全部卡，用于计算连接标记合计。
	local g=Duel.GetMatchingGroup(s.atkfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
	return g:GetSum(Card.GetLink)*400
end
