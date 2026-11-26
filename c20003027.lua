--メルフィー・パピィ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把怪兽召唤·特殊召唤的场合或者这张卡被选择作为对方怪兽的攻击对象的场合才能发动。这张卡回到手卡。那之后，可以把除「童话动物·小狗」外的1只2星以下的兽族怪兽从卡组特殊召唤。
-- ②：自己结束阶段才能发动。这张卡从手卡特殊召唤。
function c20003027.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：对方把怪兽召唤·特殊召唤的场合或者这张卡被选择作为对方怪兽的攻击对象的场合才能发动。这张卡回到手卡。那之后，可以把除「童话动物·小狗」外的1只2星以下的兽族怪兽从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20003027,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
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
	-- 这个卡名的①②的效果1回合各能使用1次。②：自己结束阶段才能发动。这张卡从手卡特殊召唤。
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
-- 过滤是否为指定玩家sp所召唤或特殊召唤的怪兽
function c20003027.cfilter(c,sp)
	return c:IsSummonPlayer(sp)
end
-- 检查①效果的召唤触发条件：在本次召唤/特召事件中是否存在由对方玩家召唤或特召的怪兽
function c20003027.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c20003027.cfilter,1,nil,1-tp)
end
-- 检查①效果的被攻击触发条件：发起此次攻击的怪兽当前控制者是否为对方玩家
function c20003027.thcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断此次战斗的攻击怪兽是否由对方控制
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 发动前确认此卡能否返回手卡，并登记将此卡送回手卡的操作信息
function c20003027.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 登记将此卡自身送回手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 过滤卡组中除「童话动物·小狗」外、2星以下的兽族且可特殊召唤的怪兽
function c20003027.thfilter(c,e,tp)
	return c:IsRace(RACE_BEAST) and c:IsLevelBelow(2) and not c:IsCode(20003027) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果处理：将此卡送回手卡并确认已回到手卡后，若场上还有空位且卡组有符合条件的兽族怪兽，可选择其中1只表侧表示特殊召唤
function c20003027.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡与效果关联后将其以效果送回手卡，并验证其已成功回到手卡
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_HAND)
		-- 检查己方怪兽区是否至少有1个可用空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方卡组是否存在至少1只符合条件的2星以下兽族怪兽
		and Duel.IsExistingMatchingCard(c20003027.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 询问己方玩家是否从卡组特殊召唤1只符合条件的怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(20003027,2)) then  --"是否从卡组特殊召唤？"
		-- 插入效果处理间断，使此卡回手与后续卡组特殊召唤视为不同时处理
		Duel.BreakEffect()
		-- 向己方发送从卡组选择要特殊召唤的怪兽的提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让己方从卡组选择1只除「童话动物·小狗」外的2星以下兽族怪兽
		local g=Duel.SelectMatchingCard(tp,c20003027.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		-- 将选中的怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检查②效果发动条件：当前是否为己方回合
function c20003027.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前的回合玩家是否为己方
	return Duel.GetTurnPlayer()==tp
end
-- 发动前确认己方怪兽区有空位且手卡的此卡可以特殊召唤，并登记特召操作信息
function c20003027.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查己方怪兽区是否有空位且此卡能否被特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记将此卡自身特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果处理：若此卡仍在手卡并与效果关联，将其表侧表示特殊召唤到己方场上
function c20003027.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
