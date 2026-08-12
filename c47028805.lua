--Lマジマージ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段，这张卡在手卡存在的场合，把自己场上1只电子界族怪兽或连接怪兽解放才能发动。这张卡特殊召唤。
-- ②：这张卡的攻击力上升自己墓地的连接怪兽的连接标记合计×400。
local s,id,o=GetID()
-- 创建效果，注册①效果和②效果
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段，这张卡在手卡存在的场合，把自己场上1只电子界族怪兽或连接怪兽解放才能发动。这张卡特殊召唤。
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
-- 判断当前是否为自己的主要阶段1或主要阶段2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 过滤满足条件的怪兽（连接怪兽或电子界族怪兽）且该怪兽所在区域有空位
function s.cfilter(c,tp)
	return (c:IsType(TYPE_LINK) or c:IsRace(RACE_CYBERSE))
		-- 确保该怪兽在场上有可用的怪兽区
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsFaceup() or c:IsControler(tp))
end
-- 检查是否可以支付解放费用并选择解放对象
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测是否存在可解放的满足条件的卡
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,tp) end
	-- 选择一张满足条件的卡进行解放
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,tp)
	-- 将选中的卡以代价形式解放
	Duel.Release(g,REASON_COST)
end
-- 设置特殊召唤的目标和操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以正面表示形式特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤墓地中的连接怪兽
function s.atkfilter(c)
	return c:IsType(TYPE_LINK)
end
-- 计算墓地中所有连接怪兽的连接标记总和并乘以400作为攻击力加成
function s.atkval(e,c)
	-- 获取玩家墓地中所有连接怪兽组成的组
	local g=Duel.GetMatchingGroup(s.atkfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
	return g:GetSum(Card.GetLink)*400
end
