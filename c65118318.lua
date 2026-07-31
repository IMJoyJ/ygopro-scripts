--おろかな墓荒らし
local s,id,o=GetID()
-- 初始化卡片效果：注册①魔法卡发动（卡组堆墓及墓地特召）、②墓地除外盖放魔陷效果
function s.initial_effect(c)
	-- 注册关联卡名：「愚蠢的埋葬」
	aux.AddCodeList(c,40235813)
	-- ①：卡片发动效果：从卡组把1张同名以外的记有「愚蠢的埋葬」卡名的卡送去墓地。之后，可以选双方墓地1只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：墓地发动效果：把墓地的这张卡除外才能发动。选对方墓地或双方墓地记有「愚蠢的埋葬」卡名的1张魔法·陷阱卡在自己场地盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	-- ②效果发动Cost：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 卡组堆墓过滤条件：同名以外、记有「愚蠢的埋葬」卡名且能送去墓地的卡
function s.tgfilter(c)
	-- 检查卡片是否同名以外、记有「愚蠢的埋葬」卡名且可送去墓地
	return not c:IsCode(id) and aux.IsCodeListed(c,40235813) and c:IsAbleToGrave()
end
-- ①效果发动准备：设置从卡组送去墓地卡片的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己卡组是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组把1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 墓地特召过滤条件：可以特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果处理：从卡组把1张满足条件的卡送去墓地，之后可从双方墓地特召1只怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断卡片是否成功送去墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
		-- 检查自己怪兽区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方墓地是否存在可特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp)
		-- 询问玩家是否继续执行特殊召唤效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		-- 连接块：分隔送去墓地与特殊召唤的处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从双方墓地选择1只满足条件的怪兽
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
		-- 高亮显示选择的目标怪兽
		Duel.HintSelection(sg)
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 盖放魔陷过滤条件：魔法·陷阱卡，且满足盖放位置与控制者条件（对方墓地任意魔陷，或自己墓地同名以外记有「愚蠢的埋葬」的魔陷）
function s.stfilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(true)
		-- 检查卡片是否为场地魔法或魔法与陷阱区域有空位
		and (c:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
		-- 检查卡片是否来自对方墓地，或是自己墓地中同名以外记有「愚蠢的埋葬」的卡
		and (c:IsControler(1-tp) or aux.IsCodeListed(c,40235813) and not c:IsCode(id))
end
-- ②效果发动准备：检查双方墓地是否存在满足盖放条件的魔法·陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：双方墓地（除自身外）是否存在符合盖放条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,e:GetHandler(),tp) end
end
-- ②效果处理：从双方墓地选1张满足条件的魔法·陷阱卡在自己场地盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从双方墓地选择1张满足条件的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.stfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp)
	if #g>0 then
		-- 高亮显示选择的目标卡片
		Duel.HintSelection(g)
		-- 将选中的卡片在自己场地盖放
		Duel.SSet(tp,g)
	end
end
