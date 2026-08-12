--天球の聖刻印
-- 效果：
-- 龙族怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方回合1次，这张卡在额外怪兽区域存在的场合，把自己的手卡·场上1只怪兽解放才能发动。场上1张表侧表示卡回到手卡。
-- ②：这张卡被解放的场合发动。从手卡·卡组把1只龙族怪兽攻击力·守备力变成0特殊召唤。
function c24361622.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用2只龙族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_DRAGON),2,2)
	-- ①：对方回合1次，这张卡在额外怪兽区域存在的场合，把自己的手卡·场上1只怪兽解放才能发动。场上1张表侧表示卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24361622,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c24361622.thcon)
	e1:SetCost(c24361622.thcost)
	e1:SetTarget(c24361622.thtg)
	e1:SetOperation(c24361622.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡被解放的场合发动。从手卡·卡组把1只龙族怪兽攻击力·守备力变成0特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24361622,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,24361622)
	e2:SetTarget(c24361622.sptg)
	e2:SetOperation(c24361622.spop)
	c:RegisterEffect(e2)
end
-- 效果发动条件：卡片在额外怪兽区域且当前回合不是玩家回合
function c24361622.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 卡片在额外怪兽区域且当前回合不是玩家回合
	return e:GetHandler():GetSequence()>4 and Duel.GetTurnPlayer()~=tp
end
-- 解放卡的过滤函数：满足是怪兽且场上存在可返回手卡的表侧表示卡
function c24361622.thcfilter(c,tp)
	return c:IsType(TYPE_MONSTER)
		-- 场上存在可返回手卡的表侧表示卡
		and Duel.IsExistingMatchingCard(c24361622.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 返回手卡卡的过滤函数：满足是表侧表示且能返回手卡
function c24361622.thfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 效果发动费用：选择1只满足条件的怪兽进行解放
function c24361622.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,c24361622.thcfilter,1,REASON_COST,true,nil,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择满足条件的1只怪兽进行解放
	local g=Duel.SelectReleaseGroupEx(tp,c24361622.thcfilter,1,1,REASON_COST,true,nil,tp)
	-- 执行解放操作
	Duel.Release(g,REASON_COST)
end
-- 设置效果发动的目标：选择1张场上表侧表示卡返回手卡
function c24361622.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：目标为场上的1张卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_ONFIELD)
end
-- 效果发动处理：选择1张场上表侧表示卡返回手卡
function c24361622.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择1张场上表侧表示卡
	local g=Duel.SelectMatchingCard(tp,c24361622.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡返回手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 特殊召唤卡的过滤函数：满足是龙族且能特殊召唤
function c24361622.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果发动的目标：从手卡或卡组选择1只龙族怪兽特殊召唤
function c24361622.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：目标为手卡或卡组的1只龙族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果发动处理：从手卡或卡组选择1只龙族怪兽特殊召唤并将其攻守变为0
function c24361622.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的特殊召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或卡组选择1只龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c24361622.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 执行特殊召唤操作
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 将特殊召唤的怪兽攻守变为0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
