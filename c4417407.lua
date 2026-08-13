--幻獣機ブラックファルコン
-- 效果：
-- 这张卡攻击宣言时，把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。只要自己场上有衍生物存在，这张卡不会被战斗以及效果破坏。此外，1回合1次，把1只衍生物解放才能发动。选择对方场上1只怪兽变成表侧守备表示。这个效果在对方回合也能发动。
function c4417407.initial_effect(c)
	-- 这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(c4417407.lvval)
	c:RegisterEffect(e1)
	-- 只要自己场上有衍生物存在，这张卡不会被战斗以及效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 设置「不会被战斗破坏」效果的适用条件：自己场上有衍生物存在（aux.tkfcon判断）。
	e2:SetCondition(aux.tkfcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- 这张卡攻击宣言时，把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(4417407,0))  --"特殊召唤Token"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetTarget(c4417407.sptg)
	e4:SetOperation(c4417407.spop)
	c:RegisterEffect(e4)
	-- 此外，1回合1次，把1只衍生物解放才能发动。选择对方场上1只怪兽变成表侧守备表示。这个效果在对方回合也能发动。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(4417407,1))  --"改变表示形式"
	e5:SetCategory(CATEGORY_POSITION)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetHintTiming(TIMING_BATTLE_PHASE)
	e5:SetCountLimit(1)
	e5:SetCost(c4417407.poscost)
	e5:SetTarget(c4417407.postg)
	e5:SetOperation(c4417407.posop)
	c:RegisterEffect(e5)
end
-- 计算此卡等级上升的数值，即自己场上所有「幻兽机衍生物」的等级合计。
function c4417407.lvval(e,c)
	local tp=c:GetControler()
	-- 获取自己场上所有卡号为31533705（幻兽机衍生物）的怪兽，并返回其等级合计数值。
	return Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,31533705):GetSum(Card.GetLevel)
end
-- 特殊召唤衍生物效果的目标设定：效果可发动时返回true，并设置操作信息为特殊召唤1只衍生物。
function c4417407.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息中包含衍生物生成分类，表示本次处理会生成1只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息中包含特殊召唤分类，表示本次处理会特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 特殊召唤衍生物的实际处理：若己方怪兽区有空位且允许特殊召唤，则生成1只「幻兽机衍生物」以表侧攻击表示特殊召唤到自己场上。
function c4417407.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方主要怪兽区是否有空位，若无空位则无法特殊召唤，效果处理中止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查玩家tp是否能够特殊召唤参数指定的衍生物（「幻兽机衍生物」，机械族/风/3星/攻守0），避免受到不能特殊召唤的限制。
	if Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		-- 由tp玩家生成1只卡号为4417408的衍生物Token（幻兽机衍生物）。
		local token=Duel.CreateToken(tp,4417408)
		-- 将生成的衍生物以表侧攻击表示特殊召唤到tp自己场上（遵守召唤条件和苏生限制）。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 该效果的发动COST：检查、选择并解放自己场上1只衍生物。
function c4417407.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己场上存在至少1只可解放的衍生物，否则不能发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsType,1,nil,TYPE_TOKEN) end
	-- 让玩家选择自己场上1只衍生物作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsType,1,1,nil,TYPE_TOKEN)
	-- 将选择的衍生物解放（REASON_COST），作为发动效果的代价。
	Duel.Release(g,REASON_COST)
end
-- 定义效果对象过滤条件：对方场上表侧攻击表示且可以变更表示形式的怪兽。
function c4417407.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 取对象处理：效果发动时选择对方场上1只表侧攻击表示且可变更表示形式的怪兽作为对象，并显示选择提示。
function c4417407.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c4417407.filter(chkc) end
	-- 目标检查：确认对方场上是否存在至少1只符合条件的表侧攻击表示且可变更表示形式的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c4417407.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家发送“请选择要改变表示形式的怪兽”的选择提示，用于选择目标卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家从对方场上选择1只符合条件的怪兽，并将其登记为当前连锁的效果对象（取对象）。
	Duel.SelectTarget(tp,c4417407.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 改变表示形式效果的实际处理：获取对象怪兽，若其仍与效果关联且不是表侧守备表示，则变更为表侧守备表示。
function c4417407.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时当前连锁的第一个对象卡（即被选择的那只对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsPosition(POS_FACEUP_DEFENSE) then
		-- 将对象怪兽的表示形式变更为表侧守备表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end
