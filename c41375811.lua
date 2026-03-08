--十二獣ライカ
-- 效果：
-- 4星怪兽×2只以上
-- 「十二兽 狗环」1回合1次也能在同名卡以外的自己场上的「十二兽」怪兽上面重叠来超量召唤。
-- ①：这张卡的攻击力·守备力上升这张卡作为超量素材中的「十二兽」怪兽的各自数值。
-- ②：1回合1次，把这张卡1个超量素材取除，以自己墓地1只「十二兽」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合效果无效化，不能作为超量召唤的素材。
function c41375811.initial_effect(c)
	aux.AddXyzProcedure(c,nil,4,2,c41375811.ovfilter,aux.Stringid(41375811,0),99,c41375811.xyzop)  --"是否在「十二兽」怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡作为超量素材中的「十二兽」怪兽的各自数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c41375811.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(c41375811.defval)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把这张卡1个超量素材取除，以自己墓地1只「十二兽」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合效果无效化，不能作为超量召唤的素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(41375811,1))  --"自己墓地「十二兽」怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCost(c41375811.spcost)
	e3:SetTarget(c41375811.sptg)
	e3:SetOperation(c41375811.spop)
	c:RegisterEffect(e3)
end
-- 用于判断场上是否满足「十二兽」怪兽叠放条件的过滤函数，排除自身。
function c41375811.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf1) and not c:IsCode(41375811)
end
-- XYZ召唤时的处理函数，用于记录该回合是否已发动过效果。
function c41375811.xyzop(e,tp,chk)
	-- 检查该玩家是否已在本回合发动过此效果。
	if chk==0 then return Duel.GetFlagEffect(tp,41375811)==0 end
	-- 为该玩家注册一个标识效果，防止本回合再次发动此效果。
	Duel.RegisterFlagEffect(tp,41375811,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 用于筛选攻击力大于等于0的「十二兽」怪兽的过滤函数。
function c41375811.atkfilter(c)
	return c:IsSetCard(0xf1) and c:GetAttack()>=0
end
-- 计算该卡作为超量素材时，所有「十二兽」怪兽的攻击力总和。
function c41375811.atkval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(c41375811.atkfilter,nil)
	return g:GetSum(Card.GetAttack)
end
-- 用于筛选守备力大于等于0的「十二兽」怪兽的过滤函数。
function c41375811.deffilter(c)
	return c:IsSetCard(0xf1) and c:GetDefense()>=0
end
-- 计算该卡作为超量素材时，所有「十二兽」怪兽的守备力总和。
function c41375811.defval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(c41375811.deffilter,nil)
	return g:GetSum(Card.GetDefense)
end
-- 发动效果时的费用处理，移除1个超量素材。
function c41375811.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 用于筛选可特殊召唤的「十二兽」怪兽的过滤函数。
function c41375811.spfilter(c,e,tp)
	return c:IsSetCard(0xf1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的目标选择逻辑，选择墓地中的「十二兽」怪兽。
function c41375811.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c41375811.spfilter(chkc,e,tp) end
	-- 检查是否有满足条件的墓地怪兽可特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c41375811.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向对方提示本效果已被发动。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标墓地中的「十二兽」怪兽。
	local g=Duel.SelectTarget(tp,c41375811.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果操作信息，确定特殊召唤的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作，并对召唤出的怪兽施加效果限制。
function c41375811.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效，并尝试特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 使特殊召唤出的怪兽在本回合内效果无效。
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
		e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		e3:SetValue(1)
		tc:RegisterEffect(e3)
	end
	-- 完成特殊召唤流程，结束处理。
	Duel.SpecialSummonComplete()
end
