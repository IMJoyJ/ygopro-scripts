--幻獣機ブルーインパラス
-- 效果：
-- 把这张卡作为同调素材的场合，不是机械族怪兽的同调召唤不能使用，其他的同调素材怪兽必须是自己的手卡·场上的名字带有「幻兽机」的怪兽。只要自己场上有衍生物存在，这张卡不会被战斗以及效果破坏。此外，对方场上有怪兽存在，自己场上没有怪兽存在的场合，把墓地的这张卡从游戏中除外才能发动。把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
function c67489919.initial_effect(c)
	-- 只要自己场上有衍生物存在，这张卡不会被战斗以及效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 设置效果适用的条件为自己场上存在衍生物
	e1:SetCondition(aux.tkfcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- 此外，对方场上有怪兽存在，自己场上没有怪兽存在的场合，把墓地的这张卡从游戏中除外才能发动。把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(67489919,0))  --"特殊召唤Token"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(c67489919.spcon)
	-- 设置发动成本为将墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c67489919.sptg)
	e3:SetOperation(c67489919.spop)
	c:RegisterEffect(e3)
	-- 把这张卡作为同调素材的场合，不是机械族怪兽的同调召唤不能使用
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetValue(c67489919.synlimit)
	c:RegisterEffect(e5)
	-- 其他的同调素材怪兽必须是自己的手卡·场上的名字带有「幻兽机」的怪兽。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_TUNER_MATERIAL_LIMIT)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e6:SetTarget(c67489919.synlimit2)
	e6:SetValue(LOCATION_MZONE+LOCATION_HAND)
	c:RegisterEffect(e6)
end
-- 判定自己场上没有怪兽且对方场上有怪兽存在
function c67489919.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 检查对方场上的怪兽数量是否大于0
		and	Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 效果发动的目标选择与合法性检测，确认怪兽区域有空位且可以特殊召唤衍生物
function c67489919.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定的衍生物怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) end
	-- 设置操作信息，表明该效果包含产生衍生物的操作
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息，表明该效果包含特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理的执行函数，在场上特殊召唤1只「幻兽机衍生物」
function c67489919.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 确认玩家是否能够特殊召唤该衍生物
	if Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		-- 创建「幻兽机衍生物」的卡片对象
		local token=Duel.CreateToken(tp,67489920)
		-- 将衍生物以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 限制同调素材用途，若同调怪兽不是机械族，则不能将此卡作为同调素材
function c67489919.synlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_MACHINE)
end
-- 限制同调素材范围，判定其他的同调素材怪兽是否为「幻兽机」怪兽
function c67489919.synlimit2(e,c)
	return c:IsSetCard(0x101b)
end
