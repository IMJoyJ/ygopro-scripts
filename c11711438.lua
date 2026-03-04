--戦華史略－三顧礼迎
-- 效果：
-- 这张卡发动后，第2次的自己准备阶段送去墓地。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段，自己对「战华」怪兽的召唤·特殊召唤成功的场合，以那1只怪兽为对象才能发动。和那只怪兽卡名不同的1只「战华」怪兽从卡组加入手卡。
-- ②：这张卡从魔法与陷阱区域送去墓地的场合才能发动。从手卡把1只「战华」怪兽特殊召唤。
function c11711438.initial_effect(c)
	-- 这张卡发动后，第2次的自己准备阶段送去墓地。这个卡名的①②的效果1回合各能使用1次。
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(11711438,0))
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetTarget(c11711438.target)
	c:RegisterEffect(e0)
	-- 自己主要阶段，自己对「战华」怪兽的召唤·特殊召唤成功的场合，以那1只怪兽为对象才能发动。和那只怪兽卡名不同的1只「战华」怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11711438,1))  --"卡组检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,11711438)
	e1:SetCondition(c11711438.thcon)
	e1:SetTarget(c11711438.thtg)
	e1:SetOperation(c11711438.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 这张卡从魔法与陷阱区域送去墓地的场合才能发动。从手卡把1只「战华」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(11711438,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,11711439)
	e3:SetCondition(c11711438.spcon)
	e3:SetTarget(c11711438.sptg)
	e3:SetOperation(c11711438.spop)
	c:RegisterEffect(e3)
end
-- 设置该卡发动时的处理逻辑，包括创建一个用于记录准备阶段次数的持续效果。
function c11711438.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 创建一个在准备阶段触发的持续效果，用于记录该卡已进入准备阶段的次数。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c11711438.stgcon)
	e1:SetOperation(c11711438.stgop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
	c:SetTurnCounter(0)
	c:RegisterEffect(e1)
end
-- 判断当前是否为该卡的持有者回合。
function c11711438.stgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为效果持有者。
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段效果的处理函数，用于增加计数器并判断是否满足条件。
function c11711438.stgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 then
		-- 当计数器达到2时，将该卡因规则送去墓地。
		Duel.SendtoGrave(c,REASON_RULE)
	end
end
-- 判断目标怪兽是否为「战华」怪兽且为当前玩家召唤或特殊召唤成功。
function c11711438.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x137) and c:IsSummonPlayer(tp)
end
-- 判断目标怪兽是否满足检索条件，即为「战华」怪兽且其卡号与目标怪兽不同。
function c11711438.tgfilter(c,tp,g)
	-- 返回目标怪兽是否满足检索条件。
	return g:IsContains(c) and Duel.IsExistingMatchingCard(c11711438.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
-- 判断卡组中是否存在与指定卡号不同的「战华」怪兽。
function c11711438.thfilter(c,code)
	return c:IsSetCard(0x137) and c:IsType(TYPE_MONSTER) and not c:IsCode(code) and c:IsAbleToHand()
end
-- 判断该效果是否可以发动，即当前为玩家回合、主阶段且有「战华」怪兽被召唤或特殊召唤成功。
function c11711438.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为效果持有者且当前阶段为主阶段且有「战华」怪兽被召唤或特殊召唤成功。
	return Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2) and eg:IsExists(c11711438.cfilter,1,nil,tp)
end
-- 设置检索效果的目标选择逻辑。
function c11711438.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(c11711438.cfilter,nil,tp)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c11711438.tgfilter(chkc,tp,g) end
	-- 检查是否有满足条件的目标怪兽。
	if chk==0 then return Duel.IsExistingTarget(c11711438.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,g) end
	if g:GetCount()==1 then
		-- 设置当前效果的目标为指定的怪兽。
		Duel.SetTargetCard(g)
	else
		-- 提示玩家选择目标怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		-- 选择目标怪兽。
		Duel.SelectTarget(tp,c11711438.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp,g)
	end
	-- 设置效果处理信息，表示将从卡组检索1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理检索效果的执行逻辑。
function c11711438.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local code=tc:GetCode()
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		-- 从卡组中选择一张与目标怪兽卡号不同的「战华」怪兽。
		local g=Duel.SelectMatchingCard(tp,c11711438.thfilter,tp,LOCATION_DECK,0,1,1,nil,code)
		if g:GetCount()>0 then
			-- 将选中的卡加入手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 判断手牌中是否存在可特殊召唤的「战华」怪兽。
function c11711438.spfilter(c,e,tp)
	return c:IsSetCard(0x137) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断该效果是否可以发动，即该卡是否从魔法与陷阱区域被送去墓地。
function c11711438.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
-- 设置特殊召唤效果的目标选择逻辑。
function c11711438.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置且手牌中有可特殊召唤的「战华」怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 返回是否有满足条件的怪兽可特殊召唤。
		and Duel.IsExistingMatchingCard(c11711438.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息，表示将从手牌特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 处理特殊召唤效果的执行逻辑。
function c11711438.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的召唤位置。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从手牌中选择一只「战华」怪兽。
	local g=Duel.SelectMatchingCard(tp,c11711438.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
