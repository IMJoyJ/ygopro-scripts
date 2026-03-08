--コンタクト・ゲート
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己墓地把「新空间侠」怪兽2种类各1只除外才能发动。从自己的手卡·卡组·墓地选2只「新空间侠」怪兽特殊召唤（同名卡最多1张）。这个效果发动过的回合，自己不是融合怪兽不能从额外卡组特殊召唤。
-- ②：自己场上的表侧表示的需以「元素英雄 新宇侠」为融合素材的融合怪兽回到额外卡组的场合，把墓地的这张卡除外才能发动。选除外的1只自己的「新空间侠」怪兽特殊召唤。
function c41933425.initial_effect(c)
	-- 记录此卡的卡名包含「元素英雄 新宇侠」（89943723）
	aux.AddCodeList(c,89943723)
	-- 为这张卡添加「新空间侠」系列编码（0x3008）
	aux.AddSetNameMonsterList(c,0x3008)
	-- ①：从自己墓地把「新空间侠」怪兽2种类各1只除外才能发动。从自己的手卡·卡组·墓地选2只「新空间侠」怪兽特殊召唤（同名卡最多1张）。这个效果发动过的回合，自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,41933425+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c41933425.cost)
	e1:SetTarget(c41933425.target)
	e1:SetOperation(c41933425.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的表侧表示的需以「元素英雄 新宇侠」为融合素材的融合怪兽回到额外卡组的场合，把墓地的这张卡除外才能发动。选除外的1只自己的「新空间侠」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41933425,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c41933425.spcon)
	-- 设置效果发动时的除外费用为将此卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c41933425.sptg)
	e2:SetOperation(c41933425.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查墓地是否存在满足条件的「新空间侠」怪兽（类型为怪兽、可除外、且存在满足cfilter2条件的另一只怪兽）
function c41933425.cfilter1(c,e,tp)
	return c:IsSetCard(0x1f) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 确保所选的怪兽能与另一只怪兽组成满足条件的组合
		and Duel.IsExistingMatchingCard(c41933425.cfilter2,tp,LOCATION_GRAVE,0,1,c,e,tp,c)
end
-- 过滤函数：检查墓地是否存在满足条件的「新空间侠」怪兽（类型为怪兽、可除外、且与已选怪兽组成满足条件的组合）
function c41933425.cfilter2(c,e,tp,tc)
	if c:IsCode(tc:GetCode()) then return false end
	local sg=Group.FromCards(tc,c)
	-- 获取满足条件的「新空间侠」怪兽组（用于检查卡名种类数）
	local g=Duel.GetMatchingGroup(c41933425.spfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,sg,e,tp)
	return c:IsSetCard(0x1f) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and g:GetClassCount(Card.GetCode)>1
end
-- 过滤函数：检查手卡·卡组·墓地是否存在满足条件的「新空间侠」怪兽（可特殊召唤）
function c41933425.spfilter1(c,e,tp)
	return c:IsSetCard(0x1f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的费用处理：从墓地选择2只不同种类的「新空间侠」怪兽除外
function c41933425.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：墓地是否存在满足cfilter1条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c41933425.cfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足cfilter1条件的怪兽
	local g1=Duel.SelectMatchingCard(tp,c41933425.cfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足cfilter2条件的怪兽
	local g2=Duel.SelectMatchingCard(tp,c41933425.cfilter2,tp,LOCATION_GRAVE,0,1,1,g1:GetFirst(),e,tp,g1:GetFirst())
	g1:Merge(g2)
	-- 将选中的怪兽除外作为费用
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
end
-- 效果发动时的目标处理：检查是否满足特殊召唤条件
function c41933425.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足条件的「新空间侠」怪兽组（用于检查卡名种类数）
	local g=Duel.GetMatchingGroup(c41933425.spfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查是否满足特殊召唤条件：场地上有空位且存在至少2种不同卡名的怪兽
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and g:GetClassCount(Card.GetCode)>1 end
	-- 设置效果发动时的操作信息：特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果发动时的处理：设置不能特殊召唤融合怪兽的效果，并特殊召唤符合条件的怪兽
function c41933425.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 设置不能特殊召唤融合怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c41933425.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤融合怪兽的效果
	Duel.RegisterEffect(e1,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
	-- 获取满足条件的「新空间侠」怪兽组（排除王家长眠之谷影响）
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c41933425.spfilter1),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	if g:GetClassCount(Card.GetCode)>1 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从满足条件的怪兽组中选择2只不同卡名的怪兽
		local sg1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		-- 将选中的怪兽特殊召唤
		Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 限制不能特殊召唤融合怪兽的效果函数
function c41933425.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 判断融合怪兽是否满足条件（需以「元素英雄 新宇侠」为素材、在场上、表侧表示、为己方控制、在额外卡组）
function c41933425.confilter(c,tp)
	-- 判断融合怪兽是否以「元素英雄 新宇侠」为素材
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,89943723) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsLocation(LOCATION_EXTRA)
end
-- 判断是否满足效果发动条件：是否有满足条件的融合怪兽回到额外卡组
function c41933425.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c41933425.confilter,1,nil,tp)
end
-- 过滤函数：检查场上是否存在满足条件的「新空间侠」怪兽（表侧表示、可特殊召唤）
function c41933425.spfilter2(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x1f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标处理：检查是否满足特殊召唤条件
function c41933425.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤条件：场地上有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足特殊召唤条件：墓地是否存在满足条件的「新空间侠」怪兽
		and Duel.IsExistingMatchingCard(c41933425.spfilter2,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置效果发动时的操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
-- 效果发动时的处理：特殊召唤满足条件的怪兽
function c41933425.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足特殊召唤条件：场地上有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「新空间侠」怪兽
	local g=Duel.SelectMatchingCard(tp,c41933425.spfilter2,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
