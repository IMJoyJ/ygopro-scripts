--超力の聖刻印
-- 效果：
-- 从手卡把1只名字带有「圣刻」的怪兽特殊召唤。
function c51365514.initial_effect(c)
	-- 从手卡把1只名字带有「圣刻」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c51365514.target)
	e1:SetOperation(c51365514.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：选择手卡中满足名字带有「圣刻」且能够被该效果特殊召唤（检查召唤条件与苏生限制）的怪兽。
function c51365514.filter(c,e,tp)
	return c:IsSetCard(0x69) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动合法判定及操作信息登记：检查己方主要怪兽区有空位且手卡存在符合条件的目标，并登记特殊召唤操作信息。
function c51365514.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动判定（chk==0）时，检查己方主要怪兽区是否存在可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查手卡中是否存在至少1只满足过滤器 c51365514.filter 的「圣刻」怪兽。
		and Duel.IsExistingMatchingCard(c51365514.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记连锁操作信息：本次效果包含特殊召唤，预计从己方手卡特殊召唤1只怪兽到场上。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：若己方主要怪兽区有空位，则让玩家从手卡选择1只符合条件的「圣刻」怪兽，并以表侧表示特殊召唤到己方场上。
function c51365514.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理开始时再次确认己方主要怪兽区是否还有空位，若没有则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡中筛选并选择1张满足过滤器条件的「圣刻」怪兽卡，作为本次特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c51365514.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到己方场上（不跳过召唤条件与苏生限制的检查）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
