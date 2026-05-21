--孵化
-- 效果：
-- ①：把自己场上1只怪兽解放才能发动。比解放的怪兽等级高1星的1只昆虫族怪兽从卡组特殊召唤。
function c96965364.initial_effect(c)
	-- ①：把自己场上1只怪兽解放才能发动。比解放的怪兽等级高1星的1只昆虫族怪兽从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetLabel(0)
	e1:SetCost(c96965364.cost)
	e1:SetTarget(c96965364.target)
	e1:SetOperation(c96965364.activate)
	c:RegisterEffect(e1)
end
-- 代价函数，设置标记100以用于在target中进行解放怪兽的合法性检测
function c96965364.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤满足解放条件的怪兽：等级大于0、卡组有对应高1星的昆虫族怪兽、且解放后能确保有怪兽区域用于特殊召唤
function c96965364.cfilter(c,e,tp,ft)
	local lv=c:GetLevel()
	-- 检查怪兽等级是否大于0，且卡组中是否存在等级比其高1星的满足特殊召唤条件的昆虫族怪兽
	return lv>0 and Duel.IsExistingMatchingCard(c96965364.spfilter,tp,LOCATION_DECK,0,1,nil,lv+1,e,tp)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
-- 过滤卡组中等级为指定等级（解放怪兽等级+1）且可以特殊召唤的昆虫族怪兽
function c96965364.spfilter(c,lv,e,tp)
	return c:IsLevel(lv) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 靶向与代价处理函数，检查是否能发动，并选择怪兽解放作为发动代价，记录其等级
function c96965364.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查是否存在至少1只可解放的怪兽，且解放后能腾出足够的怪兽区域
		return ft>-1 and Duel.CheckReleaseGroup(tp,c96965364.cfilter,1,nil,e,tp,ft)
	end
	-- 玩家选择1只满足条件的怪兽作为解放的代价
	local rg=Duel.SelectReleaseGroup(tp,c96965364.cfilter,1,1,nil,e,tp,ft)
	e:SetLabel(rg:GetFirst():GetLevel())
	-- 将选择的怪兽解放
	Duel.Release(rg,REASON_COST)
	-- 设置效果处理信息，声明此效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，从卡组特殊召唤比解放怪兽等级高1星的昆虫族怪兽
function c96965364.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否已满，若无可用区域则不进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只比解放怪兽等级高1星的昆虫族怪兽
	local g=Duel.SelectMatchingCard(tp,c96965364.spfilter,tp,LOCATION_DECK,0,1,1,nil,lv+1,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
