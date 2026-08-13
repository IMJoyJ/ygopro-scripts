--C・ドルフィーナ
-- 效果：
-- 场上有「新宇宙」存在时，可以把这张卡作为祭品，从手卡·卡组特殊召唤1只「新空间侠·水波海豚」。
function c42682609.initial_effect(c)
	-- 登记本卡效果中提到的“新空间侠·水波海豚”的卡号17955766，用于规则识别与提示。
	aux.AddCodeList(c,17955766)
	-- 场上有「新宇宙」存在时，可以把这张卡作为祭品，从手卡·卡组特殊召唤1只「新空间侠·水波海豚」。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42682609,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c42682609.spcon)
	e1:SetCost(c42682609.spcost)
	e1:SetTarget(c42682609.sptg)
	e1:SetOperation(c42682609.spop)
	c:RegisterEffect(e1)
end
-- 条件函数：判断场上是否存在「新宇宙」，作为效果能否发动的条件。
function c42682609.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前场上是否存在着卡号42015635的「新宇宙」。
	return Duel.IsEnvironment(42015635)
end
-- 代价函数：确认这张卡可以解放，并将这张卡解放作为发动代价。
function c42682609.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡自身解放，原因记为代价（REASON_COST）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 特殊召唤对象过滤：必须是「新空间侠·水波海豚」（卡号17955766），且满足特殊召唤条件。
function c42682609.spfilter(c,e,tp)
	return c:IsCode(17955766) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标判定函数：确认发动条件成立——自己场上至少存在可用的怪兽区域（因自身解放后腾出区域），且手卡·卡组中有符合条件的「新空间侠·水波海豚」。
function c42682609.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前怪兽区可用数量大于-1，即解放自身后能空出1个可用位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 同时检查手卡·卡组中是否存在1张满足特殊召唤条件的「新空间侠·水波海豚」。
		and Duel.IsExistingMatchingCard(c42682609.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果涉及特殊召唤，预计从手卡·卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理函数：再次确认有怪兽区域空位且「新宇宙」在场，然后选择并特殊召唤「新空间侠·水波海豚」。
function c42682609.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区没有空位，则不再进行特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 若此时场上没有「新宇宙」存在，则效果处理不适用。
	if not Duel.IsEnvironment(42015635) then return end
	-- 向玩家发送“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组中选择1张符合条件的「新空间侠·水波海豚」。
	local g=Duel.SelectMatchingCard(tp,c42682609.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「新空间侠·水波海豚」以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
