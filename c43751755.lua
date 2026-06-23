--C・パンテール
-- 效果：
-- 场上有「新宇宙」存在时，可以把这张卡作为祭品从手卡·卡组特殊召唤1只「新空间侠·黑暗豹」。
function c43751755.initial_effect(c)
	-- 记录该卡具有「新空间侠·黑暗豹」的卡名信息
	aux.AddCodeList(c,43237273)
	-- 场上有「新宇宙」存在时，可以把这张卡作为祭品从手卡·卡组特殊召唤1只「新空间侠·黑暗豹」。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43751755,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c43751755.spcon)
	e1:SetCost(c43751755.spcost)
	e1:SetTarget(c43751755.sptg)
	e1:SetOperation(c43751755.spop)
	c:RegisterEffect(e1)
end
-- 检查场地是否为「新宇宙」
function c43751755.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场地是否为「新宇宙」
	return Duel.IsEnvironment(42015635)
end
-- 支付效果代价，解放自身
function c43751755.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身从游戏中解放作为效果的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选可以特殊召唤的「新空间侠·黑暗豹」
function c43751755.spfilter(c,e,tp)
	return c:IsCode(43237273) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的发动条件，确认场上存在可用区域且手卡或卡组有可特殊召唤的怪兽
function c43751755.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认玩家场上是否存在可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 确认玩家手卡或卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c43751755.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时的操作信息，指定将要特殊召唤的怪兽来源为手卡或卡组
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 执行效果的处理程序，检查是否满足特殊召唤条件并选择目标怪兽进行特殊召唤
function c43751755.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否还有可用的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 再次确认场地是否为「新宇宙」
	if not Duel.IsEnvironment(42015635) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或卡组中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c43751755.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
