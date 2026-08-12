--突然変異
-- 效果：
-- 把自己场上的1只怪兽作为祭品。从融合卡组把1只等级与作为祭品的怪兽的等级相同的融合怪兽特殊召唤。
function c46411259.initial_effect(c)
	-- 创建效果，设置为魔陷发动、自由时点，指定特殊召唤为效果分类，并设置成本、目标和处理函数
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
-- 设置cost函数，将标签设为100表示已支付费用
function c46411259.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤函数filter1：检查场上是否存在等级大于0且融合卡组中存在对应等级融合怪兽的怪兽
function c46411259.filter1(c,e,tp)
	local lv=c:GetLevel()
	-- 判断融合卡组中是否存在等级与祭品怪兽相同的融合怪兽
	return lv>0 and Duel.IsExistingMatchingCard(c46411259.filter2,tp,LOCATION_EXTRA,0,1,nil,lv,e,tp,c)
end
-- 过滤函数filter2：筛选满足类型为融合、等级等于lv、可特殊召唤且有足够召唤位置的融合怪兽
function c46411259.filter2(c,lv,e,tp,mc)
	return c:IsType(TYPE_FUSION) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查目标怪兽是否有足够的额外卡组召唤位置
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置target函数，判断是否满足条件并选择祭品怪兽进行解放
function c46411259.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查场上是否存在满足filter1条件的怪兽作为祭品
		return Duel.CheckReleaseGroup(tp,c46411259.filter1,1,nil,e,tp)
	end
	-- 从场上选择满足filter1条件的1只怪兽作为祭品
	local rg=Duel.SelectReleaseGroup(tp,c46411259.filter1,1,1,nil,e,tp)
	e:SetLabel(rg:GetFirst():GetLevel())
	-- 将选中的怪兽进行解放作为发动代价
	Duel.Release(rg,REASON_COST)
	-- 设置操作信息，表示将特殊召唤一张来自额外卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 设置activate函数，处理效果发动后的特殊召唤流程
function c46411259.activate(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择等级与祭品怪兽相同的融合怪兽
	local g=Duel.SelectMatchingCard(tp,c46411259.filter2,tp,LOCATION_EXTRA,0,1,1,nil,lv,e,tp,nil)
	if g:GetCount()>0 then
		-- 将选中的融合怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
