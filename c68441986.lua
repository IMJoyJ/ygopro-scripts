--蚊学忍法・軍蚊マーチ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把最多2只4星以下的昆虫族怪兽特殊召唤（把2只特殊召唤的场合必须是相同等级）。
-- ②：自己场上有「No.2 蚊学忍者 影蚊」存在的场合，把墓地的这张卡除外，以最多有自己场上的昆虫族怪兽数量的对方场上的表侧表示怪兽为对象才能发动。给那些怪兽放置1个幻觉指示物。有幻觉指示物放置的怪兽的效果无效化。
function c68441986.initial_effect(c)
	-- ①：从手卡把最多2只4星以下的昆虫族怪兽特殊召唤（把2只特殊召唤的场合必须是相同等级）。这个卡名的①的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68441986,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,68441986)
	e1:SetTarget(c68441986.sptg)
	e1:SetOperation(c68441986.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上有「No.2 蚊学忍者 影蚊」存在的场合，把墓地的这张卡除外，以最多有自己场上的昆虫族怪兽数量的对方场上的表侧表示怪兽为对象才能发动。给那些怪兽放置1个幻觉指示物。这个卡名的②的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68441986,1))  --"放置指示物"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,68441987)
	e2:SetCondition(c68441986.countercond)
	-- 设定发动代价：把墓地的这张卡除外才能发动
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c68441986.countertg)
	e2:SetOperation(c68441986.counterop)
	c:RegisterEffect(e2)
end
c68441986.mentioned_counter={
	[0x1063]=true,
}
-- 特殊召唤的过滤条件：4星以下·昆虫族·可以特殊召唤的怪兽
function c68441986.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标函数：确认自己主要怪兽区有空位且手卡有可特殊召唤的4星以下昆虫族怪兽时才能发动
function c68441986.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己主要怪兽区至少有1个可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：手卡存在至少1只满足条件的4星以下昆虫族怪兽
		and Duel.IsExistingMatchingCard(c68441986.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本连锁将进行从手卡的特殊召唤，预计特殊召唤1只
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果的处理：从手卡选最多2只4星以下昆虫族怪兽（受场上空位数限制，青眼精灵龙效果适用中只能选1只），以表侧表示特殊召唤
function c68441986.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得手卡中所有满足条件的4星以下昆虫族怪兽
	local g=Duel.GetMatchingGroup(c68441986.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 可特殊召唤的数量上限：取怪兽区空位数、符合条件的卡数与2之间的最小值
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),#g,2)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 向玩家提示：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c68441986.spcheck,false,1,ft)
	if sg then
		-- 把选出的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 子组检查：选中的怪兽等级必须全部相同（特殊召唤2只的场合必须是相同等级）
function c68441986.spcheck(sg)
	return sg:GetClassCount(Card.GetLevel)==1
end
-- 条件过滤：自己场上表侧表示的「No.2 蚊学忍者 影蚊」
function c68441986.cfilter(c)
	return c:IsFaceup() and c:IsCode(32453837)
end
-- ②效果的发动条件：自己场上有「No.2 蚊学忍者 影蚊」存在
function c68441986.countercond(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「No.2 蚊学忍者 影蚊」
	return Duel.IsExistingMatchingCard(c68441986.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 数量统计过滤：自己场上表侧表示的昆虫族怪兽
function c68441986.ctfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 对象过滤：表侧表示且可以放置1个幻觉指示物的怪兽
function c68441986.tgfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x1063,1)
end
-- ②效果的目标函数：以最多有自己场上昆虫族怪兽数量的对方场上表侧表示怪兽为对象
function c68441986.countertg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 统计自己场上表侧表示的昆虫族怪兽的数量，作为取对象数量的上限
	local ct=Duel.GetMatchingGroupCount(c68441986.ctfilter,tp,LOCATION_MZONE,0,nil)
	-- 发动条件检查：自己场上有昆虫族怪兽，且对方场上存在可以放置幻觉指示物的表侧表示怪兽
	if chk==0 then return ct>0 and Duel.IsExistingTarget(c68441986.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示：请选择要放置指示物的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
	-- 选择1至ct只对方场上表侧表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c68441986.tgfilter,tp,0,LOCATION_MZONE,1,ct,nil)
	-- 设置操作信息：本连锁将进行放置指示物的处理
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,0,0,0)
end
-- 无效化的持续条件：该怪兽放置有幻觉指示物
function c68441986.ctcon(e)
	return e:GetHandler():GetCounter(0x1063)>0
end
-- ②效果的处理：给那些作为对象的怪兽各放置1个幻觉指示物，放置成功的怪兽的效果无效化
function c68441986.counterop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡中仍与本效果关联的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g==0 then return end
	local c=e:GetHandler()
	-- 逐个遍历作为对象的怪兽进行处理
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
