--幻獣機ライテン
-- 效果：
-- ①：丢弃1张手卡才能发动。在自己场上把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。这个效果的发动后，直到回合结束时自己不是「幻兽机」怪兽不能作为融合·同调·超量·连接召唤的素材。
-- ②：这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。
-- ③：只要自己场上有衍生物存在，这张卡不会被战斗·效果破坏。
function c44026393.initial_effect(c)
	-- ②：这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(c44026393.lvval)
	c:RegisterEffect(e1)
	-- ③：只要自己场上有衍生物存在，这张卡不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 该效果在满足条件时触发，用于判断场上是否存在衍生物。
	e2:SetCondition(aux.tkfcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- ①：丢弃1张手卡才能发动。在自己场上把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。这个效果的发动后，直到回合结束时自己不是「幻兽机」怪兽不能作为融合·同调·超量·连接召唤的素材。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(44026393,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(c44026393.spcost)
	e4:SetTarget(c44026393.sptg)
	e4:SetOperation(c44026393.spop)
	c:RegisterEffect(e4)
end
-- 计算场上所有「幻兽机衍生物」的等级总和，用于提升此卡的等级。
function c44026393.lvval(e,c)
	local tp=c:GetControler()
	-- 获取场上所有「幻兽机衍生物」的等级总和。
	return Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,31533705):GetSum(Card.GetLevel)
end
-- 支付效果的发动代价：丢弃1张手卡。
function c44026393.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃手卡的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃1张手卡的操作。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 设置效果的发动条件：确认场上存在空位且可以特殊召唤衍生物。
function c44026393.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的空间进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否可以特殊召唤指定的衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,44026394,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) end
	-- 设置操作信息：标记将要特殊召唤衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：标记将要特殊召唤衍生物。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 执行效果的处理流程：设置不能作为融合/同调/超量/连接素材的效果，并特殊召唤衍生物。
function c44026393.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 创建并注册多个效果，禁止自己场上的非幻兽机怪兽作为融合/同调/超量/连接召唤的素材。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(0xff,0xff)
	-- 设置目标筛选条件：排除幻兽机衍生物以外的怪兽。
	e1:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,0x101b)))
	e1:SetValue(c44026393.fuslimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册到玩家的场上。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetValue(c44026393.sumlimit)
	-- 将效果e2注册到玩家的场上。
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	-- 将效果e3注册到玩家的场上。
	Duel.RegisterEffect(e3,tp)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	-- 将效果e4注册到玩家的场上。
	Duel.RegisterEffect(e4,tp)
	-- 检查场上是否还有空位，若无则不继续特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查是否可以特殊召唤衍生物。
	if Duel.IsPlayerCanSpecialSummonMonster(tp,44026394,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		-- 创建一个幻兽机衍生物。
		local token=Duel.CreateToken(tp,44026394)
		-- 将创建的衍生物特殊召唤到场上。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断目标怪兽是否为融合召唤的素材。
function c44026393.fuslimit(e,c,sumtype)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer()) and sumtype==SUMMON_TYPE_FUSION
end
-- 判断目标怪兽是否为其他召唤方式的素材。
function c44026393.sumlimit(e,c)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end
