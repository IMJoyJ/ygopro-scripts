--モロコシーナ
-- 效果：
-- 1回合1次，自己的主要阶段2支付500基本分才能发动。在自己场上把1只「玉米粒衍生物」（植物族·地·1星·攻/守0）特殊召唤。
function c74983881.initial_effect(c)
	-- 1回合1次，自己的主要阶段2支付500基本分才能发动。在自己场上把1只「玉米粒衍生物」（植物族·地·1星·攻/守0）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74983881,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c74983881.spcon)
	e1:SetCost(c74983881.spcost)
	e1:SetTarget(c74983881.sptg)
	e1:SetOperation(c74983881.spop)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件（主要阶段2）的函数
function c74983881.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 定义效果发动代价（支付500基本分）的函数
function c74983881.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动确认阶段，检查玩家是否能够支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 支付500基本分作为发动的代价
	Duel.PayLPCost(tp,500)
end
-- 定义效果发动时的目标确认与连锁信息设置的函数
function c74983881.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动确认阶段，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能够特殊召唤指定的衍生物怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,74983882,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_PLANT,ATTRIBUTE_EARTH) end
	-- 设置连锁信息，表明此效果包含产生衍生物的操作
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁信息，表明此效果包含特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 定义效果处理（特殊召唤衍生物）的函数
function c74983881.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上没有空余的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果处理时，若玩家不能特殊召唤该衍生物则不处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,74983882,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_PLANT,ATTRIBUTE_EARTH) then return end
	-- 在内存中创建「玉米粒衍生物」的卡片数据
	local token=Duel.CreateToken(tp,74983882)
	-- 将创建的衍生物以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
