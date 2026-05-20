--幻獣機オライオン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己场上有衍生物存在，这张卡不会被战斗·效果破坏。
-- ②：这张卡被送去墓地的场合才能发动。在自己场上把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
-- ③：把墓地的这张卡除外才能发动。进行手卡1只「幻兽机」怪兽的召唤。
function c72291078.initial_effect(c)
	-- ①：只要自己场上有衍生物存在，这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 设置效果适用条件为自己场上有衍生物存在
	e1:SetCondition(aux.tkfcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外才能发动。进行手卡1只「幻兽机」怪兽的召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(72291078,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	-- 设置发动成本为把墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c72291078.target)
	e3:SetOperation(c72291078.operation)
	c:RegisterEffect(e3)
	-- ②：这张卡被送去墓地的场合才能发动。在自己场上把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(72291078,1))  --"特殊召唤衍生物"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,72291078)
	e4:SetTarget(c72291078.sptg)
	e4:SetOperation(c72291078.spop)
	c:RegisterEffect(e4)
end
-- 过滤函数：选择手卡中可以进行通常召唤的「幻兽机」怪兽
function c72291078.filter(c)
	return c:IsSetCard(0x101b) and c:IsSummonable(true,nil)
end
-- 召唤效果的靶子函数（检查手卡是否存在可召唤的「幻兽机」怪兽，并设置操作信息）
function c72291078.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只满足过滤条件的「幻兽机」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c72291078.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置连锁处理的操作信息为进行1只怪兽的通常召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 召唤效果的执行函数（让玩家选择手卡中的「幻兽机」怪兽并进行通常召唤）
function c72291078.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送选择要召唤的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从手卡选择1只满足过滤条件的「幻兽机」怪兽
	local g=Duel.SelectMatchingCard(tp,c72291078.filter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 让玩家对选中的怪兽进行通常召唤（忽略每回合的通常召唤次数限制）
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 特殊召唤衍生物效果的靶子函数（检查怪兽区域空格及是否能特招特定属性种族的衍生物，并设置操作信息）
function c72291078.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤1只「幻兽机衍生物」（机械族·风·3星·攻/守0）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) end
	-- 设置连锁处理的操作信息为产生1个衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁处理的操作信息为特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 特殊召唤衍生物效果的执行函数（在场上特殊召唤1只「幻兽机衍生物」）
function c72291078.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的主要怪兽区域是否已无空位，若无则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 再次确认玩家是否可以特殊召唤该衍生物
	if Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		-- 创建卡号为72291079的「幻兽机衍生物」卡片对象
		local token=Duel.CreateToken(tp,72291079)
		-- 将创建的衍生物以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
