--ガーデン・ローズ・メイデン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从自己的卡组·墓地把1张「黑色花园」加入手卡。
-- ②：把墓地的这张卡除外，以自己墓地1只「蔷薇龙」怪兽或龙族同调怪兽为对象才能发动。那只怪兽特殊召唤。
function c53325667.initial_effect(c)
	-- 将卡号71645242（黑色花园）加入本卡的记载卡名列表，标记这张卡上记载有「黑色花园」的卡名。
	aux.AddCodeList(c,71645242)
	-- 注册同调召唤手续：需要1只调整 + 1只以上调整以外的怪兽。
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
	-- 设置发动代价：从墓地除外这张卡自身。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c53325667.sptg)
	e2:SetOperation(c53325667.spop)
	c:RegisterEffect(e2)
end
-- 定义「黑色花园」的检索过滤器：卡号是71645242且能被加入手卡。
function c53325667.thfilter(c)
	return c:IsCode(71645242) and c:IsAbleToHand()
end
-- 定义①效果的发动条件：自己卡组·墓地存在可加入手牌的「黑色花园」；并设置检索回手牌的操作信息。
function c53325667.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定：自己的卡组·墓地中是否存在至少1张符合条件的「黑色花园」。
	if chk==0 then return Duel.IsExistingMatchingCard(c53325667.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：从自己的卡组·墓地将1张卡加入手卡（不取对象的检索效果）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 执行①效果：从卡组·墓地选1张符合条件的「黑色花园」加入手牌，并让对手确认。
function c53325667.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组·墓地中选择1张符合条件的「黑色花园」（需通过王家长眠之谷的适用检查）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c53325667.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入其持有者的手卡（效果处理）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义②效果的对象过滤器：对象为「蔷薇龙」怪兽或龙族同调怪兽，且能够被这个效果特殊召唤。
function c53325667.spfilter(c,e,tp)
	return (c:IsSetCard(0x1123) or (c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义②效果的发动条件和取对象：自己主要怪兽区有空位，且墓地存在符合条件的对象。
function c53325667.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c53325667.spfilter(chkc,e,tp) end
	-- 发动时判定：自己的主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且墓地存在可作为对象的符合条件的「蔷薇龙」怪兽或龙族同调怪兽。
		and Duel.IsExistingTarget(c53325667.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地将1只符合条件的怪兽选择为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c53325667.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：进行1只怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行②效果：将对象怪兽在自己场上正面表示特殊召唤。
function c53325667.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 检查对象仍与效果关联且场上仍有可用怪兽区域。
	if tc and tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上（sumtype为0，遵守召唤条件和苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
