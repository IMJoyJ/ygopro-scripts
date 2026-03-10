--水晶機巧－ハリファイバー
-- 效果：
-- 包含调整的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。从手卡·卡组把1只3星以下的调整守备表示特殊召唤。这个效果特殊召唤的怪兽在这个回合不能把效果发动。
-- ②：对方的主要阶段以及战斗阶段把场上的这张卡除外才能发动。从额外卡组把1只同调怪兽调整当作同调召唤作特殊召唤。
function c50588353.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用2个连接素材，且必须包含调整怪兽
	aux.AddLinkProcedure(c,nil,2,2,c50588353.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤成功的场合才能发动。从手卡·卡组把1只3星以下的调整守备表示特殊召唤。这个效果特殊召唤的怪兽在这个回合不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50588353,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,50588353)
	e1:SetCondition(c50588353.hspcon)
	e1:SetTarget(c50588353.hsptg)
	e1:SetOperation(c50588353.hspop)
	c:RegisterEffect(e1)
	-- ②：对方的主要阶段以及战斗阶段把场上的这张卡除外才能发动。从额外卡组把1只同调怪兽调整当作同调召唤作特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50588353,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,50588354)
	e2:SetCondition(c50588353.spcon)
	-- 设置效果发动时需要将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c50588353.sptg)
	e2:SetOperation(c50588353.spop)
	c:RegisterEffect(e2)
end
-- 连接素材检查函数，确保连接素材中包含调整怪兽
function c50588353.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_TUNER)
end
-- 效果发动条件判断，确认此卡是通过连接召唤方式出场的
function c50588353.hspcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 筛选满足条件的调整怪兽，等级不超过3星且可以守备表示特殊召唤
function c50588353.hspfilter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果发动时的检查条件，确认场上存在可特殊召唤的调整怪兽
function c50588353.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查目标玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或卡组中是否存在满足条件的调整怪兽
		and Duel.IsExistingMatchingCard(c50588353.hspfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤一张来自手牌或卡组的调整怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 执行效果处理，选择并特殊召唤符合条件的调整怪兽，并使其在本回合不能发动效果
function c50588353.hspop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查目标玩家场上是否有空位，若无则不继续处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或卡组中选择一张满足条件的调整怪兽
	local g=Duel.SelectMatchingCard(tp,c50588353.hspfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤步骤，并为该怪兽添加不能发动效果的限制
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 为特殊召唤的调整怪兽添加效果，使其在本回合不能发动效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 判断是否可以发动效果，条件为当前不是自己的回合且处于主要阶段或战斗阶段
function c50588353.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 确认当前回合玩家不是自己
	return Duel.GetTurnPlayer()~=tp
		and (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
end
-- 筛选满足条件的同调怪兽调整，可特殊召唤且有足够空位
function c50588353.spfilter(c,e,tp,mc)
	return c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 检查目标玩家额外卡组是否有足够的空位来特殊召唤该同调怪兽
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置效果发动时的检查条件，确认额外卡组中存在满足条件的同调怪兽调整
function c50588353.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤所需的素材要求
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查额外卡组中是否存在满足条件的同调怪兽调整
		and Duel.IsExistingMatchingCard(c50588353.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置连锁操作信息，表示将要从额外卡组特殊召唤一只同调怪兽调整
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行效果处理，选择并特殊召唤符合条件的同调怪兽调整
function c50588353.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足特殊召唤所需的素材要求，若不满足则不继续处理
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择一只满足条件的同调怪兽调整
	local tc=Duel.SelectMatchingCard(tp,c50588353.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil):GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 执行特殊召唤操作，将该同调怪兽调整以同调召唤方式特殊召唤
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	end
end
