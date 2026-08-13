--エアリアル・イーター
-- 效果：
-- 相同属性的恶魔族怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合才能发动。从卡组把1只恶魔族怪兽送去墓地。
-- ②：这张卡在墓地存在的场合，把除「大气吸收者」外的2只6星以上而相同属性的恶魔族怪兽从自己墓地除外才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 大气吸收者的初始化主函数：为这张卡设置苏生限制，添加融合召唤手续（2只相同属性恶魔族），创建并注册①效果（融合召唤成功时从卡组堆墓恶魔族）和②效果（自己墓地除外2只6星以上同属性恶魔族来特殊召唤），两个效果均为一回合一次。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：用2只满足s.ffilter条件的怪兽作为融合素材。
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	-- 对应①效果：这张卡融合召唤的场合才能发动。从卡组把1只恶魔族怪兽送去墓地。
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
	-- 对应②效果：这张卡在墓地存在的场合，把除「大气吸收者」外的2只6星以上而相同属性的恶魔族怪兽从自己墓地除外才能发动。这张卡特殊召唤。
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
-- 融合素材筛选函数：判断候选怪兽是否可作为本卡的融合素材，规则上要求素材必须是恶魔族，且若已有素材则需与已选素材属性相同，以满足“相同属性的恶魔族怪兽×2”。
function s.ffilter(c,fc,sub,mg,sg)
	-- 判断候选融合素材是否合格：必须是恶魔族；同时检查与已选素材的关系——若已选素材为空/只有当前卡则通过，否则要求已选素材中存在至少一张属性与当前卡相同的怪兽，从而保证所有素材属性一致。
	return c:IsRace(RACE_FIEND) and (not sg or sg:FilterCount(aux.TRUE,c)==0 or sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute()))
end
-- 效果①的发动条件：仅当这张卡以融合召唤方式特殊召唤成功时才允许发动。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果①堆墓目标的筛选条件：选择卡组中种族为恶魔族且可以送去墓地的怪兽。
function s.tgfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAbleToGrave()
end
-- 效果①的发动目标判定与操作信息设置：在发动时检查卡组中是否存在符合条件的恶魔族怪兽；若存在，则设置将1张怪兽送去墓地的操作信息，供后续效果处理及对方连锁判定。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己的卡组中至少存在1张满足s.tgfilter的恶魔族怪兽，否则无法发动①效果。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：声明本效果将把从卡组选出的1张卡送去墓地，目标区域为卡组，目标持有者为tp。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的实际处理：提示玩家从卡组选择1张符合条件的恶魔族怪兽，并将其送去墓地，完成堆墓。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要送去墓地的卡”的提示，并将该提示写入选择缓存用于选择卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的卡组中选择1张满足s.tgfilter条件的恶魔族怪兽。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将玩家选中的卡以“效果”原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 效果②除外代价的候选卡筛选：不能是大气吸收者自身，必须是恶魔族、6星以上，并且可以作为发动代价除外。
function s.rfilter(c)
	return not c:IsCode(id) and c:IsRace(RACE_FIEND) and c:IsLevelAbove(6) and c:IsAbleToRemoveAsCost()
end
-- 检查一组被选中的墓地怪兽是否属性相同：通过判断该组中不同属性的种类数是否为1来实现。
function s.rselect(g)
	return g:GetClassCount(Card.GetAttributeInGrave)==1
end
-- 效果②的发动代价：从自己墓地筛选出除「大气吸收者」外的2只6星以上且属性相同的恶魔族怪兽，确认存在后提示玩家选择并以除外作为代价支付。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地中所有可作为②效果代价的候选怪兽集合（满足s.rfilter）。
	local g=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return g:CheckSubGroup(s.rselect,2,2) end
	-- 显示“请选择要除外的卡”的提示信息，引导玩家选择要除外的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,s.rselect,false,2,2)
	-- 将玩家选择的怪兽以表侧表示除外，作为发动②效果的代价。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 效果②特殊召唤目标的发动条件判定（chk==0）：自己场上主要怪兽区有空位，且这张卡自身能够被特殊召唤时才可发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动者tp的场上是否存在可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：声明本效果将把e:GetHandler()（大气吸收者自身）特殊召唤，数量为1，目标玩家及位置参数为0。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的实际处理：若该卡仍与效果关联且不受王家长眠之谷等效果影响，则将其表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 特殊召唤前的验证：确认这张卡仍与当前效果关联（未被移动/离场重置联系），并且通过王家长眠之谷过滤（在墓地能被特殊召唤）。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将大气吸收者以表侧表示特殊召唤到其持有者tp的场上，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
