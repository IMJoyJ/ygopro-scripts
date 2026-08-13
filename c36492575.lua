--海晶乙女シーホース
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以从手卡往作为「海晶少女」连接怪兽所连接区的自己场上特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从手卡把1只水属性怪兽在作为「海晶少女」连接怪兽所连接区的自己场上特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c36492575.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：这张卡可以从手卡往作为「海晶少女」连接怪兽所连接区的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36492575,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,36492575+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c36492575.spcon)
	e1:SetValue(c36492575.spval)
	c:RegisterEffect(e1)
	-- ②的效果1回合只能使用1次。②：把墓地的这张卡除外才能发动。从手卡把1只水属性怪兽在作为「海晶少女」连接怪兽所连接区的自己场上特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36492575,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,36492576)
	-- 设置②效果的发动条件：若这张卡不是本回合被送去墓地（或灵摆返回等特殊情况）则允许发动，对应“这个效果在这张卡送去墓地的回合不能发动”。
	e2:SetCondition(aux.exccon)
	-- 设置②效果的发动代价：把墓地中的这张卡除外作为发动的COST，对应“把墓地的这张卡除外才能发动”。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c36492575.sptg)
	e2:SetOperation(c36492575.spop)
	c:RegisterEffect(e2)
end
-- 定义筛选函数：判断场上的一张卡是否为表侧表示、卡名含有「海晶少女」且为连接怪兽，用于获取能给本卡提供连接区的连接怪兽。
function c36492575.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b) and c:IsType(TYPE_LINK)
end
-- 定义连接区计算函数：收集双方场上所有符合条件的「海晶少女」连接怪兽，将所有连接怪兽指向的区域（连接区）合并为位掩码，并只保留主要怪兽区（0x1f）部分，返回可用的特殊召唤区域列表。
function c36492575.checkzone(tp)
	local zone=0
	-- 获取双方场上所有满足cfilter条件的「海晶少女」连接怪兽集合，作为计算连接区域的基础。
	local g=Duel.GetMatchingGroup(c36492575.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 遍历该连接怪兽集合，依次取出每只怪兽，将其连接区域累加到zone位掩码中。
	for tc in aux.Next(g) do
		zone=bit.bor(zone,tc:GetLinkedZone(tp))
	end
	return bit.band(zone,0x1f)
end
-- 定义①规则特殊召唤的发动条件：当以规则方式从手牌特殊召唤本卡时，若手牌拥有者场上存在由「海晶少女」连接怪兽连接出的可用主要怪兽区，则允许发动（非玩家发起的规则召唤直接返回true）。
function c36492575.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=c36492575.checkzone(tp)
	-- 检查玩家tp场上在计算出的连接区域内是否还有至少1个可用的主要怪兽区空位，以确保本卡能特殊召唤到连接区。
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 定义①规则特殊召唤的参数值：返回计算得到的连接区zone作为特殊召唤时的可用区域，使本卡只能特殊召唤到该连接区。
function c36492575.spval(e,c)
	local tp=c:GetControler()
	local zone=c36492575.checkzone(tp)
	return 0,zone
end
-- 定义②效果可特殊召唤的手牌怪兽的筛选条件：该怪兽必须为水属性，且能被效果特殊召唤到指定连接区zone，并以表侧表示特殊召唤。
function c36492575.spfilter(c,e,tp,zone)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 定义②效果的发动目标检查：获取当前连接区，若存在连接区且手卡中有满足条件的水属性怪兽，则允许发动（chk==0为发动时点检查）。
function c36492575.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=c36492575.checkzone(tp)
	if chk==0 then return zone~=0
		-- 检查手卡中是否存在至少1只满足spfilter条件（水属性且可特殊召唤）的水属性怪兽，确保有可特殊召唤的对象。
		and Duel.IsExistingMatchingCard(c36492575.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,zone) end
	-- 设置该连锁的操作信息，标明本效果在解决时将从手卡特殊召唤1只怪兽（数量为1，来源为手卡），用于触发相关卡片的效果互动。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 定义②效果解决的执行操作：重新计算当前连接区，若已不存在连接区则终止；否则让玩家从手卡选择1只满足条件的水属性怪兽，并特殊召唤到连接区。
function c36492575.spop(e,tp,eg,ep,ev,re,r,rp)
	local zone=c36492575.checkzone(tp)
	if zone==0 then return end
	-- 弹出选择卡片的UI提示“请选择要特殊召唤的卡”，为接下来选择手卡怪兽做提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只符合spfilter条件的水属性怪兽，用于随后特殊召唤。
	local g=Duel.SelectMatchingCard(tp,c36492575.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,zone)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到玩家tp场上由连接区参数zone指定的区域（已提前检查过召唤条件和苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
