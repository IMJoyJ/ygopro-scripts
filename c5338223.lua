--強制進化
-- 效果：
-- 把自己场上1只名字带有「进化虫」的怪兽解放发动。从卡组把1只名字带有「进化龙」的怪兽特殊召唤。这个效果特殊召唤的怪兽变成当作用名字带有「进化虫」的怪兽的效果特殊召唤使用。
function c5338223.initial_effect(c)
	-- 效果发动时创建一个连锁处理，设置为自由时点，具有特殊召唤分类，需要支付解放怪兽的费用，并设置对应的处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c5338223.cost)
	e1:SetTarget(c5338223.target)
	e1:SetOperation(c5338223.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选可以被解放的「进化虫」怪兽，满足条件包括：是进化虫卡组、在场上或有剩余召唤次数、且为表侧表示或控制者为玩家
function c5338223.cfilter(c,ft,tp)
	return c:IsSetCard(0x304e)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
-- 支付费用阶段，设置标签为1，检查是否有满足条件的怪兽可解放并进行选择和解放操作
function c5338223.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 获取玩家当前场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 判断是否满足支付费用条件，即有足够召唤次数且场上有符合条件的怪兽可解放
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c5338223.cfilter,1,nil,ft,tp) end
	-- 从场上选择一张满足条件的怪兽作为解放对象
	local rg=Duel.SelectReleaseGroup(tp,c5338223.cfilter,1,1,nil,ft,tp)
	-- 将选中的怪兽以支付代价的方式进行解放
	Duel.Release(rg,REASON_COST)
end
-- 过滤函数，用于筛选可以特殊召唤的「进化龙」怪兽，必须是进化龙卡组且能被特殊召唤
function c5338223.spfilter(c,e,tp)
	return c:IsSetCard(0x604e) and c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_EVOLTILE,tp,false,false)
end
-- 设置效果的目标，判断是否满足发动条件，包括是否有足够的召唤区域和卡组中是否存在可特殊召唤的怪兽
function c5338223.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查卡组中是否存在满足条件的进化龙怪兽
			return Duel.IsExistingMatchingCard(c5338223.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		else
			-- 检查玩家场上是否有足够的召唤区域
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 同时检查卡组中是否存在满足条件的进化龙怪兽
				and Duel.IsExistingMatchingCard(c5338223.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		end
	end
	e:SetLabel(0)
	-- 设置操作信息，表示本次处理将特殊召唤一张来自卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时执行的操作函数，判断是否满足召唤条件并选择和特殊召唤怪兽
function c5338223.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的召唤区域，若无则直接返回不执行召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择一张满足条件的进化龙怪兽作为特殊召唤对象
	local g=Duel.SelectMatchingCard(tp,c5338223.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以进化虫的效果方式特殊召唤到场上
		Duel.SpecialSummon(g,SUMMON_VALUE_EVOLTILE,tp,tp,false,false,POS_FACEUP)
	end
end
