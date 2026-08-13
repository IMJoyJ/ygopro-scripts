--幻獣機エアロスバード
-- 效果：
-- ①：1回合1次，把「幻兽机 航空飞鸟」以外的自己墓地1只「幻兽机」怪兽除外才能发动。在自己场上把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
-- ②：这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。
-- ③：只要自己场上有衍生物存在，这张卡不会被战斗·效果破坏。
function c16943770.initial_effect(c)
	-- ②：这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(c16943770.lvval)
	c:RegisterEffect(e1)
	-- ③：只要自己场上有衍生物存在，这张卡不会被战斗·效果破坏。（对应‘不会被战斗破坏’）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 设置该效果的条件：仅在自己场上有衍生物存在时适用。
	e2:SetCondition(aux.tkfcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- ①：1回合1次，把「幻兽机 航空飞鸟」以外的自己墓地1只「幻兽机」怪兽除外才能发动。在自己场上把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(16943770,0))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c16943770.spcost)
	e4:SetTarget(c16943770.sptg)
	e4:SetOperation(c16943770.spop)
	c:RegisterEffect(e4)
end
-- 计算这张卡的等级上升数值：为自己场上所有「幻兽机衍生物」的等级合计。
function c16943770.lvval(e,c)
	local tp=c:GetControler()
	-- 获取自己场上所有「幻兽机衍生物」（卡号31533705）并求其等级合计值。
	return Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,31533705):GetSum(Card.GetLevel)
end
-- 过滤条件：墓地中满足「幻兽机」字段、不是「幻兽机 航空飞鸟」自身、且可以作为代价除外的怪兽。
function c16943770.cfilter(c)
	return c:IsSetCard(0x101b) and not c:IsCode(16943770) and c:IsAbleToRemoveAsCost()
end
-- ①效果的发动代价：从自己墓地选择「幻兽机 航空飞鸟」以外的1只「幻兽机」怪兽除外。
function c16943770.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查代价：自己墓地是否存在至少1只符合条件的「幻兽机」怪兽（非本卡、可作为除外代价）。
	if chk==0 then return Duel.IsExistingMatchingCard(c16943770.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示选择要除外的卡的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的「幻兽机」怪兽。
	local g=Duel.SelectMatchingCard(tp,c16943770.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的「幻兽机」怪兽以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的发动条件检查：自己场上有可用怪兽区域，且自己能特殊召唤「幻兽机衍生物」。
function c16943770.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己主要怪兽区有空余位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认玩家可以特殊召唤「幻兽机衍生物」（机械族·风·3星·攻/守0）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) end
	-- 设置本效果含有衍生物特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置本效果含有特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ①效果处理：在自己场上特殊召唤1只「幻兽机衍生物」。
function c16943770.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己主要怪兽区有空位，否则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 处理时再次确认可以特殊召唤「幻兽机衍生物」。
	if Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		-- 创建1只「幻兽机衍生物」（卡号16943771）。
		local token=Duel.CreateToken(tp,16943771)
		-- 将衍生物以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
