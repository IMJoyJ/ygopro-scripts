--インフェルニティ・ビートル
-- 效果：
-- 自己手卡是0张的场合，可以把这张卡解放从自己卡组把最多2只「永火甲虫」特殊召唤。
function c49080532.initial_effect(c)
	-- 创建一个起动效果，效果描述为“特殊召唤”，分类为特殊召唤，效果类型为起动效果，生效位置为主怪兽区，条件为己方手卡为0张，费用为解放自身，目标为从卡组特殊召唤最多2只永火甲虫，效果处理为特殊召唤符合条件的永火甲虫
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49080532,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c49080532.condition)
	e1:SetCost(c49080532.cost)
	e1:SetTarget(c49080532.target)
	e1:SetOperation(c49080532.operation)
	c:RegisterEffect(e1)
end
-- 效果条件：自己手卡是0张
function c49080532.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方手卡数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 效果费用：解放自身
function c49080532.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身以代价进行解放
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数：检查目标卡片是否为永火甲虫且可以特殊召唤
function c49080532.filter(c,e,tp)
	return c:IsCode(49080532) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标：确认场上存在可特殊召唤的永火甲虫
function c49080532.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查己方卡组是否存在至少1张永火甲虫
		and Duel.IsExistingMatchingCard(c49080532.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息为特殊召唤，目标为卡组中的永火甲虫
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若己方手卡不为0则返回；获取己方场上可用怪兽区域数量；若区域数量超过2则限制为2；检测青眼精灵龙效果是否生效并相应调整召唤数量；提示选择要特殊召唤的卡；选择满足条件的永火甲虫；将选中的卡特殊召唤
function c49080532.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果己方手卡不为0则返回
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 then return end
	-- 获取己方场上可用怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方卡组中选择满足条件的永火甲虫
	local g=Duel.SelectMatchingCard(tp,c49080532.filter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的永火甲虫特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
