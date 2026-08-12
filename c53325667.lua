--ガーデン・ローズ・メイデン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从自己的卡组·墓地把1张「黑色花园」加入手卡。
-- ②：把墓地的这张卡除外，以自己墓地1只「蔷薇龙」怪兽或龙族同调怪兽为对象才能发动。那只怪兽特殊召唤。
function c53325667.initial_effect(c)
	-- 注册此卡为「黑色花园」的卡片密码
	aux.AddCodeList(c,71645242)
	-- 添加同调召唤手续，需要1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。从自己的卡组·墓地把1张「黑色花园」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,53325667)
	e1:SetTarget(c53325667.thtg)
	e1:SetOperation(c53325667.thop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只「蔷薇龙」怪兽或龙族同调怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,53325668)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c53325667.sptg)
	e2:SetOperation(c53325667.spop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的「黑色花园」卡片
function c53325667.thfilter(c)
	return c:IsCode(71645242) and c:IsAbleToHand()
end
-- 设置检索效果的处理目标
function c53325667.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的「黑色花园」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c53325667.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置检索效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 执行检索效果的操作
function c53325667.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「黑色花园」卡片
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c53325667.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看了送入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤满足条件的「蔷薇龙」或龙族同调怪兽
function c53325667.spfilter(c,e,tp)
	return (c:IsSetCard(0x1123) or (c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的处理目标
function c53325667.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c53325667.spfilter(chkc,e,tp) end
	-- 检查场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c53325667.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c53325667.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤效果的操作
function c53325667.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且场上存在足够区域
	if tc and tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
