--トレジャー・パンダー
-- 效果：
-- ①：从自己墓地把最多3张魔法·陷阱卡里侧表示除外才能发动。和除外的卡数量相同等级的1只通常怪兽从卡组特殊召唤。
function c45221020.initial_effect(c)
	-- ①：从自己墓地把最多3张魔法·陷阱卡里侧表示除外才能发动。和除外的卡数量相同等级的1只通常怪兽从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45221020,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c45221020.sptg)
	e1:SetOperation(c45221020.spop)
	c:RegisterEffect(e1)
end
-- 代价筛选函数：筛选自己墓地中可以作为里侧表示除外代价的魔法·陷阱卡。
function c45221020.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemoveAsCost(POS_FACEDOWN)
end
-- 候选怪兽筛选函数：筛选卡组中等级不高于指定等级、且可以被当前效果特殊召唤的通常怪兽。
function c45221020.filter(c,e,tp,lv)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标的设定与代价处理函数：检查发动条件，发动时计算可除外的魔法·陷阱卡数量，让玩家宣言要特殊召唤的怪兽等级，从墓地选相同数量的魔法·陷阱卡里侧表示除外作为代价，并将特殊召唤1只通常怪兽的操作信息写入连锁。
function c45221020.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 计算自己墓地中可作为代价的魔法·陷阱卡数量，并限制最多为3张。
		local ct=math.min(3,Duel.GetMatchingGroupCount(c45221020.cfilter,tp,LOCATION_GRAVE,0,nil))
		-- 确认可除外的魔法·陷阱卡数量大于0，且自己主要怪兽区有空位，作为发动条件之一。
		return ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 确认卡组中存在等级不高于已选除外数量（最多3）且可被特殊召唤的通常怪兽，作为发动条件之一。
			and Duel.IsExistingMatchingCard(c45221020.filter,tp,LOCATION_DECK,0,1,nil,e,tp,ct)
	end
	-- 获取自己墓地中所有可作为代价的魔法·陷阱卡，组成候选组。
	local cg=Duel.GetMatchingGroup(c45221020.cfilter,tp,LOCATION_GRAVE,0,nil)
	local ct=math.min(3,cg:GetCount())
	-- 获取卡组中所有等级不高于除外数量且可被特殊召唤的通常怪兽，用于后续选择可用等级。
	local tg=Duel.GetMatchingGroup(c45221020.filter,tp,LOCATION_DECK,0,nil,e,tp,ct)
	local lvt={}
	local pc=1
	for i=1,3 do
		if tg:IsExists(c45221020.sfilter,1,nil,i,e,tp) then lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	-- 提示玩家选择要特殊召唤的怪兽的等级。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(45221020,1))  --"请选择要特殊召唤的怪兽的等级"
	-- 让玩家宣言一个等级；该等级将作为除外数量和特殊召唤怪兽的等级。
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	-- 提示玩家选择要里侧表示除外的魔法·陷阱卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=cg:Select(tp,lv,lv,nil)
	-- 将选中的魔法·陷阱卡以里侧表示除外，作为发动代价。
	Duel.Remove(rg,POS_FACEDOWN,REASON_COST)
	-- 将宣言的等级记录到当前连锁的目标参数中，供效果处理时使用。
	Duel.SetTargetParam(lv)
	-- 设置操作信息：本连锁的效果处理时将进行1次从卡组的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 确定特殊召唤对象的筛选函数：筛选卡组中等级与宣言等级相同的通常怪兽，且满足特殊召唤条件。
function c45221020.sfilter(c,lv,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数：在主要怪兽区有空位时，按宣言的等级从卡组选择1只符合条件的通常怪兽，以表侧攻击表示特殊召唤。
function c45221020.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前检查自己主要怪兽区是否有空位，没有空位则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取出发动时记录的宣言等级，作为选择特殊召唤怪兽的等级条件。
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只等级等于宣言等级且满足特殊召唤条件的通常怪兽。
	local g=Duel.SelectMatchingCard(tp,c45221020.sfilter,tp,LOCATION_DECK,0,1,1,nil,lv,e,tp)
	if g:GetCount()>0 then
		-- 将选择的通常怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
