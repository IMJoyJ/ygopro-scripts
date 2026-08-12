--オルフェゴール・スケルツォン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把墓地的这张卡除外，以「自奏圣乐·谐谑曲骷髅」以外的自己墓地1只「自奏圣乐」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能特殊召唤。
function c21441617.initial_effect(c)
	-- 创建一个起动效果，效果描述为卡名第0个效果提示，分类为特殊召唤，具有取对象属性，类型为起动效果，适用区域为墓地，限制1回合1次，费用为除外自身，条件为不满足快速效果条件，目标函数为sptg，效果处理函数为spop
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21441617,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,21441617)
	-- 设置效果的发动费用为将自身除外
	e1:SetCost(aux.bfgcost)
	e1:SetCondition(c21441617.spcon1)
	e1:SetTarget(c21441617.sptg)
	e1:SetOperation(c21441617.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCondition(c21441617.spcon2)
	c:RegisterEffect(e2)
end
-- 效果发动条件函数，用于判断是否满足起动效果的发动条件
function c21441617.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前卡片是否不处于可以发动诱发即时效果的状态
	return not aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- 效果发动条件函数，用于判断是否满足诱发即时效果的发动条件
function c21441617.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前卡片是否处于可以发动诱发即时效果的状态
	return aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- 特殊召唤目标过滤函数，用于筛选墓地中的自奏圣乐怪兽（非本卡）且可特殊召唤的怪兽
function c21441617.spfilter(c,e,tp)
	return c:IsSetCard(0x11b) and not c:IsCode(21441617) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标选择函数，用于选择满足条件的墓地怪兽作为特殊召唤目标
function c21441617.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21441617.spfilter(chkc,e,tp) end
	-- 判断是否满足特殊召唤的条件，即场上存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足特殊召唤的条件，即墓地存在符合条件的怪兽
		and Duel.IsExistingTarget(c21441617.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为特殊召唤目标
	local g=Duel.SelectTarget(tp,c21441617.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，确定特殊召唤的怪兽数量和目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，用于执行特殊召唤操作并设置后续限制
function c21441617.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 创建一个影响玩家的永续效果，禁止在回合结束前特殊召唤非暗属性怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c21441617.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将创建的限制效果注册到玩家场上
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的目标过滤函数，用于判断怪兽是否为暗属性
function c21441617.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
