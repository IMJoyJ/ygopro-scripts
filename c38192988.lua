--真紅眼の不死竜皇
-- 效果：
-- 不死族调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方回合，以「真红眼不死龙皇」以外的自己墓地1只不死族怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡在墓地存在的场合，把自己场上1只不死族怪兽除外才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化效果，设置同调召唤手续、启用复活限制，并注册两个效果
function c38192988.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整且为不死族，以及1只调整以外的不死族怪兽
	aux.AddSynchroProcedure(c,c38192988.synfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 效果①：对方回合，以「真红眼不死龙皇」以外的自己墓地1只不死族怪兽为对象才能发动。那只怪兽特殊召唤。
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
	-- 效果②：这张卡在墓地存在的场合，把自己场上1只不死族怪兽除外才能发动。这张卡特殊召唤。
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
-- 同调召唤所需调整的种族过滤器，要求为不死族
function c38192988.synfilter(c)
	return c:IsRace(RACE_ZOMBIE)
end
-- 效果①的发动条件，判断是否为对方回合
function c38192988.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()==1-tp
end
-- 效果①的目标过滤器，排除自身且为不死族并可特殊召唤
function c38192988.spfilter(c,e,tp)
	return not c:IsCode(38192988) and c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动时点处理，检查是否有满足条件的目标
function c38192988.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c38192988.spfilter(chkc,e,tp) end
	-- 检查场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的不死族怪兽
		and Duel.IsExistingTarget(c38192988.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,c38192988.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，确定特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的处理函数，将目标卡特殊召唤
function c38192988.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的除外卡过滤器，要求为不死族、正面表示、可作为除外费用且有空区域
function c38192988.rvfilter(c,tp)
	-- 判断是否为不死族、正面表示、可除外且有空区域
	return c:IsRace(RACE_ZOMBIE) and c:IsFaceup() and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 效果②的发动费用处理，选择并除外场上1只不死族怪兽
function c38192988.rvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的除外卡
	if chk==0 then return Duel.IsExistingMatchingCard(c38192988.rvfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择除外卡
	local g=Duel.SelectMatchingCard(tp,c38192988.rvfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的发动时点处理，检查是否可特殊召唤自身
function c38192988.rvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，确定特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的处理函数，将自身特殊召唤
function c38192988.rvop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身特殊召唤到场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
