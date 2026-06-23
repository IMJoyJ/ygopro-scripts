--魔術師の再演
-- 效果：
-- ①：只在这张卡在场上表侧表示存在才有1次，以自己墓地1只3星以下的魔法师族怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡被送去墓地的场合才能发动。从卡组把「魔术师的再演」以外的1张「魔术师」永续魔法卡加入手卡。
function c40252269.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只在这张卡在场上表侧表示存在才有1次，以自己墓地1只3星以下的魔法师族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40252269,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c40252269.sptg)
	e2:SetOperation(c40252269.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的场合才能发动。从卡组把「魔术师的再演」以外的1张「魔术师」永续魔法卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40252269,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetTarget(c40252269.thtg)
	e3:SetOperation(c40252269.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断墓地中的怪兽是否为魔法师族、等级不超过3星且可以被特殊召唤
function c40252269.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时的条件判断函数，用于确认是否满足特殊召唤的条件
function c40252269.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c40252269.spfilter(chkc,e,tp) end
	-- 判断玩家场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c40252269.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为特殊召唤的目标
	local g=Duel.SelectTarget(tp,c40252269.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，执行特殊召唤操作
function c40252269.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断卡组中是否存在满足条件的永续魔法卡
function c40252269.thfilter(c)
	return c:IsSetCard(0x98) and c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS and not c:IsCode(40252269) and c:IsAbleToHand()
end
-- 效果处理时的条件判断函数，用于确认是否满足检索的条件
function c40252269.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家卡组中是否存在满足条件的永续魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c40252269.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，确定将要加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行检索并加入手牌的操作
function c40252269.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的永续魔法卡
	local g=Duel.SelectMatchingCard(tp,c40252269.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
