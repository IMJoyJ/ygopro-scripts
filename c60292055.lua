--エルフェーズ
-- 效果：
-- 3星以上的电子界族怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升这张卡所连接区的怪兽数量×300。
-- ②：连接召唤的表侧表示的这张卡从场上离开的场合，以自己墓地1只4星以下的电子界族怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合效果无效化，不能作为连接素材。
function c60292055.initial_effect(c)
	-- 设置连接召唤的手续，需要2只满足过滤条件的怪兽作为素材。
	aux.AddLinkProcedure(c,c60292055.mfilter,2)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡所连接区的怪兽数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c60292055.atkval)
	c:RegisterEffect(e1)
	-- ②：连接召唤的表侧表示的这张卡从场上离开的场合，以自己墓地1只4星以下的电子界族怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合效果无效化，不能作为连接素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60292055,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,60292055)
	e2:SetCondition(c60292055.spcon)
	e2:SetTarget(c60292055.sptg)
	e2:SetOperation(c60292055.spop)
	c:RegisterEffect(e2)
end
-- 过滤连接素材：3星以上的电子界族怪兽。
function c60292055.mfilter(c)
	return c:IsLevelAbove(3) and c:IsLinkRace(RACE_CYBERSE)
end
-- 计算攻击力上升值：所连接区的怪兽数量×300。
function c60292055.atkval(e,c)
	return c:GetLinkedGroupCount()*300
end
-- 检查效果②的发动条件：连接召唤的表侧表示的自身从场上离开。
function c60292055.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK) and c:IsPreviousPosition(POS_FACEUP)
end
-- 过滤特殊召唤的目标：墓地4星以下的电子界族怪兽，且能特殊召唤。
function c60292055.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备（包含对象判定和可行性检查）。
function c60292055.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c60292055.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的、可作为效果对象的目标怪兽。
		and Duel.IsExistingTarget(c60292055.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c60292055.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息（包含特殊召唤分类、目标卡片组和数量）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理：将对象怪兽特殊召唤，并使其效果无效化、不能作为连接素材。
function c60292055.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与效果相关，则尝试将其以表侧表示特殊召唤（分步处理）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽在这个回合效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e3:SetValue(1)
		tc:RegisterEffect(e3)
	end
	-- 完成特殊召唤的最终处理。
	Duel.SpecialSummonComplete()
end
