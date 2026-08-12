--C・モーグ
-- 效果：
-- 场上有「新宇宙」存在时，可以把这张卡作为祭品从手卡·卡组特殊召唤1只「新空间侠·大地鼹鼠」。
function c42239546.initial_effect(c)
	-- 记录该卡具有「新空间侠·大地鼹鼠」的卡名信息
	aux.AddCodeList(c,80344569)
	-- 场上有「新宇宙」存在时，可以把这张卡作为祭品从手卡·卡组特殊召唤1只「新空间侠·大地鼹鼠」。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42239546,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c42239546.spcon)
	e1:SetCost(c42239546.spcost)
	e1:SetTarget(c42239546.sptg)
	e1:SetOperation(c42239546.spop)
	c:RegisterEffect(e1)
end
-- 检查场地是否为「新宇宙」
function c42239546.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 场地卡号为「新宇宙」
	return Duel.IsEnvironment(42015635)
end
-- 设置效果的费用为解放自身
function c42239546.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选可以特殊召唤的「新空间侠·大地鼹鼠」
function c42239546.spfilter(c,e,tp)
	return c:IsCode(80344569) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的目标为从手卡或卡组特殊召唤1只「新空间侠·大地鼹鼠」
function c42239546.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有可用怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查玩家手卡或卡组是否存在1只「新空间侠·大地鼹鼠」
		and Duel.IsExistingMatchingCard(c42239546.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息为特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 执行效果的处理流程，包括检查场地、选择目标并特殊召唤
function c42239546.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否还有可用怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 再次确认场地是否为「新宇宙」
	if not Duel.IsEnvironment(42015635) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或卡组选择1只「新空间侠·大地鼹鼠」
	local g=Duel.SelectMatchingCard(tp,c42239546.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡以正面表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
