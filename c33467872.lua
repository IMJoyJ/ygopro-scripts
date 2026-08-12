--深海のコレペティ
-- 效果：
-- 「深海歌后」＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己·对方回合1次，从手卡丢弃1只4星以下的水属性怪兽才能发动。这张卡的攻击力直到回合结束时上升800。
-- ②：同调召唤的这张卡被送去墓地的场合，以「深海艺术指导」以外的自己墓地1只5星以上的水属性怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个回合，自己不是水属性怪兽不能特殊召唤。
function c33467872.initial_effect(c)
	-- 为该怪兽添加融合召唤时允许使用的素材代码列表，指定素材必须为卡号78868119的怪兽
	aux.AddMaterialCodeList(c,78868119)
	-- 为该怪兽添加同调召唤手续，要求1只满足条件的调整和1只满足条件的非调整怪兽作为素材
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsCode,78868119),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：自己·对方回合1次，从手卡丢弃1只4星以下的水属性怪兽才能发动。这张卡的攻击力直到回合结束时上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33467872,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1)
	-- 设置效果发动条件为不能在伤害步骤发动
	e1:SetCondition(aux.dscon)
	e1:SetCost(c33467872.atkcost)
	e1:SetOperation(c33467872.atkop)
	c:RegisterEffect(e1)
	-- ②：同调召唤的这张卡被送去墓地的场合，以「深海艺术指导」以外的自己墓地1只5星以上的水属性怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个回合，自己不是水属性怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33467872,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,33467872)
	e2:SetCondition(c33467872.spcon)
	e2:SetTarget(c33467872.sptg)
	e2:SetOperation(c33467872.spop)
	c:RegisterEffect(e2)
end
-- 定义用于判断是否满足丢弃条件的过滤函数，即水属性、等级4以下且可丢弃的怪兽
function c33467872.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelBelow(4) and c:IsDiscardable()
end
-- 设置效果的发动费用为丢弃1张手卡，该手卡必须满足水属性、等级4以下且可丢弃的条件
function c33467872.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c33467872.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃手卡的操作，丢弃1张满足条件的水属性4星以下的怪兽
	Duel.DiscardHand(tp,c33467872.costfilter,1,1,REASON_DISCARD+REASON_COST)
end
-- 设置效果发动时的处理，使该怪兽的攻击力上升800点
function c33467872.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 使该怪兽的攻击力上升800点，持续到回合结束
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 设置效果发动的条件，即该怪兽是从主要怪兽区被送去墓地且为同调召唤
function c33467872.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 定义用于判断是否满足特殊召唤条件的过滤函数，即水属性、等级5以上且不是本卡的怪兽
function c33467872.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelAbove(5) and not c:IsCode(33467872)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果的目标选择函数，选择满足条件的墓地水属性5星以上怪兽
function c33467872.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c33467872.spfilter(chkc,e,tp) end
	-- 检查是否满足特殊召唤的条件，即场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足特殊召唤的条件，即墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c33467872.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为特殊召唤的目标
	local g=Duel.SelectTarget(tp,c33467872.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，确定特殊召唤的怪兽数量和目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 设置效果发动后的处理，将目标怪兽特殊召唤并设置不能特殊召唤非水属性怪兽的效果
function c33467872.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以守备表示形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 设置不能特殊召唤非水属性怪兽的效果，持续到回合结束
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c33467872.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家环境中
	Duel.RegisterEffect(e1,tp)
end
-- 定义限制非水属性怪兽特殊召唤的过滤函数
function c33467872.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
