--氷水艇エーギロカシス
-- 效果：
-- 这个卡名的①③的效果1回合只能有1次使用其中任意1个。
-- ①：自己·对方回合，这张卡在手卡·墓地存在的场合，以自己场上1只「冰水」怪兽为对象才能发动。这张卡当作装备卡使用给那只自己怪兽装备。
-- ②：有这张卡装备的怪兽的攻击力·守备力上升除外状态的怪兽数量×400。
-- ③：这张卡装备中的场合才能发动。这张卡特殊召唤。
function c1295442.initial_effect(c)
	-- ①：自己·对方回合，这张卡在手卡·墓地存在的场合，以自己场上1只「冰水」怪兽为对象才能发动。这张卡当作装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,1295442)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c1295442.eqtg)
	e1:SetOperation(c1295442.eqop)
	c:RegisterEffect(e1)
	-- ②：有这张卡装备的怪兽的攻击力·守备力上升除外状态的怪兽数量×400。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c1295442.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ③：这张卡装备中的场合才能发动。这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,1295442)
	e4:SetCondition(c1295442.spcon)
	e4:SetTarget(c1295442.sptg)
	e4:SetOperation(c1295442.spop)
	c:RegisterEffect(e4)
end
-- 过滤场上存在的「冰水」怪兽
function c1295442.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x16c)
end
-- 效果①的发动时的取对象处理
function c1295442.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c1295442.filter(chkc) end
	-- 判断装备区域是否为空
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and e:GetHandler():CheckUniqueOnField(tp)
		-- 判断场上是否存在「冰水」怪兽
		and Duel.IsExistingTarget(c1295442.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择装备对象
	Duel.SelectTarget(tp,c1295442.filter,tp,LOCATION_MZONE,0,1,1,nil)
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		-- 设置效果处理信息，将此卡送入墓地
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end
-- 效果①的发动处理
function c1295442.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前连锁的装备对象
	local tc=Duel.GetFirstTarget()
	-- 判断装备条件是否满足
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 将此卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 执行装备操作
	if not Duel.Equip(tp,c,tc) then return end
	-- 设置装备限制效果，防止被其他装备卡装备
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c1295442.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 装备限制效果的判定函数
function c1295442.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 过滤除外状态的怪兽
function c1295442.atkfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
-- 计算除外怪兽数量并乘以400作为攻击力加成
function c1295442.atkval(e,c)
	-- 计算除外怪兽数量并乘以400作为攻击力加成
	return Duel.GetMatchingGroupCount(c1295442.atkfilter,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)*400
end
-- 判断此卡是否装备中
function c1295442.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end
-- 效果③的发动时的处理
function c1295442.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断召唤区域是否为空
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果③的发动处理
function c1295442.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
