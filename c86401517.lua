--嵐竜の聖騎士
-- 效果：
-- 「电脑网仪式」降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡向怪兽攻击的伤害步骤开始时才能发动。那只怪兽回到持有者手卡。
-- ②：把这张卡解放才能发动。从手卡·卡组把1只5星以上的电子界族怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能把效果发动。
function c86401517.initial_effect(c)
	-- 将「电脑网仪式」卡片密码（34767865）添加到该卡的关系代码列表中，以在规则层面表明该卡上记载了其卡名。
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
	-- ②：把这张卡解放才能发动。从手手卡·卡组把1只5星以上的电子界族怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能把效果发动。
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
-- 效果①的发动准备：获取攻击的目标怪兽，并确认此卡是攻击方、有可返回手牌的目标，同时设定回手牌的操作信息。
function c86401517.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取作为攻击目标的怪兽卡。
	local d=Duel.GetAttackTarget()
	-- 在伤害步骤开始时，判断这张卡是否是攻击方，且是否存在可被返回手牌的对方防守怪兽。
	if chk==0 then return Duel.GetAttacker()==c and d and d:IsAbleToHand() end
	-- 设置操作信息：将作为攻击目标的怪兽返回持有者手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,d,1,0,0)
end
-- 效果①的效果处理：若该战斗目标怪兽存在且仍在战斗中，则将其送回持有者的手牌。
function c86401517.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为战斗攻击目标的怪兽。
	local d=Duel.GetAttackTarget()
	if d and d:IsRelateToBattle() then
		-- 将该怪兽送回持有者手牌。
		Duel.SendtoHand(d,nil,REASON_EFFECT)
	end
end
-- 效果②的支付代价：检查怪兽区域可用空位数以及此卡是否可被解放，并将其解放。
function c86401517.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动时判断解放此卡后玩家的场上是否有可以用于召唤的怪兽格，且此卡是否能够被解放。
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0 and c:IsReleasable() end
	-- 将作为代价的该怪兽卡解放。
	Duel.Release(c,REASON_COST)
end
-- 过滤条件：手牌或卡组中5星以上的电子界族怪兽且满足特殊召唤的条件。
function c86401517.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查手牌或卡组中是否存在符合条件的特殊召唤怪兽，并设置特殊召唤的操作信息。
function c86401517.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断手牌或卡组中是否存在符合特殊召唤条件的5星以上电子界族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c86401517.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：从手牌或卡组中特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果②的效果处理：在空位足够的情况下，从手牌或卡组选择1只5星以上电子界族怪兽特殊召唤到自己场上，并使其在本回合内无法发动效果。
function c86401517.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽区域是否还有可用的空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示消息，提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或卡组中选择1只符合过滤条件的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c86401517.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 如果成功获取所选怪兽且顺利进行特殊召唤的步骤。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽在这个回合不能把效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤的过程。
	Duel.SpecialSummonComplete()
end
