--メルフィー・パピィ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把怪兽召唤·特殊召唤的场合或者这张卡被选择作为对方怪兽的攻击对象的场合才能发动。这张卡回到手卡。那之后，可以把除「童话动物·小狗」外的1只2星以下的兽族怪兽从卡组特殊召唤。
-- ②：自己结束阶段才能发动。这张卡从手卡特殊召唤。
function c20003027.initial_effect(c)
	-- ①：对方把怪兽召唤·特殊召唤的场合或者这张卡被选择作为对方怪兽的攻击对象的场合才能发动。这张卡回到手卡。那之后，可以把除「童话动物·小狗」外的1只2星以下的兽族怪兽从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20003027,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,20003027)
	e1:SetCondition(c20003027.thcon)
	e1:SetTarget(c20003027.thtg)
	e1:SetOperation(c20003027.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetCondition(c20003027.thcon2)
	c:RegisterEffect(e3)
	-- ②：自己结束阶段才能发动。这张卡从手卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(20003027,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_HAND)
	e4:SetCountLimit(1,20003028)
	e4:SetCondition(c20003027.spcon)
	e4:SetTarget(c20003027.sptg)
	e4:SetOperation(c20003027.spop)
	c:RegisterEffect(e4)
end
-- 过滤函数，检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
function c20003027.cfilter(c,sp)
	return c:IsSummonPlayer(sp)
end
-- 检查是否有对方召唤成功的怪兽
function c20003027.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c20003027.cfilter,1,nil,1-tp)
end
-- 检查是否被对方怪兽选为攻击对象
function c20003027.thcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 返回此次战斗攻击的卡
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 设置连锁操作信息，将目标卡送回手牌
function c20003027.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置当前处理的连锁的操作信息此操作信息包含了效果处理中确定要处理的效果分类
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 过滤函数，检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
function c20003027.thfilter(c,e,tp)
	return c:IsRace(RACE_BEAST) and c:IsLevelBelow(2) and not c:IsCode(20003027) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 当满足条件时，将该卡送回手牌，并从卡组特殊召唤符合条件的怪兽
function c20003027.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否与效果相关并成功送回手牌且在手牌中
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_HAND)
		-- 判断目标玩家场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c20003027.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 询问玩家是否从卡组特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(20003027,2)) then  --"是否从卡组特殊召唤？"
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c20003027.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检查是否为当前回合玩家
function c20003027.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前的回合玩家
	return Duel.GetTurnPlayer()==tp
end
-- 设置连锁操作信息，将目标卡特殊召唤
function c20003027.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足特殊召唤的条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前处理的连锁的操作信息此操作信息包含了效果处理中确定要处理的效果分类
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 将该卡特殊召唤到场上
function c20003027.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 让玩家 sumplayer 以sumtype方式，pos表示形式把targets特殊召唤到target_player场上[的区域 zone]
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
