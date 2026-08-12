--機皇帝グランエル∞
-- 效果：
-- 这张卡不能通常召唤，用自身的效果才能特殊召唤。
-- ①：自己场上的表侧表示怪兽被效果破坏送去墓地时才能发动。手卡的这张卡特殊召唤。
-- ②：1回合1次，以对方场上1只同调怪兽为对象才能发动。那只对方同调怪兽给这张卡装备。
-- ③：这个攻击力·守备力上升自己基本分一半数值，攻击力上升自身的效果装备的怪兽的攻击力数值。
-- ④：以自身的效果装备的1只怪兽为对象才能发动。那只守备表示特殊召唤。
function c4545683.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用自身的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(0)
	c:RegisterEffect(e1)
	-- 自己场上的表侧表示怪兽被效果破坏送去墓地时才能发动。手卡的这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4545683,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c4545683.spcon)
	e2:SetTarget(c4545683.sptg)
	e2:SetOperation(c4545683.spop)
	c:RegisterEffect(e2)
	-- 这个攻击力·守备力上升自己基本分一半数值，攻击力上升自身的效果装备的怪兽的攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c4545683.val)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- 1回合1次，以对方场上1只同调怪兽为对象才能发动。那只对方同调怪兽给这张卡装备。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(4545683,1))  --"装备同调怪兽"
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(c4545683.eqtg)
	e5:SetOperation(c4545683.eqop)
	c:RegisterEffect(e5)
	-- 以自身的效果装备的1只怪兽为对象才能发动。那只守备表示特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(4545683,2))  --"特殊召唤装备的怪兽"
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTarget(c4545683.sptg2)
	e6:SetOperation(c4545683.spop2)
	c:RegisterEffect(e6)
end
-- 判断被破坏送入墓地的怪兽是否为己方场上表侧表示的怪兽
function c4545683.filter(c,tp)
	return c:IsType(TYPE_MONSTER) and bit.band(c:GetReason(),0x41)==0x41 and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 判断是否有己方场上表侧表示被破坏送入墓地的怪兽
function c4545683.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c4545683.filter,1,nil,tp)
end
-- 判断是否可以特殊召唤此卡
function c4545683.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以特殊召唤此卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,true) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c4545683.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤操作
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- 计算攻击力上升值
function c4545683.val(e,c)
	-- 计算攻击力上升值
	return math.ceil(Duel.GetLP(c:GetControler())/2)
end
-- 判断目标是否为可装备的同调怪兽
function c4545683.eqfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToChangeControler()
end
-- 设置装备效果的目标选择
function c4545683.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c4545683.eqfilter(chkc) end
	-- 判断是否可以装备
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断是否可以装备
		and Duel.IsExistingTarget(c4545683.eqfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示选择装备目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标
	local g=Duel.SelectTarget(tp,c4545683.eqfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 设置装备限制效果
function c4545683.eqlimit(e,c)
	return e:GetOwner()==c and not c:IsDisabled()
end
-- 执行装备操作
function c4545683.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取装备目标
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		local atk=tc:GetTextAttack()
		if atk<0 then atk=0 end
		-- 执行装备操作
		if not Duel.Equip(tp,tc,c,false) then return end
		tc:RegisterFlagEffect(4545683,RESET_EVENT+RESETS_STANDARD,0,0)
		-- 设置装备限制效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c4545683.eqlimit)
		tc:RegisterEffect(e1)
		if atk>0 then
			-- 装备怪兽攻击力上升效果
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(atk)
			tc:RegisterEffect(e2)
		end
	end
end
-- 判断是否为可特殊召唤的装备怪兽
function c4545683.spfilter(c,e,tp,ec)
	return c:GetFlagEffect(4545683)~=0 and c:GetEquipTarget()==ec and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置特殊召唤装备怪兽的目标选择
function c4545683.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c4545683.spfilter(chkc,e,tp,e:GetHandler()) end
	-- 判断是否可以特殊召唤装备怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否可以特殊召唤装备怪兽
		and Duel.IsExistingTarget(c4545683.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp,e:GetHandler()) end
	-- 提示选择特殊召唤目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择特殊召唤目标
	local g=Duel.SelectTarget(tp,c4545683.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp,e:GetHandler())
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤装备怪兽操作
function c4545683.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取特殊召唤目标
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 执行特殊召唤装备怪兽操作
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
