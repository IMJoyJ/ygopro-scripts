--生者の書－禁断の呪術－
-- 效果：
-- ①：以自己墓地1只不死族怪兽和对方墓地1只怪兽为对象才能发动。那只自己的不死族怪兽特殊召唤。那只对方怪兽除外。
function c2204140.initial_effect(c)
	-- 对应的效果原文为：①：以自己墓地1只不死族怪兽和对方墓地1只怪兽为对象才能发动。那只自己的不死族怪兽特殊召唤。那只对方怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c2204140.target)
	e1:SetOperation(c2204140.activate)
	c:RegisterEffect(e1)
end
-- 特殊召唤的筛选函数：检查墓地中的卡是否为不死族怪兽，且满足可被当前效果特殊召唤的条件（包括召唤限制和苏生限制）。
function c2204140.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 除外的筛选函数：检查墓地中的卡是否为怪兽卡，且满足可被除外的条件。
function c2204140.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 效果发动与对象选择阶段：确认自己场上存在特殊召唤空格、自己墓地存在可选不死族怪兽、对方墓地存在可选怪兽后，分别选择两个对象并登记特殊召唤与除外的操作信息。
function c2204140.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件检查：自己主要怪兽区域必须存在可用的空格，以便后续特殊召唤不死族怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：对方墓地存在至少1只满足rmfilter条件的怪兽，可以作为除外对象。
		and Duel.IsExistingTarget(c2204140.rmfilter,tp,0,LOCATION_GRAVE,1,nil)
		-- 发动条件检查：自己墓地存在至少1只满足spfilter条件的不死族怪兽，可以作为特殊召唤对象。
		and Duel.IsExistingTarget(c2204140.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的不死族怪兽，将其设为效果处理时要特殊召唤的对象。
	local g1=Duel.SelectTarget(tp,c2204140.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记特殊召唤的操作信息：对象为g1，数量为1，用于系统检测相关时点与效果。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,0,0)
	-- 弹出选择提示，提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方墓地选择1只符合条件的怪兽，将其设为效果处理时要除外的对象。
	local g2=Duel.SelectTarget(tp,c2204140.rmfilter,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 登记除外的操作信息：对象为g2，数量为1，持有者为对方，位置为墓地。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g2,1,1-tp,LOCATION_GRAVE)
end
-- 效果处理阶段：读取发动时记录的两个对象。若特殊召唤对象仍与效果关联且仍为不死族，则将其特殊召唤；若除外对象仍与效果关联，则将其除外。
function c2204140.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 读取发动时记录的特殊召唤对象组tg1。
	local ex1,tg1=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
	-- 读取发动时记录的除外对象组tg2。
	local ex2,tg2=Duel.GetOperationInfo(0,CATEGORY_REMOVE)
	if tg1:GetFirst():IsRelateToEffect(e) and tg1:GetFirst():IsRace(RACE_ZOMBIE) then
		-- 将选择的不死族怪兽以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tg1,0,tp,tp,false,false,POS_FACEUP)
	end
	if tg2:GetFirst():IsRelateToEffect(e) then
		-- 将选择的对方怪兽以表侧表示除外。
		Duel.Remove(tg2,POS_FACEUP,REASON_EFFECT)
	end
end
