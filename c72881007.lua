--宝玉の氾濫
-- 效果：
-- ①：把自己的魔法与陷阱区域4张表侧表示的「宝玉兽」卡送去墓地才能发动。场上的卡全部送去墓地。那之后，把最多有这个效果从对方场上送去墓地的数量的「宝玉兽」怪兽从自己墓地尽可能特殊召唤。
function c72881007.initial_effect(c)
	-- ①：把自己的魔法与陷阱区域4张表侧表示的「宝玉兽」卡送去墓地才能发动。场上的卡全部送去墓地。那之后，把最多有这个效果从对方场上送去墓地的数量的「宝玉兽」怪兽从自己墓地尽可能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c72881007.cost)
	e1:SetTarget(c72881007.target)
	e1:SetOperation(c72881007.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己魔陷区表侧表示且可以作为代价送去墓地的「宝玉兽」卡（不含场地区域）。
function c72881007.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsAbleToGraveAsCost() and c:GetSequence()<5
end
-- 检查选作代价的卡片组g送去墓地后，场上是否仍有其他卡片可以被送去墓地（防止发动时场上没有其他卡导致无法发动）。
function c72881007.gcheck(g,tg)
	-- 检查场上除选作代价的卡片之外，是否还存在其他卡片。
	return tg:FilterCount(aux.TRUE,g)>0
end
-- 效果发动的代价处理函数：将自己魔陷区4张表侧表示的「宝玉兽」卡送去墓地。
function c72881007.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己魔陷区所有满足代价条件的「宝玉兽」卡。
	local g=Duel.GetMatchingGroup(c72881007.costfilter,tp,LOCATION_SZONE,0,nil)
	-- 获取场上除这张卡以外的所有卡片。
	local tg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if chk==0 then return g:CheckSubGroup(c72881007.gcheck,4,4,tg) end
	local sg=g
	if #g~=4 then
		-- 提示玩家选择要送去墓地的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		sg=g:SelectSubGroup(tp,c72881007.gcheck,false,4,4,tg)
	end
	-- 将选中的4张「宝玉兽」卡作为发动代价送去墓地。
	Duel.SendtoGrave(sg,REASON_COST)
end
-- 效果发动的目标确认与操作信息设置函数。
function c72881007.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上除这张卡以外的所有卡片（用于检测是否有卡可以送去墓地）。
	local tg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if chk==0 then return e:IsCostChecked() or #tg>0 end
	-- 设置操作信息：将场上的卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tg,#tg,0,0)
	-- 设置操作信息：从墓地特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 过滤因该效果从对方场上送去墓地的卡片。
function c72881007.ctfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsLocation(LOCATION_GRAVE)
end
-- 过滤自己墓地中可以特殊召唤的「宝玉兽」怪兽。
function c72881007.spfilter(c,e,tp)
	return c:IsSetCard(0x1034) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理的核心逻辑：场上卡全部送墓，然后根据对方送墓数量从自己墓地特召「宝玉兽」怪兽。
function c72881007.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除这张卡以外的所有卡片。
	local tg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将场上的卡全部送去墓地。
	Duel.SendtoGrave(tg,REASON_EFFECT)
	-- 获取本次操作实际被送去墓地的卡片组。
	local g=Duel.GetOperatedGroup()
	local ct=g:FilterCount(c72881007.ctfilter,nil,1-tp)
	-- 获取自己场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>ct then ft=ct end
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择最多等同于对方送墓数量（且不超过可用怪兽区域数）的「宝玉兽」怪兽。
	local sg=Duel.SelectMatchingCard(tp,c72881007.spfilter,tp,LOCATION_GRAVE,0,ft,ft,nil,e,tp)
	if sg:GetCount()>0 then
		-- 插入效果连接点，使后续的特殊召唤处理与送去墓地处理不视为同时进行。
		Duel.BreakEffect()
		-- 将选中的「宝玉兽」怪兽在自己场上表侧表示特殊召唤。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
