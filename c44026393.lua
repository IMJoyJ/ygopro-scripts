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
	-- 设置③的破坏免疫效果仅在己方场上有衍生物（Token）存在时才适用。
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
-- 计算这张卡的等级上升量：检索自己场上存在的「幻兽机衍生物」，并将其等级合计作为上升数值。
function c44026393.lvval(e,c)
	local tp=c:GetControler()
	-- 获取己方场上所有卡号为31533705（幻兽机衍生物）的怪兽，返回它们的等级合计值。
	return Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,31533705):GetSum(Card.GetLevel)
end
-- ①的发动代价处理：从手牌丢弃1张卡作为代价，先检查是否有可丢弃的手牌。
function c44026393.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段（chk==0）确认手牌中是否存在1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行代价：从手牌选择并丢弃1张卡，丢弃原因记为代价与丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- ①的发动条件检查：确认自己主要怪兽区有空位且可以特殊召唤「幻兽机衍生物」。
function c44026393.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件之一：自己场上主要怪兽区存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：玩家当前可以特殊召唤1只「幻兽机衍生物」（机械族·风·3星·攻/守0）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,44026394,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) end
	-- 向系统登记本次效果处理将包含衍生物生成（CATEGORY_TOKEN），对象为1只，用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 向系统登记本次效果处理将包含特殊召唤（CATEGORY_SPECIAL_SUMMON），对象为1只，用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ①的效果处理：先为双方场上符合条件的怪兽附加“不能作为融合·同调·超量·连接素材”的自肃（直到回合结束），再在自己的主要怪兽区特殊召唤1只「幻兽机衍生物」。
function c44026393.spop(e,tp,eg,ep,ev,re,r,rp)
	-- ①：在自己场上把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。这个效果的发动后，直到回合结束时自己不是「幻兽机」怪兽不能作为融合·同调·超量·连接召唤的素材。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(0xff,0xff)
	-- 设置限制效果的对象为“不是「幻兽机」字段的怪兽”（非0x101b系列），用于后续禁止其作为素材。
	e1:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,0x101b)))
	e1:SetValue(c44026393.fuslimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能作为融合素材”的自肃效果注册到场上，对双方所有符合条件的卡生效，直到回合结束。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetValue(c44026393.sumlimit)
	-- 将“不能作为同调素材”的自肃效果注册到场上，对双方所有符合条件的卡生效，直到回合结束。
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	-- 将“不能作为超量素材”的自肃效果注册到场上，对双方所有符合条件的卡生效，直到回合结束。
	Duel.RegisterEffect(e3,tp)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	-- 将“不能作为连接素材”的自肃效果注册到场上，对双方所有符合条件的卡生效，直到回合结束。
	Duel.RegisterEffect(e4,tp)
	-- 效果处理时再次确认主要怪兽区是否有空位，若无空位则直接结束处理（但自肃限制已适用）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 确认玩家仍然可以特殊召唤「幻兽机衍生物」，避免因其他效果干扰而无法特招。
	if Duel.IsPlayerCanSpecialSummonMonster(tp,44026394,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		-- 创建1只属于tp的「幻兽机衍生物」卡片（卡号44026394）。
		local token=Duel.CreateToken(tp,44026394)
		-- 将衍生物以正面表示特殊召唤到tp自己场上，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义“不能作为融合素材”的条件：该卡由当前效果控制者所控制，且正被用于融合召唤时，禁止作为素材。
function c44026393.fuslimit(e,c,sumtype)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer()) and sumtype==SUMMON_TYPE_FUSION
end
-- 定义“不能作为同调/超量/连接素材”的条件：只要该卡由当前效果控制者所控制，即禁止作为对应召唤的素材。
function c44026393.sumlimit(e,c)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end
