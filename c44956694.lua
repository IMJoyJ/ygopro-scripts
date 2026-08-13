--ROMクラウディア
-- 效果：
-- ①：这张卡召唤成功时，以「ROM云雌羊」以外的自己墓地1只电子界族怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把「ROM云雌羊」以外的1只4星以下的电子界族怪兽特殊召唤。
function c44956694.initial_effect(c)
	-- ①：这张卡召唤成功时，以「ROM云雌羊」以外的自己墓地1只电子界族怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44956694,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c44956694.thtg)
	e1:SetOperation(c44956694.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把「ROM云雌羊」以外的1只4星以下的电子界族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44956694,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c44956694.spcon)
	e2:SetTarget(c44956694.sptg)
	e2:SetOperation(c44956694.spop)
	c:RegisterEffect(e2)
end
-- 定义效果①的取对象过滤器：对象必须是自己墓地的电子界族怪兽、可以加入手牌、且不是「ROM云雌羊」（卡号44956694）。
function c44956694.thfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsAbleToHand() and not c:IsCode(44956694)
end
-- 效果①的发动条件检查与取对象处理：确认墓地存在符合条件的怪兽后，提示玩家选择1只作为对象，并登记回手牌的操作信息。
function c44956694.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c44956694.thfilter(chkc) end
	-- 发动时点检查（chk==0）：确认自己墓地存在至少1只可作为效果对象的电子界族怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c44956694.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示对象选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动玩家从自己墓地选择1只符合条件的电子界族怪兽，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c44956694.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本次连锁处理会将选择的对象卡加入手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①处理时的操作：取得对象卡，若该卡仍与效果相关，则将其加入持有者手牌。
function c44956694.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果①发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送入其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 效果②的发动条件：这张卡因战斗或效果被破坏时满足（用位运算判断破坏原因含REASON_BATTLE或REASON_EFFECT）。
function c44956694.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 定义效果②的特殊召唤过滤器：选择卡组中等级4以下、电子界族、不是「ROM云雌羊」自身、且可以被特殊召唤的怪兽。
function c44956694.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_CYBERSE) and not c:IsCode(44956694) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②目标设定的发动条件检查：确认自己怪兽区有空位，且卡组中存在符合条件的电子界族怪兽。
function c44956694.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查（chk==0）：自己场上怪兽区必须有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且卡组中必须存在至少1只符合条件的电子界族怪兽；两项条件同时满足才能发动。
		and Duel.IsExistingMatchingCard(c44956694.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：效果处理时将把1只怪兽从卡组特殊召唤（具体怪兽在处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②处理时的操作：若怪兽区有空位，则从卡组选择1只符合条件的电子界族怪兽，以表侧表示特殊召唤。
function c44956694.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查：怪兽区没有空格则效果不处理，直接结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示特殊召唤选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只符合条件的电子界族怪兽（不取对象，于效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c44956694.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上（执行通常的特殊召唤判定与苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
