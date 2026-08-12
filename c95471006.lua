--X・Y・Zコンバイン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的机械族·光属性的同盟怪兽卡被除外的场合才能发动。从卡组把「X-首领加农」「Y-龙头」「Z-金属履带」之内1只特殊召唤。
-- ②：让自己场上1只融合怪兽回到额外卡组才能发动。从除外的自己怪兽之中选「X-首领加农」「Y-龙头」「Z-金属履带」最多2只特殊召唤（同名卡最多1张）。
function c95471006.initial_effect(c)
	-- 在卡片关系数据库中注册该卡记有「X-首领加农」、「Y-龙头」、「Z-金属履带」的卡名
	aux.AddCodeList(c,62651957,65622692,64500000)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己的机械族·光属性的同盟怪兽卡被除外的场合才能发动。从卡组把「X-首领加农」「Y-龙头」「Z-金属履带」之内1只特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95471006,0))  --"从卡组特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCountLimit(1,95471006)
	e1:SetCondition(c95471006.spcon)
	e1:SetTarget(c95471006.sptg)
	e1:SetOperation(c95471006.spop)
	c:RegisterEffect(e1)
	-- ②：让自己场上1只融合怪兽回到额外卡组才能发动。从除外的自己怪兽之中选「X-首领加农」「Y-龙头」「Z-金属履带」最多2只特殊召唤（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95471006,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,95471007)
	e2:SetCost(c95471006.sprcost)
	e2:SetTarget(c95471006.sprtg)
	e2:SetOperation(c95471006.sprop)
	c:RegisterEffect(e2)
end
c95471006.has_text_type=TYPE_UNION
-- 过滤条件：自己被除外的表侧表示机械族·光属性同盟怪兽
function c95471006.cfilter(c,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsType(TYPE_UNION) and c:IsPreviousControler(tp) and c:IsFaceup()
end
-- 效果①的发动条件：检查被除外的卡中是否存在满足条件的怪兽
function c95471006.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c95471006.cfilter,1,nil,tp)
end
-- 过滤条件：卡组中的「X-首领加农」、「Y-龙头」或「Z-金属履带」且可以特殊召唤
function c95471006.spfilter(c,e,tp)
	return c:IsCode(62651957,65622692,64500000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备：检查怪兽区域空位、卡组中是否存在可特召的怪兽，并设置特殊召唤的操作信息
function c95471006.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只可以特殊召唤的「X-首领加农」、「Y-龙头」或「Z-金属履带」
		and Duel.IsExistingMatchingCard(c95471006.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：从卡组选择1只「X-首领加农」、「Y-龙头」或「Z-金属履带」特殊召唤
function c95471006.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c95471006.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：自己场上表侧表示的融合怪兽，且能作为cost回到额外卡组，且其离开后有可用的怪兽区域
function c95471006.sprcfilter(c,tp)
	-- 检查怪兽是否为表侧表示的融合怪兽、能否作为cost回到额外卡组，且其离开后是否有可用的怪兽区域
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsAbleToExtraAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 效果②的发动代价（Cost）：选择自己场上1只融合怪兽回到额外卡组
function c95471006.sprcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可以作为cost回到额外卡组的融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c95471006.sprcfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要返回额外卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择1只满足条件的融合怪兽
	local g=Duel.SelectMatchingCard(tp,c95471006.sprcfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 将选择的融合怪兽作为发动代价（Cost）回到额外卡组
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤条件：除外状态的表侧表示「X-首领加农」、「Y-龙头」或「Z-金属履带」且可以特殊召唤
function c95471006.sprfilter(c,e,tp)
	return c:IsCode(62651957,65622692,64500000) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查除外区是否有可特召的怪兽，计算最大可特召数量，并设置特殊召唤的操作信息
function c95471006.sprtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查除外区是否存在至少1只可以特殊召唤的「X-首领加农」、「Y-龙头」或「Z-金属履带」
	if chk==0 then return Duel.IsExistingMatchingCard(c95471006.sprfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	local max=2
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetMZoneCount(tp)<2 then max=1 end
	-- 设置特殊召唤的操作信息（从除外区特殊召唤最多max只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,max,tp,LOCATION_REMOVED)
end
-- 效果②的处理：从除外的自己怪兽中选择最多2只卡名不同的「X-首领加农」、「Y-龙头」、「Z-金属履带」特殊召唤
function c95471006.sprop(e,tp,eg,ep,ev,re,r,rp)
	local max=2
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理
	if Duel.GetMZoneCount(tp)<1 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then max=1 end
	-- 获取除外区所有满足特殊召唤条件的「X-首领加农」、「Y-龙头」、「Z-金属履带」怪兽
	local g=Duel.GetMatchingGroup(c95471006.sprfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择1到max只卡名互不相同的怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,max)
	if sg then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
