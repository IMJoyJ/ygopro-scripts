--幻獣機テザーウルフ
-- 效果：
-- ①：这张卡召唤成功的场合发动。在自己场上把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
-- ②：这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。
-- ③：只要自己场上有衍生物存在，这张卡不会被战斗·效果破坏。
-- ④：这张卡和对方怪兽进行战斗的从伤害步骤开始时到伤害计算前1次，把自己场上1只衍生物解放才能发动。这张卡的攻击力直到回合结束时上升800。
function c67922702.initial_effect(c)
	-- ②：这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(c67922702.lvval)
	c:RegisterEffect(e1)
	-- ③：只要自己场上有衍生物存在，这张卡不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 设置效果适用的条件为自己场上存在衍生物。
	e2:SetCondition(aux.tkfcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- ①：这张卡召唤成功的场合发动。在自己场上把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(67922702,0))  --"特殊召唤Token"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetTarget(c67922702.sptg)
	e4:SetOperation(c67922702.spop)
	c:RegisterEffect(e4)
	-- ④：这张卡和对方怪兽进行战斗的从伤害步骤开始时到伤害计算前1次，把自己场上1只衍生物解放才能发动。这张卡的攻击力直到回合结束时上升800。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(67922702,1))  --"攻击上升"
	e5:SetCategory(CATEGORY_ATKCHANGE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e5:SetHintTiming(TIMING_DAMAGE_STEP)
	e5:SetCondition(c67922702.atkcon)
	e5:SetCost(c67922702.atkcost)
	e5:SetOperation(c67922702.atkop)
	c:RegisterEffect(e5)
end
-- 计算自身等级上升数值的辅助函数。
function c67922702.lvval(e,c)
	local tp=c:GetControler()
	-- 获取自己场上所有「幻兽机衍生物」的等级合计值。
	return Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,31533705):GetSum(Card.GetLevel)
end
-- 特殊召唤衍生物效果的发动准备与目标确认函数。
function c67922702.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示此效果包含产生衍生物的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息，表示此效果包含特殊召唤怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 特殊召唤衍生物效果的具体处理函数。
function c67922702.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽区域是否有空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查玩家是否具有特殊召唤指定属性、种族、等级等数值的衍生物的权限。
	if Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		-- 在系统后台创建用于特殊召唤的「幻兽机衍生物」卡片对象。
		local token=Duel.CreateToken(tp,67922703)
		-- 将创建的衍生物以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 攻击力上升效果的发动条件检查函数。
function c67922702.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的决斗阶段。
	local phase=Duel.GetCurrentPhase()
	-- 检查是否处于伤害步骤、尚未进行伤害计算，且自身存在战斗对象。
	return e:GetHandler():GetBattleTarget()~=nil and phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()
end
-- 攻击力上升效果的发动代价处理函数。
function c67922702.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(67922702)==0
		-- 并且检查自己场上是否存在可以作为解放代价的衍生物。
		and Duel.CheckReleaseGroup(tp,Card.IsType,1,nil,TYPE_TOKEN) end
	-- 让玩家选择自己场上的1只衍生物。
	local g=Duel.SelectReleaseGroup(tp,Card.IsType,1,1,nil,TYPE_TOKEN)
	-- 将选中的衍生物解放作为发动效果的代价。
	Duel.Release(g,REASON_COST)
	e:GetHandler():RegisterFlagEffect(67922702,RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 攻击力上升效果的具体处理函数。
function c67922702.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡的攻击力直到回合结束时上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(800)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
