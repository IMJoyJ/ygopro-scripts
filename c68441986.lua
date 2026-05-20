--蚊学忍法・軍蚊マーチ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把最多2只4星以下的昆虫族怪兽特殊召唤（把2只特殊召唤的场合必须是相同等级）。
-- ②：自己场上有「No.2 蚊学忍者 影蚊」存在的场合，把墓地的这张卡除外，以最多有自己场上的昆虫族怪兽数量的对方场上的表侧表示怪兽为对象才能发动。给那些怪兽放置1个幻觉指示物。有幻觉指示物放置的怪兽的效果无效化。
function c68441986.initial_effect(c)
	-- ①：从手卡把最多2只4星以下的昆虫族怪兽特殊召唤（把2只特殊召唤的场合必须是相同等级）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68441986,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,68441986)
	e1:SetTarget(c68441986.sptg)
	e1:SetOperation(c68441986.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上有「No.2 蚊学忍者 影蚊」存在的场合，把墓地的这张卡除外，以最多有自己场上的昆虫族怪兽数量的对方场上的表侧表示怪兽为对象才能发动。给那些怪兽放置1个幻觉指示物。有幻觉指示物放置的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68441986,1))  --"放置指示物"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,68441987)
	e2:SetCondition(c68441986.countercond)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c68441986.countertg)
	e2:SetOperation(c68441986.counterop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中等级4以下且可以特殊召唤的昆虫族怪兽
function c68441986.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备：检查怪兽区域空位以及手卡中是否存在符合条件的昆虫族怪兽
function c68441986.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足条件的昆虫族怪兽
		and Duel.IsExistingMatchingCard(c68441986.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从手卡特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的处理：从手卡选择并特殊召唤最多2只相同等级的4星以下昆虫族怪兽
function c68441986.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取手卡中所有满足特殊召唤条件的昆虫族怪兽
	local g=Duel.GetMatchingGroup(c68441986.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 计算最大可特殊召唤的数量（受怪兽区域空位、手卡符合条件的怪兽数量以及最大值2的限制）
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),#g,2)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c68441986.spcheck,false,1,ft)
	if sg then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检查选择的怪兽组是否等级相同（若选择2只，则必须是相同等级）
function c68441986.spcheck(sg)
	return sg:GetClassCount(Card.GetLevel)==1
end
-- 过滤场上表侧表示的「No.2 蚊学忍者 影蚊」
function c68441986.cfilter(c)
	return c:IsFaceup() and c:IsCode(32453837)
end
-- 效果②的发动条件：自己场上存在「No.2 蚊学忍者 影蚊」
function c68441986.countercond(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「No.2 蚊学忍者 影蚊」
	return Duel.IsExistingMatchingCard(c68441986.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤自己场上表侧表示的昆虫族怪兽
function c68441986.ctfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 过滤对方场上可以放置幻觉指示物的表侧表示怪兽
function c68441986.tgfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x1063,1)
end
-- 效果②的发动准备：计算自己场上昆虫族怪兽数量，并选择对应数量的对方场上表侧表示怪兽作为对象
function c68441986.countertg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 计算自己场上表侧表示的昆虫族怪兽数量
	local ct=Duel.GetMatchingGroupCount(c68441986.ctfilter,tp,LOCATION_MZONE,0,nil)
	-- 检查自己场上是否有昆虫族怪兽，且对方场上是否存在可以放置指示物的表侧表示怪兽
	if chk==0 then return ct>0 and Duel.IsExistingTarget(c68441986.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要放置指示物的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
	-- 选择最多等同于自己场上昆虫族怪兽数量的对方场上的表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c68441986.tgfilter,tp,0,LOCATION_MZONE,1,ct,nil)
	-- 设置放置指示物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,0,0,0)
end
-- 检查怪兽上是否存在幻觉指示物（用于无效效果的持续条件）
function c68441986.ctcon(e)
	return e:GetHandler():GetCounter(0x1063)>0
end
-- 效果②的处理：给作为对象的怪兽放置幻觉指示物，并使其效果无效化
function c68441986.counterop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍存在于场上且仍是该效果对象的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g==0 then return end
	local c=e:GetHandler()
	-- 遍历所有符合条件的对象怪兽
	for tc in aux.Next(g) do
		if tc:AddCounter(0x1063,1) then
			-- 有幻觉指示物放置的怪兽的效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetCondition(c68441986.ctcon)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
