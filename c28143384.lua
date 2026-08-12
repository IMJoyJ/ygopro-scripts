--エアリアル・イーター
-- 效果：
-- 相同属性的恶魔族怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合才能发动。从卡组把1只恶魔族怪兽送去墓地。
-- ②：这张卡在墓地存在的场合，把除「大气吸收者」外的2只6星以上而相同属性的恶魔族怪兽从自己墓地除外才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，设置融合召唤限制并添加融合召唤手续，创建两个效果分别为①和②
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用2个满足s.ffilter条件的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	-- ①：这张卡融合召唤的场合才能发动。从卡组把1只恶魔族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，把除「大气吸收者」外的2只6星以上而相同属性的恶魔族怪兽从自己墓地除外才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 定义融合素材过滤函数，确保融合素材为恶魔族且属性符合融合规则
function s.ffilter(c,fc,sub,mg,sg)
	-- 融合素材必须为恶魔族，且若已有融合素材则需满足属性一致或无融合素材
	return c:IsRace(RACE_FIEND) and (not sg or sg:FilterCount(aux.TRUE,c)==0 or sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute()))
end
-- 判断是否为融合召唤成功触发的效果
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 定义从卡组检索的恶魔族怪兽过滤条件
function s.tgfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAbleToGrave()
end
-- 设置效果发动时的处理目标，检查是否有满足条件的恶魔族怪兽可送去墓地
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即卡组中存在至少1只恶魔族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理，提示选择并把卡送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1只满足条件的恶魔族怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 定义墓地除外怪兽的过滤条件，排除自身并满足等级和种族要求
function s.rfilter(c)
	return not c:IsCode(id) and c:IsRace(RACE_FIEND) and c:IsLevelAbove(6) and c:IsAbleToRemoveAsCost()
end
-- 定义子组选择函数，确保所选怪兽属性一致
function s.rselect(g)
	return g:GetClassCount(Card.GetAttributeInGrave)==1
end
-- 设置效果发动时的费用，从墓地选择2只满足条件的怪兽除外
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足条件的墓地怪兽组
	local g=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return g:CheckSubGroup(s.rselect,2,2) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,s.rselect,false,2,2)
	-- 将选中的怪兽除外作为费用
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 设置特殊召唤效果的目标，检查是否有足够的召唤位置和特殊召唤条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，指定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤效果，将卡片特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查卡片是否仍存在于场上或效果处理中，且不受王家长眠之谷影响
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将卡片以正面表示特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
