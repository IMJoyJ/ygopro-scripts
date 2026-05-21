--メルフィー・キャシィ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把怪兽召唤·特殊召唤的场合或者这张卡被选择作为对方怪兽的攻击对象的场合才能发动。这张卡回到手卡。那之后，可以从卡组把「童话动物·小猫」以外的1只兽族怪兽加入手卡。
-- ②：自己结束阶段才能发动。这张卡从手卡特殊召唤。
function c93018428.initial_effect(c)
	-- ①：对方把怪兽召唤·特殊召唤的场合或者这张卡被选择作为对方怪兽的攻击对象的场合才能发动。这张卡回到手卡。那之后，可以从卡组把「童话动物·小猫」以外的1只兽族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93018428,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,93018428)
	e1:SetCondition(c93018428.thcon)
	e1:SetTarget(c93018428.thtg)
	e1:SetOperation(c93018428.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetCondition(c93018428.thcon2)
	c:RegisterEffect(e3)
	-- ②：自己结束阶段才能发动。这张卡从手卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(93018428,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_HAND)
	e4:SetCountLimit(1,93018429)
	e4:SetCondition(c93018428.spcon)
	e4:SetTarget(c93018428.sptg)
	e4:SetOperation(c93018428.spop)
	c:RegisterEffect(e4)
end
-- 过滤条件：检查怪兽是否由指定玩家召唤·特殊召唤
function c93018428.cfilter(c,sp)
	return c:IsSummonPlayer(sp)
end
-- 效果①发动条件：对方成功召唤·特殊召唤怪兽的场合
function c93018428.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c93018428.cfilter,1,nil,1-tp)
end
-- 效果①发动条件：这张卡被选择作为对方怪兽的攻击对象的场合
function c93018428.thcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查进行攻击的怪兽控制者是否为对方
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 效果①的发动准备：检查自身是否能回到手卡，并设置将自身送回手卡的操作信息
function c93018428.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置连锁处理中的操作信息为：将1张自身卡片送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 过滤条件：卡组中「童话动物·小猫」以外的1只兽族怪兽
function c93018428.thfilter(c)
	return c:IsRace(RACE_BEAST) and not c:IsCode(93018428) and c:IsAbleToHand()
end
-- 效果①的效果处理：将自身送回手卡，之后可以从卡组把「童话动物·小猫」以外的1只兽族怪兽加入手卡
function c93018428.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果相关，并成功将自身送回手卡
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_HAND)
		-- 检查卡组中是否存在满足检索条件的兽族怪兽
		and Duel.IsExistingMatchingCard(c93018428.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否选择从卡组将怪兽加入手卡
		and Duel.SelectYesNo(tp,aux.Stringid(93018428,2)) then  --"是否从卡组把卡加入手卡？"
		-- 中断当前效果处理，使后续的检索处理与回手卡不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要加入手卡的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1张满足条件的兽族怪兽
		local g=Duel.SelectMatchingCard(tp,c93018428.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 将选中的卡片加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②发动条件：自己的结束阶段
function c93018428.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 效果②的发动准备：检查自身是否能特殊召唤以及怪兽区域是否有空位，并设置特殊召唤的操作信息
function c93018428.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域，且自身是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的效果处理：将手卡的这张卡特殊召唤
function c93018428.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
