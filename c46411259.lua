--突然変異
-- 效果：
-- 把自己场上的1只怪兽作为祭品。从融合卡组把1只等级与作为祭品的怪兽的等级相同的融合怪兽特殊召唤。
function c46411259.initial_effect(c)
	-- ①：把自己场上1只怪兽解放才能发动。等级和那只怪兽相同的1只融合怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetLabel(0)
	e1:SetCost(c46411259.cost)
	e1:SetTarget(c46411259.target)
	e1:SetOperation(c46411259.activate)
	c:RegisterEffect(e1)
end
-- 代价预检：将效果标签设为100作为标记，表示玩家场上存在可解放的怪兽，允许效果发动；实际解放怪兽在目标选择阶段处理。
function c46411259.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 解放怪兽的过滤函数：要求怪兽等级大于0，且额外卡组中存在1只等级相同、可被特殊召唤的融合怪兽。
function c46411259.filter1(c,e,tp)
	local lv=c:GetLevel()
	-- 返回该怪兽是否可作为解放对象：等级大于0，且额外卡组中存在符合条件的融合怪兽。
	return lv>0 and Duel.IsExistingMatchingCard(c46411259.filter2,tp,LOCATION_EXTRA,0,1,nil,lv,e,tp,c)
end
-- 额外卡组融合怪兽的过滤函数：要求是融合怪兽、等级等于解放怪兽的等级、可以被当前效果特殊召唤，且解放后额外怪兽区有空格。
function c46411259.filter2(c,lv,e,tp,mc)
	return c:IsType(TYPE_FUSION) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认在解放代价怪兽mc后，仍有足够额外怪兽区空格来特殊召唤这只融合怪兽。
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 目标处理函数：发动时确认可解放怪兽，选择1只并解放作为代价，记录其等级，并设置本次效果为从额外卡组特殊召唤1只怪兽。
function c46411259.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查玩家场上是否存在至少1只可作为解放的怪兽，且后续能够特殊召唤对应的融合怪兽。
		return Duel.CheckReleaseGroup(tp,c46411259.filter1,1,nil,e,tp)
	end
	-- 选择要解放的1只怪兽，筛选条件为filter1。
	local rg=Duel.SelectReleaseGroup(tp,c46411259.filter1,1,1,nil,e,tp)
	e:SetLabel(rg:GetFirst():GetLevel())
	-- 将选择的怪兽解放，作为发动代价。
	Duel.Release(rg,REASON_COST)
	-- 将本次效果的处理信息设置为从额外卡组特殊召唤1只怪兽，便于其他效果连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数：根据之前保存的解放怪兽等级，从额外卡组选择符合条件的融合怪兽并特殊召唤。
function c46411259.activate(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 给玩家显示“请选择要特殊召唤的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只等级等于已解放怪兽等级且能被特殊召唤的融合怪兽。
	local g=Duel.SelectMatchingCard(tp,c46411259.filter2,tp,LOCATION_EXTRA,0,1,1,nil,lv,e,tp,nil)
	if g:GetCount()>0 then
		-- 将选择的融合怪兽以表侧攻击表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
