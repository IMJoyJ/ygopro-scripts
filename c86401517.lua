--嵐竜の聖騎士
-- 效果：
-- 「电脑网仪式」降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡向怪兽攻击的伤害步骤开始时才能发动。那只怪兽回到持有者手卡。
-- ②：把这张卡解放才能发动。从手卡·卡组把1只5星以上的电子界族怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能把效果发动。
function c86401517.initial_effect(c)
	aux.AddCodeList(c,34767865)
	c:EnableReviveLimit()
	-- ①：这张卡向怪兽攻击的伤害步骤开始时才能发动。那只怪兽回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86401517,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCountLimit(1,86401517)
	e1:SetTarget(c86401517.thtg)
	e1:SetOperation(c86401517.thop)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放才能发动。从手卡·卡组把1只5星以上的电子界族怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能把效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86401517,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,86401518)
	e2:SetCost(c86401517.spcost)
	e2:SetTarget(c86401517.sptg)
	e2:SetOperation(c86401517.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动准备：检查自身是否进行攻击，且对方怪兽是否能回到手卡
function c86401517.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取当前战斗的守备侧怪兽（被攻击的怪兽）
	local d=Duel.GetAttackTarget()
	-- 作为发动条件，检查自身是否为攻击怪兽，且存在可以回到手卡的攻击对象
	if chk==0 then return Duel.GetAttacker()==c and d and d:IsAbleToHand() end
	-- 设置操作信息：将1个怪兽送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,d,1,0,0)
end
-- ①效果的处理：将进行战斗的对方怪兽送回持有者手卡
function c86401517.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的守备侧怪兽（被攻击的怪兽）
	local d=Duel.GetAttackTarget()
	if d and d:IsRelateToBattle() then
		-- 将目标怪兽送回持有者手卡
		Duel.SendtoHand(d,nil,REASON_EFFECT)
	end
end
-- ②效果的发动代价：解放自身
function c86401517.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 作为发动条件，检查自身解放后是否有可用的怪兽区域，且自身是否可以被解放
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0 and c:IsReleasable() end
	-- 解放自身
	Duel.Release(c,REASON_COST)
end
-- 过滤条件：手卡·卡组中5星以上的电子界族怪兽
function c86401517.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动准备：检查手卡·卡组是否存在可特殊召唤的怪兽
function c86401517.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 作为发动条件，检查手卡或卡组中是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c86401517.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- ②效果的处理：从手卡·卡组特殊召唤1只5星以上的电子界族怪兽，并使其本回合不能发动效果
function c86401517.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或卡组中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c86401517.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 如果成功将选中的怪兽以表侧表示进行特殊召唤的准备步骤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽在这个回合不能把效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
