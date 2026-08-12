--スワローズ・ネスト
-- 效果：
-- ①：把自己场上1只表侧表示的鸟兽族怪兽解放才能发动。和解放的怪兽相同等级的1只鸟兽族怪兽从卡组特殊召唤。
function c94145683.initial_effect(c)
	-- ①：把自己场上1只表侧表示的鸟兽族怪兽解放才能发动。和解放的怪兽相同等级的1只鸟兽族怪兽从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetLabel(0)
	e1:SetCost(c94145683.cost)
	e1:SetTarget(c94145683.target)
	e1:SetOperation(c94145683.activate)
	c:RegisterEffect(e1)
end
-- 在cost阶段将Label设为100，用于在target中标记并检测是否正常支付代价
function c94145683.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤场上可以被解放的表侧表示鸟兽族怪兽，且卡组中存在与其相同等级的、可特殊召唤的鸟兽族怪兽
function c94145683.filter1(c,e,tp,ft)
	local lv=c:GetLevel()
	return lv>0 and c:IsFaceup() and c:IsRace(RACE_WINDBEAST)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
		-- 检查卡组中是否存在与该怪兽相同等级且可特殊召唤的鸟兽族怪兽
		and Duel.IsExistingMatchingCard(c94145683.filter2,tp,LOCATION_DECK,0,1,nil,lv,e,tp)
end
-- 过滤卡组中与指定等级相同且可以特殊召唤的鸟兽族怪兽
function c94145683.filter2(c,lv,e,tp)
	return c:IsRace(RACE_WINDBEAST) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理，包括检测是否能发动、选择并解放怪兽、记录其等级并设置特殊召唤的操作信息
function c94145683.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查玩家场上是否存在至少1只满足解放条件的怪兽
		return ft>-1 and Duel.CheckReleaseGroup(tp,c94145683.filter1,1,nil,e,tp,ft)
	end
	-- 让玩家选择1只满足解放条件的怪兽
	local rg=Duel.SelectReleaseGroup(tp,c94145683.filter1,1,1,nil,e,tp,ft)
	e:SetLabel(rg:GetFirst():GetLevel())
	-- 解放选中的怪兽作为发动代价
	Duel.Release(rg,REASON_COST)
	-- 设置特殊召唤的操作信息，准备从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理，从卡组将1只与解放怪兽相同等级的鸟兽族怪兽特殊召唤
function c94145683.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有可用的怪兽区域，若无则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	-- 向玩家发送选择特殊召唤卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只与解放怪兽相同等级的鸟兽族怪兽
	local g=Duel.SelectMatchingCard(tp,c94145683.filter2,tp,LOCATION_DECK,0,1,1,nil,lv,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
