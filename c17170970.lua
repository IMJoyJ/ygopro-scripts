--アーマード・ホワイトベア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上有同调怪兽存在，这张卡召唤·特殊召唤成功的场合，以自己墓地1张场地魔法卡为对象才能发动。那张卡加入手卡。
-- ②：这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。从自己的卡组·墓地选「铠装白熊」以外的1只4星以下的兽族怪兽特殊召唤。
function c17170970.initial_effect(c)
	-- ①：场上有同调怪兽存在，这张卡召唤·特殊召唤成功的场合，以自己墓地1张场地魔法卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,17170970)
	e1:SetCondition(c17170970.thcon)
	e1:SetTarget(c17170970.thtg)
	e1:SetOperation(c17170970.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。从自己的卡组·墓地选「铠装白熊」以外的1只4星以下的兽族怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,17170971)
	e3:SetCondition(c17170970.spcon)
	e3:SetTarget(c17170970.sptg)
	e3:SetOperation(c17170970.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在表侧表示的同调怪兽
function c17170970.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 效果发动的条件：场上有同调怪兽存在
function c17170970.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在至少1只同调怪兽
	return Duel.IsExistingMatchingCard(c17170970.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 过滤函数，用于判断墓地的卡是否为场地魔法卡且能加入手牌
function c17170970.filter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 设置效果的发动目标：选择墓地1张场地魔法卡作为对象
function c17170970.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c17170970.filter(chkc) end
	-- 检查是否满足发动条件：墓地存在场地魔法卡
	if chk==0 then return Duel.IsExistingTarget(c17170970.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,c17170970.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数：将目标卡加入手牌
function c17170970.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 效果发动的条件：被战斗或对方的效果破坏送去墓地
function c17170970.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp))
end
-- 过滤函数，用于判断卡是否为兽族、等级4以下且不是铠装白熊
function c17170970.spfilter(c,e,tp)
	return c:IsRace(RACE_BEAST) and c:IsLevelBelow(4) and not c:IsCode(17170970) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的发动目标：从卡组或墓地选择1只符合条件的怪兽
function c17170970.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：场上存在空位且卡组或墓地存在符合条件的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组或墓地是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c17170970.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理信息：特殊召唤1只符合条件的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理函数：从卡组或墓地特殊召唤符合条件的怪兽
function c17170970.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c17170970.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
