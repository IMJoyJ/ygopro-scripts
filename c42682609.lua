--C・ドルフィーナ
-- 效果：
-- 场上有「新宇宙」存在时，可以把这张卡作为祭品，从手卡·卡组特殊召唤1只「新空间侠·水波海豚」。
function c42682609.initial_effect(c)
	-- 记录该卡具有「新空间侠·水波海豚」的卡名代码
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
-- 检查场地是否为「新宇宙」
function c42682609.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 场地卡号为「新宇宙」
	return Duel.IsEnvironment(42015635)
end
-- 支付效果的解放费用
function c42682609.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为效果的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选可以特殊召唤的「新空间侠·水波海豚」
function c42682609.spfilter(c,e,tp)
	return c:IsCode(17955766) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤的条件
function c42682609.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡或卡组中是否存在满足条件的「新空间侠·水波海豚」
		and Duel.IsExistingMatchingCard(c42682609.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的卡的信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 执行特殊召唤的操作
function c42682609.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 再次确认场地是否为「新宇宙」
	if not Duel.IsEnvironment(42015635) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或卡组中选择1只「新空间侠·水波海豚」
	local g=Duel.SelectMatchingCard(tp,c42682609.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
