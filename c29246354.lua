--C・ピニー
-- 效果：
-- 场上有「新宇宙」存在时，可以把这张卡作为祭品从手卡·卡组特殊召唤1只「新空间侠·光辉青苔」。
function c29246354.initial_effect(c)
	-- 记录该卡具有「新空间侠·光辉青苔」的卡名代码
	aux.AddCodeList(c,17732278)
	-- 场上有「新宇宙」存在时，可以把这张卡作为祭品从手卡·卡组特殊召唤1只「新空间侠·光辉青苔」。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29246354,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c29246354.spcon)
	e1:SetCost(c29246354.spcost)
	e1:SetTarget(c29246354.sptg)
	e1:SetOperation(c29246354.spop)
	c:RegisterEffect(e1)
end
-- 检查场地是否为「新宇宙」
function c29246354.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 场地卡号为「新宇宙」
	return Duel.IsEnvironment(42015635)
end
-- 支付特殊召唤的代价，解放自身
function c29246354.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身从游戏中解放作为代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选可以特殊召唤的「新空间侠·光辉青苔」
function c29246354.spfilter(c,e,tp)
	return c:IsCode(17732278) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤的条件，检查手卡和卡组是否存在可特殊召唤的卡片
function c29246354.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有可用怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡或卡组中是否存在「新空间侠·光辉青苔」
		and Duel.IsExistingMatchingCard(c29246354.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 执行特殊召唤操作，选择并特殊召唤符合条件的怪兽
function c29246354.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否还有可用怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 再次确认场地是否为「新宇宙」
	if not Duel.IsEnvironment(42015635) then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或卡组中选择1只「新空间侠·光辉青苔」
	local g=Duel.SelectMatchingCard(tp,c29246354.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡片特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
