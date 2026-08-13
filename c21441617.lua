--オルフェゴール・スケルツォン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把墓地的这张卡除外，以「自奏圣乐·谐谑曲骷髅」以外的自己墓地1只「自奏圣乐」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能特殊召唤。
function c21441617.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：把墓地的这张卡除外，以「自奏圣乐·谐谑曲骷髅」以外的自己墓地1只「自奏圣乐」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21441617,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,21441617)
	-- 设置效果的发动COST：把墓地中的这张卡除外。
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
-- 定义e1（一速起动效果）的发动条件：当此卡未被特定效果（码90351981）赋予二速化能力时，该效果才作为起动效果在主要阶段发动。
function c21441617.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 返回“当前不满足二速化条件”的判断结果，用于使e1仅在非二速状态下可发动。
	return not aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- 定义e2（诱发即时效果）的发动条件：当此卡满足特定效果（码90351981）赋予的二速化条件时，e2可作为诱发即时效果发动。
function c21441617.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 返回“当前满足二速化条件”的判断结果，用于允许e2在合适时点（如对方结束阶段）以诱发即时效果发动。
	return aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- 定义对象怪兽的筛选条件：是「自奏圣乐」字段（0x11b）怪兽、不是自身（卡号21441617）、且可以被当前效果特殊召唤。
function c21441617.spfilter(c,e,tp)
	return c:IsSetCard(0x11b) and not c:IsCode(21441617) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果的发动目标流程：确认对象合法后，让玩家从自己墓地的「自奏圣乐」怪兽中选择1只作为效果对象（取对象）。
function c21441617.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21441617.spfilter(chkc,e,tp) end
	-- 发动时合法性检查：确认自己主要怪兽区存在可用的空格，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动时合法性检查：确认自己墓地存在至少1只满足spfilter条件且能被效果取为对象的「自奏圣乐」怪兽。
		and Duel.IsExistingTarget(c21441617.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家展示选择提示，要求选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的「自奏圣乐」怪兽，并将其登记为当前连锁的效果处理对象。
	local g=Duel.SelectTarget(tp,c21441617.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息：声明本次处理包含特殊召唤，对象为选择的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将对象怪兽特殊召唤，然后为发动者附加“直到回合结束时自己不能特殊召唤非暗属性怪兽”的自肃效果。
function c21441617.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示（攻击表示）特殊召唤到发动者场上，并正常检查召唤条件和苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c21441617.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册为场上持续效果的实例，作用于发动者玩家，并在结束阶段重置。
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃效果的适用判定：若将被特殊召唤的怪兽不是暗属性，则禁止该特殊召唤。
function c21441617.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
