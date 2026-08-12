--メルフィー・フェニィ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方对怪兽的召唤·特殊召唤成功的场合或者这张卡被选择作为对方怪兽的攻击对象的场合才能发动。这张卡回到持有者手卡。那之后，可以从手卡把「童话动物·小阔耳狐」以外的1只兽族怪兽特殊召唤。
-- ②：自己结束阶段才能发动。这张卡从手卡特殊召唤。
function c57523313.initial_effect(c)
	-- ①：对方对怪兽的召唤·特殊召唤成功的场合或者这张卡被选择作为对方怪兽的攻击对象的场合才能发动。这张卡回到持有者手卡。那之后，可以从手卡把「童话动物·小阔耳狐」以外的1只兽族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57523313,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,57523313)
	e1:SetCondition(c57523313.thcon)
	e1:SetTarget(c57523313.thtg)
	e1:SetOperation(c57523313.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetCondition(c57523313.thcon2)
	c:RegisterEffect(e3)
	-- ②：自己结束阶段才能发动。这张卡从手卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(57523313,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_HAND)
	e4:SetCountLimit(1,57523314)
	e4:SetCondition(c57523313.spcon)
	e4:SetTarget(c57523313.sptg)
	e4:SetOperation(c57523313.spop)
	c:RegisterEffect(e4)
end
-- 过滤召唤·特殊召唤怪兽的玩家是否为指定玩家的辅助过滤函数
function c57523313.cfilter(c,sp)
	return c:IsSummonPlayer(sp)
end
-- 检查对方是否成功召唤·特殊召唤了怪兽，作为效果①的发动条件
function c57523313.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c57523313.cfilter,1,nil,1-tp)
end
-- 检查攻击怪兽的控制者是否为对方，作为被选择作为攻击对象时效果①的发动条件
function c57523313.thcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 返回攻击怪兽的控制者是否为对方
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 效果①的发动准备（检查自身是否能回到手卡，并设置操作信息为回手卡）
function c57523313.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置连锁处理的操作信息为将自身送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 过滤手卡中除「童话动物·小阔耳狐」以外可以特殊召唤的兽族怪兽的辅助过滤函数
function c57523313.thfilter(c,e,tp)
	return c:IsRace(RACE_BEAST) and not c:IsCode(57523313) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的实际处理（自身回手卡，之后可选择从手卡特殊召唤1只除同名卡以外的兽族怪兽）
function c57523313.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果关联，并成功通过效果回到手卡且目前在手卡中
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_HAND)
		-- 检查自己场上是否有可用的怪兽区域空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足特殊召唤条件的兽族怪兽（除同名卡外）
		and Duel.IsExistingMatchingCard(c57523313.thfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 询问玩家是否选择从手卡特殊召唤怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(57523313,2)) then  --"是否从手卡特殊召唤？"
		-- 中断当前效果处理，使后续的特殊召唤处理与回手卡不视为同时处理（会造成错时点）
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡选择1张满足条件的兽族怪兽
		local g=Duel.SelectMatchingCard(tp,c57523313.thfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件（必须是自己的回合）
function c57523313.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 效果②的发动准备（检查自身是否能特殊召唤，并设置特殊召唤的操作信息）
function c57523313.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用怪兽区域空格，且自身是否能特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的实际处理（将自身特殊召唤）
function c57523313.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
