--アポート
-- 效果：
-- ①：1回合1次，只有对方场上才有怪兽存在的场合，支付800基本分才能发动。从手卡把1只念动力族怪兽特殊召唤。
function c6795211.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，只有对方场上才有怪兽存在的场合，支付800基本分才能发动。从手卡把1只念动力族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6795211,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c6795211.condition)
	e1:SetCost(c6795211.cost)
	e1:SetTarget(c6795211.target)
	e1:SetOperation(c6795211.operation)
	c:RegisterEffect(e1)
end
-- 发动条件：检查是否只有对方场上才有怪兽存在
function c6795211.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 检查对方场上的怪兽数量是否不为0
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)~=0
end
-- 发动代价：检查并支付800基本分
function c6795211.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，检查玩家是否能够支付800基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 扣除玩家800基本分作为发动代价
	Duel.PayLPCost(tp,800)
end
-- 过滤函数：筛选手卡中可以特殊召唤的念动力族怪兽
function c6795211.filter(c,e,sp)
	return c:IsRace(RACE_PSYCHO) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 发动准备：检查自己场上是否有空位，以及手卡中是否存在可特殊召唤的念动力族怪兽，并设置特殊召唤的操作信息
function c6795211.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c6795211.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁的操作信息为：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：从手卡选择1只念动力族怪兽特殊召唤到场上
function c6795211.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果此时自己场上没有可用的怪兽区域空格，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c6795211.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
