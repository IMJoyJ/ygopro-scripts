--海晶乙女シーホース
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以从手卡往作为「海晶少女」连接怪兽所连接区的自己场上特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从手卡把1只水属性怪兽在作为「海晶少女」连接怪兽所连接区的自己场上特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c36492575.initial_effect(c)
	-- ①：这张卡可以从手卡往作为「海晶少女」连接怪兽所连接区的自己场上特殊召唤。
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
	-- ②：把墓地的这张卡除外才能发动。从手卡把1只水属性怪兽在作为「海晶少女」连接怪兽所连接区的自己场上特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36492575,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,36492576)
	-- 设置效果条件为：这张卡送去墓地的回合不能发动此效果
	e2:SetCondition(aux.exccon)
	-- 设置效果代价为：把这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c36492575.sptg)
	e2:SetOperation(c36492575.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查场上是否存在表侧表示的「海晶少女」连接怪兽
function c36492575.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b) and c:IsType(TYPE_LINK)
end
-- 计算可用的连接区域：遍历场上所有「海晶少女」连接怪兽，获取其连接区域并合并
function c36492575.checkzone(tp)
	local zone=0
	-- 获取场上所有「海晶少女」连接怪兽
	local g=Duel.GetMatchingGroup(c36492575.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 遍历所有「海晶少女」连接怪兽
	for tc in aux.Next(g) do
		zone=bit.bor(zone,tc:GetLinkedZone(tp))
	end
	return bit.band(zone,0x1f)
end
-- 判断特殊召唤条件：检查是否有足够的主怪兽区域用于特殊召唤
function c36492575.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=c36492575.checkzone(tp)
	-- 判断主怪兽区域是否足够
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 设置特殊召唤时的区域参数：返回连接区域
function c36492575.spval(e,c)
	local tp=c:GetControler()
	local zone=c36492575.checkzone(tp)
	return 0,zone
end
-- 过滤函数：检查手牌中是否含有水属性且可特殊召唤的怪兽
function c36492575.spfilter(c,e,tp,zone)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 设置效果目标：检查手牌中是否存在满足条件的水属性怪兽
function c36492575.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=c36492575.checkzone(tp)
	if chk==0 then return zone~=0
		-- 检查手牌中是否存在满足条件的水属性怪兽
		and Duel.IsExistingMatchingCard(c36492575.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,zone) end
	-- 设置连锁操作信息：确定将要特殊召唤的怪兽数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：选择并特殊召唤符合条件的水属性怪兽
function c36492575.spop(e,tp,eg,ep,ev,re,r,rp)
	local zone=c36492575.checkzone(tp)
	if zone==0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择一只满足条件的水属性怪兽
	local g=Duel.SelectMatchingCard(tp,c36492575.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,zone)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
