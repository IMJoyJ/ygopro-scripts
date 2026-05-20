--転生の超戦士
-- 效果：
-- 「转生的超战士」在1回合只能发动1张。
-- ①：以自己场上1只「混沌战士」怪兽为对象才能发动。那只怪兽送去墓地，和那只怪兽卡名不同的1只「混沌战士」怪兽无视召唤条件从手卡特殊召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「混沌战士」怪兽为对象才能发动。那张卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c73694478.initial_effect(c)
	-- 「转生的超战士」在1回合只能发动1张。①：以自己场上1只「混沌战士」怪兽为对象才能发动。那只怪兽送去墓地，和那只怪兽卡名不同的1只「混沌战士」怪兽无视召唤条件从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,73694478+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c73694478.target)
	e1:SetOperation(c73694478.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「混沌战士」怪兽为对象才能发动。那张卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(c73694478.thcon)
	-- 把墓地的这张卡除外作为发动成本（cost）
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c73694478.thtg)
	e2:SetOperation(c73694478.thop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的「混沌战士」怪兽，且手卡存在至少1只与其卡名不同、可以特殊召唤的「混沌战士」怪兽
function c73694478.filter(c,e,tp,ft)
	return c:IsFaceup() and c:IsSetCard(0x10cf) and (ft>0 or c:GetSequence()<5)
		-- 检查手卡是否存在至少1只与该怪兽卡名不同的、可以特殊召唤的「混沌战士」怪兽
		and Duel.IsExistingMatchingCard(c73694478.spfilter,tp,LOCATION_HAND,0,1,nil,c:GetCode(),e,tp)
end
-- 过滤手卡中与指定卡名不同、且可以无视召唤条件特殊召唤的「混沌战士」怪兽
function c73694478.spfilter(c,code,e,tp)
	return c:IsSetCard(0x10cf) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果①的发动准备与目标选择（Target）
function c73694478.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上可用怪兽区域的数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c73694478.filter(chkc,e,tp,ft) end
	-- 检查发动条件：自己场上是否存在满足条件的「混沌战士」怪兽（若怪兽区已满，则该怪兽必须在主要怪兽区以腾出格子）
	if chk==0 then return ft>-1 and Duel.IsExistingTarget(c73694478.filter,tp,LOCATION_MZONE,0,1,nil,e,tp,ft) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1只「混沌战士」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c73694478.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,ft)
	-- 设置效果处理信息：将选择的对象怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 设置效果处理信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的处理（Operation）
function c73694478.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local code=tc:GetCode()
	-- 将对象怪兽送去墓地，若未成功送去墓地则处理终止
	if Duel.SendtoGrave(tc,REASON_EFFECT)==0 or not tc:IsLocation(LOCATION_GRAVE) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只与送去墓地的怪兽卡名不同的「混沌战士」怪兽
	local g=Duel.SelectMatchingCard(tp,c73694478.spfilter,tp,LOCATION_HAND,0,1,1,nil,code,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽无视召唤条件表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
-- 效果②的发动条件判断
function c73694478.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 必须不在送去墓地的回合，且在自己的主要阶段才能发动
	return aux.exccon(e) and Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 过滤自己墓地可以加入手卡的「混沌战士」怪兽
function c73694478.thfilter(c)
	return c:IsSetCard(0x10cf) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的发动准备与目标选择（Target）
function c73694478.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c73694478.thfilter(chkc) end
	-- 检查发动条件：自己墓地是否存在可以加入手卡的「混沌战士」怪兽
	if chk==0 then return Duel.IsExistingTarget(c73694478.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只「混沌战士」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c73694478.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选择的怪兽加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的处理（Operation）
function c73694478.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的墓地怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
