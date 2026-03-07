--機皇帝スキエル∞
-- 效果：
-- 这张卡不能通常召唤，用自身的效果才能特殊召唤。
-- ①：自己场上的表侧表示怪兽被效果破坏送去墓地时才能发动。手卡的这张卡特殊召唤。
-- ②：1回合1次，以对方场上1只同调怪兽为对象才能发动。那只对方同调怪兽给这张卡装备。
-- ③：这个攻击力上升自身的效果装备的怪兽的攻击力数值，其他的自己怪兽不能攻击宣言。
-- ④：把给自身装备的1只自己怪兽送去墓地才能发动。这个回合这张卡可以直接攻击。
function c31930787.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文：这张卡不能通常召唤，用自身的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(0)
	c:RegisterEffect(e1)
	-- 效果原文：①：自己场上的表侧表示怪兽被效果破坏送去墓地时才能发动。手卡的这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31930787,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c31930787.spcon)
	e2:SetTarget(c31930787.sptg)
	e2:SetOperation(c31930787.spop)
	c:RegisterEffect(e2)
	-- 效果原文：③：这个攻击力上升自身的效果装备的怪兽的攻击力数值，其他的自己怪兽不能攻击宣言。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c31930787.antarget)
	c:RegisterEffect(e3)
	-- 效果原文：②：1回合1次，以对方场上1只同调怪兽为对象才能发动。那只对方同调怪兽给这张卡装备。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(31930787,1))  --"装备同调怪兽"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c31930787.eqtg)
	e4:SetOperation(c31930787.eqop)
	c:RegisterEffect(e4)
	-- 效果原文：④：把给自身装备的1只自己怪兽送去墓地才能发动。这个回合这张卡可以直接攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(31930787,2))  --"直接攻击"
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c31930787.dircon)
	e5:SetCost(c31930787.dircost)
	e5:SetOperation(c31930787.dirop)
	c:RegisterEffect(e5)
end
-- 规则层面：判断被破坏送入墓地的卡是否为己方场上表侧表示的怪兽
function c31930787.filter(c,tp)
	return c:IsType(TYPE_MONSTER) and bit.band(c:GetReason(),0x41)==0x41 and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 规则层面：判断是否有己方场上表侧表示的怪兽被效果破坏送入墓地
function c31930787.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31930787.filter,1,nil,tp)
end
-- 规则层面：判断是否满足特殊召唤条件
function c31930787.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：判断是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,true) end
	-- 规则层面：设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 规则层面：执行特殊召唤操作
function c31930787.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 规则层面：完成特殊召唤程序
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- 规则层面：设置攻击宣言限制的目标
function c31930787.antarget(e,c)
	return c~=e:GetHandler()
end
-- 规则层面：筛选可装备的对方同调怪兽
function c31930787.eqfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToChangeControler()
end
-- 规则层面：判断是否满足装备条件
function c31930787.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c31930787.eqfilter(chkc) end
	-- 规则层面：判断是否有足够的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 规则层面：判断是否存在符合条件的对方怪兽
		and Duel.IsExistingTarget(c31930787.eqfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 规则层面：提示选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 规则层面：选择目标怪兽
	local g=Duel.SelectTarget(tp,c31930787.eqfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 规则层面：设置装备限制条件
function c31930787.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 规则层面：执行装备操作
function c31930787.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面：获取装备目标
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		local atk=tc:GetTextAttack()
		if atk<0 then atk=0 end
		-- 规则层面：尝试装备目标怪兽
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 效果原文：②：1回合1次，以对方场上1只同调怪兽为对象才能发动。那只对方同调怪兽给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c31930787.eqlimit)
		tc:RegisterEffect(e1)
		if atk>0 then
			-- 效果原文：②：1回合1次，以对方场上1只同调怪兽为对象才能发动。那只对方同调怪兽给这张卡装备。
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
-- 规则层面：判断是否满足直接攻击的条件
function c31930787.dircon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断当前阶段是否为主阶段且未拥有直接攻击效果
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not e:GetHandler():IsHasEffect(EFFECT_DIRECT_ATTACK)
end
-- 规则层面：筛选可作为代价送入墓地的己方怪兽
function c31930787.dcfilter(c)
	return bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0 and c:IsAbleToGraveAsCost()
end
-- 规则层面：判断是否满足直接攻击的代价条件
function c31930787.dircost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEquipGroup():IsExists(c31930787.dcfilter,1,nil) end
	-- 规则层面：提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local g=e:GetHandler():GetEquipGroup():FilterSelect(tp,c31930787.dcfilter,1,1,nil)
	-- 规则层面：将选中的卡送去墓地作为代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 规则层面：执行直接攻击效果
function c31930787.dirop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 效果原文：④：把给自身装备的1只自己怪兽送去墓地才能发动。这个回合这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1,true)
end
