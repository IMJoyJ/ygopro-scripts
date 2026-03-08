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
-- 过滤函数，用于判断墓地中的卡是否为魔法或陷阱卡且可以作为除外的代价
function c45221020.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemoveAsCost(POS_FACEDOWN)
end
-- 过滤函数，用于判断卡组中的卡是否为通常怪兽且等级不超过指定等级且可以特殊召唤
function c45221020.filter(c,e,tp,lv)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动时点处理函数，用于判断是否满足发动条件并选择除外的卡和特殊召唤的怪兽等级
function c45221020.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 计算可除外的魔法·陷阱卡数量，最多为3张
		local ct=math.min(3,Duel.GetMatchingGroupCount(c45221020.cfilter,tp,LOCATION_GRAVE,0,nil))
		-- 判断玩家场上是否有足够的空间进行特殊召唤
		return ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 判断卡组中是否存在满足等级要求的通常怪兽
			and Duel.IsExistingMatchingCard(c45221020.filter,tp,LOCATION_DECK,0,1,nil,e,tp,ct)
	end
	-- 获取玩家墓地中所有满足条件的魔法·陷阱卡
	local cg=Duel.GetMatchingGroup(c45221020.cfilter,tp,LOCATION_GRAVE,0,nil)
	local ct=math.min(3,cg:GetCount())
	-- 获取卡组中所有满足等级要求的通常怪兽
	local tg=Duel.GetMatchingGroup(c45221020.filter,tp,LOCATION_DECK,0,nil,e,tp,ct)
	local lvt={}
	local pc=1
	for i=1,3 do
		if tg:IsExists(c45221020.sfilter,1,nil,i,e,tp) then lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	-- 提示玩家选择要特殊召唤的怪兽等级
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(45221020,1))  --"请选择要特殊召唤的怪兽的等级"
	-- 让玩家宣言要特殊召唤的怪兽等级
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=cg:Select(tp,lv,lv,nil)
	-- 将玩家选择的卡以里侧表示的形式除外
	Duel.Remove(rg,POS_FACEDOWN,REASON_COST)
	-- 将选择的怪兽等级设置为连锁参数
	Duel.SetTargetParam(lv)
	-- 设置本次效果操作信息，用于后续处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数，用于判断卡组中的卡是否为指定等级的通常怪兽且可以特殊召唤
function c45221020.sfilter(c,lv,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的处理函数，用于执行特殊召唤操作
function c45221020.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家场上是否有足够的空间进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁中设置的目标参数（即怪兽等级）
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择卡组中满足等级要求的1只通常怪兽
	local g=Duel.SelectMatchingCard(tp,c45221020.sfilter,tp,LOCATION_DECK,0,1,1,nil,lv,e,tp)
	if g:GetCount()>0 then
		-- 将选择的通常怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
