--真紅眼の不死竜皇
-- 效果：
-- 不死族调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方回合，以「真红眼不死龙皇」以外的自己墓地1只不死族怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡在墓地存在的场合，把自己场上1只不死族怪兽除外才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：为「真红眼不死龙皇」添加同调召唤手续和苏生限制，并注册①的诱发即时效果（对方回合从墓地特召不死族）与②的起动效果（墓地自身除外场上不死族特召），其中①②效果均设置为1回合各能使用1次。
function c38192988.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整素材必须是不死族怪兽，调整以外的素材至少1只（不限种族）。
	aux.AddSynchroProcedure(c,c38192988.synfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 对应①效果：这个卡名的①②的效果1回合各能使用1次。①：对方回合，以「真红眼不死龙皇」以外的自己墓地1只不死族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,38192988)
	e1:SetCondition(c38192988.spcon)
	e1:SetTarget(c38192988.sptg)
	e1:SetOperation(c38192988.spop)
	c:RegisterEffect(e1)
	-- 对应②效果：②：这张卡在墓地存在的场合，把自己场上1只不死族怪兽除外才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,38192988+o)
	e2:SetCost(c38192988.rvcost)
	e2:SetTarget(c38192988.rvtg)
	e2:SetOperation(c38192988.rvop)
	c:RegisterEffect(e2)
end
-- 同调调整素材的筛选函数：判断怪兽是否为不死族。
function c38192988.synfilter(c)
	return c:IsRace(RACE_ZOMBIE)
end
-- ①效果的发动条件函数：仅在对方回合且满足发动条件时才允许发动。
function c38192988.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果的发动者的对方，即是否处于对方回合。
	return Duel.GetTurnPlayer()==1-tp
end
-- ①效果可选对象的筛选条件：对象必须是墓地存在的不死族怪兽，不能是「真红眼不死龙皇」自身，并且可以被特殊召唤。
function c38192988.spfilter(c,e,tp)
	return not c:IsCode(38192988) and c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动目标处理：检查自己怪兽区是否有空位，并选择自己墓地1只符合条件的怪兽作为效果对象。
function c38192988.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c38192988.spfilter(chkc,e,tp) end
	-- 发动时的合法检查：自己场上必须存在可用的怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动时的合法检查：墓地中至少存在1只符合条件的怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c38192988.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的怪兽，将其设置为效果的取对象目标。
	local g=Duel.SelectTarget(tp,c38192988.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：本次效果将进行1只怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的处理函数：效果结算时，若对象仍然关联且场上仍有空位，则将对象怪兽特殊召唤。
function c38192988.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次确认自己怪兽区是否有空位，若无空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得通过①效果选择的取对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将取对象的不死族怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果发动代价的筛选函数：选择自己场上表侧表示的不死族怪兽作为可除外的代价。
function c38192988.rvfilter(c,tp)
	-- 代价筛选的具体条件：是不死族、表侧表示、可以作为代价除外，且除外后自己场上仍有可用的怪兽区。
	return c:IsRace(RACE_ZOMBIE) and c:IsFaceup() and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- ②效果的发动代价处理：从自己场上选择1只不死族怪兽除外作为发动代价。
function c38192988.rvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在满足代价条件的怪兽可用于除外。
	if chk==0 then return Duel.IsExistingMatchingCard(c38192988.rvfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 给玩家显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己场上1只符合条件的不死族怪兽作为除外代价。
	local g=Duel.SelectMatchingCard(tp,c38192988.rvfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 将选择的怪兽以表侧表示除外，作为②效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的发动目标处理：确认墓地的这张卡本身可以被特殊召唤，并登记特殊召唤的操作信息。
function c38192988.rvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：本次效果将特殊召唤这张卡自身（1只怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理函数：效果结算时，若此卡仍与效果关联，则将这张卡从墓地特殊召唤。
function c38192988.rvop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将墓地中的这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
