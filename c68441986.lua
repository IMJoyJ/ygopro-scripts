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
	-- ②：自己场上有「No.2 蚊学忍者 影蚊」存在的场合，把墓地的这张卡除外，以最多有自己场上的昆虫族怪兽数量的对方场上的表侧表示怪兽为对象才能发动。给那些怪兽放置1个幻觉指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68441986,1))  --"放置指示物"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,68441987)
	e2:SetCondition(c68441986.countercond)
	-- ②效果发动Cost：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c68441986.countertg)
	e2:SetOperation(c68441986.counterop)
	c:RegisterEffect(e2)
end
c68441986.mentioned_counter={
	[0x1063]=true,
}
-- ①效果特召过滤条件：手牌4星以下的昆虫族怪兽且可特殊召唤
function c68441986.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动准备：检查怪兽区域空位与手牌符合条件的怪兽
function c68441986.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：手牌是否存在至少1只4星以下的昆虫族怪兽
		and Duel.IsExistingMatchingCard(c68441986.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从手牌特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理：从手牌选最多2只同等级的4星以下昆虫族怪兽表侧表示特殊召唤
function c68441986.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取手牌中所有符合条件的昆虫族怪兽
	local g=Duel.GetMatchingGroup(c68441986.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 计算实际可特殊召唤的最大数量
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),#g,2)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c68441986.spcheck,false,1,ft)
	if sg then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 选择卡片组合检查：选择的怪兽等级必须相同
function c68441986.spcheck(sg)
	return sg:GetClassCount(Card.GetLevel)==1
end
-- 条件过滤：场上表侧表示的「No.2 蚊学忍者 影蚊」
function c68441986.cfilter(c)
	return c:IsFaceup() and c:IsCode(32453837)
end
-- ②效果发动条件：自己场上有「No.2 蚊学忍者 影蚊」存在
function c68441986.countercond(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在表侧表示的「No.2 蚊学忍者 影蚊」
	return Duel.IsExistingMatchingCard(c68441986.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 数量统计过滤：自己场上的表侧表示昆虫族怪兽
function c68441986.ctfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 对象过滤：对方场上表侧表示且可以放置幻觉指示物的怪兽
function c68441986.tgfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x1063,1)
end
-- ②效果发动准备与选择目标：根据己方昆虫族怪兽数量选择对方场上的表侧表示怪兽为对象
function c68441986.countertg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 统计己方场上表侧表示昆虫族怪兽的数量
	local ct=Duel.GetMatchingGroupCount(c68441986.ctfilter,tp,LOCATION_MZONE,0,nil)
	-- 发动条件检查：己方场上有昆虫族怪兽且对方场上存在可以放置指示物的表侧表示怪兽
	if chk==0 then return ct>0 and Duel.IsExistingTarget(c68441986.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要放置指示物的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
	-- 选择最多有己方昆虫族怪兽数量的对方表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,c68441986.tgfilter,tp,0,LOCATION_MZONE,1,ct,nil)
	-- 设置连锁操作信息：放置指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,0,0,0)
end
-- 效果无效化条件：对应怪兽身上有幻觉指示物存在
function c68441986.ctcon(e)
	return e:GetHandler():GetCounter(0x1063)>0
end
-- ②效果处理：为选择的对象怪兽放置1个幻觉指示物，并赋予指示物存在时效果无效化的状态
function c68441986.counterop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中仍与效果相关的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g==0 then return end
	local c=e:GetHandler()
	-- 遍历所有成功选定的对象怪兽
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
