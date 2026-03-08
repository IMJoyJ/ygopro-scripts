--双天の転身
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「双天」怪兽为对象才能发动。那只怪兽破坏，比那只怪兽原本等级高1星或者原本等级低1星的1只「双天」怪兽从卡组·额外卡组特殊召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「双天」怪兽为对象才能发动。那只怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c44644529.initial_effect(c)
	-- ①：以自己场上1只「双天」怪兽为对象才能发动。那只怪兽破坏，比那只怪兽原本等级高1星或者原本等级低1星的1只「双天」怪兽从卡组·额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,44644529)
	e1:SetTarget(c44644529.target)
	e1:SetOperation(c44644529.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「双天」怪兽为对象才能发动。那只怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44644529,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,44644530)
	e2:SetCondition(c44644529.thcon)
	-- 将这张卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c44644529.thtg)
	e2:SetOperation(c44644529.thop)
	c:RegisterEffect(e2)
end
-- 破坏对象怪兽的过滤条件，必须是表侧表示的「双天」怪兽且其原本等级大于0，并且场上存在满足特殊召唤条件的「双天」怪兽
function c44644529.desfilter(c,e,tp)
	local lv=c:GetOriginalLevel()
	-- 满足破坏对象条件的怪兽必须是表侧表示的「双天」怪兽且其原本等级大于0，并且场上存在满足特殊召唤条件的「双天」怪兽
	return c:IsFaceup() and c:IsSetCard(0x14f) and lv>0 and Duel.IsExistingMatchingCard(c44644529.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,lv,c)
end
-- 特殊召唤对象怪兽的过滤条件，必须是「双天」怪兽且等级为原等级±1，并且可以被特殊召唤
function c44644529.spfilter(c,e,tp,lv,rc)
	if not (c:IsSetCard(0x14f) and c:IsLevel(lv-1,lv+1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_DECK) then
		-- 若特殊召唤对象在卡组，则判断是否有足够的怪兽区域
		return Duel.GetMZoneCount(tp,rc)>0
	else
		-- 若特殊召唤对象在额外卡组，则判断是否有足够的特殊召唤区域
		return Duel.GetLocationCountFromEx(tp,tp,rc,c)>0
	end
end
-- 设置效果目标为己方场上的「双天」怪兽，用于破坏效果
function c44644529.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c44644529.desfilter(chkc,e,tp) end
	-- 检查是否存在满足破坏条件的「双天」怪兽
	if chk==0 then return Duel.IsExistingTarget(c44644529.desfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择要破坏的「双天」怪兽
	local g=Duel.SelectTarget(tp,c44644529.desfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息为破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息为特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 处理破坏效果并选择特殊召唤对象
function c44644529.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且未被破坏
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足等级条件的「双天」怪兽进行特殊召唤
		local sg=Duel.SelectMatchingCard(tp,c44644529.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetOriginalLevel())
		if #sg>0 then
			-- 将符合条件的怪兽特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 效果发动条件，必须是己方主要阶段且不是在本回合将此卡送去墓地
function c44644529.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足发动条件，即不是在本回合将此卡送去墓地且当前为己方主要阶段
	return aux.exccon(e) and Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 墓地怪兽加入手牌的过滤条件，必须是「双天」怪兽且为怪兽类型
function c44644529.thfilter(c)
	return c:IsSetCard(0x14f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果目标为己方墓地的「双天」怪兽，用于加入手牌效果
function c44644529.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c44644529.thfilter(chkc) end
	-- 检查是否存在满足加入手牌条件的「双天」怪兽
	if chk==0 then return Duel.IsExistingTarget(c44644529.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择要加入手牌的「双天」怪兽
	local g=Duel.SelectTarget(tp,c44644529.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息为将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理将墓地怪兽加入手牌的效果
function c44644529.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
