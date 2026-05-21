--クリスタル・シャーク
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，以场上1只水属性怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽的攻击力变成一半。这个效果特殊召唤的这张卡从场上离开的场合除外。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
-- ②：把这张卡在「No.」怪兽的超量召唤使用的场合，可以把这张卡的等级当作3星或4星使用。
function c98881700.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，以场上1只水属性怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽的攻击力变成一半。这个效果特殊召唤的这张卡从场上离开的场合除外。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,98881700)
	e1:SetTarget(c98881700.sptg)
	e1:SetOperation(c98881700.spop)
	c:RegisterEffect(e1)
	-- ②：把这张卡在「No.」怪兽的超量召唤使用的场合，可以把这张卡的等级当作3星或4星使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_XYZ_LEVEL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c98881700.xyzlv)
	e2:SetLabel(3)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetLabel(4)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的水属性怪兽
function c98881700.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsFaceup()
end
-- 效果①的发动准备与合法性检测
function c98881700.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c98881700.spfilter(chkc) end
	local c=e:GetHandler()
	-- 检测场上是否存在可以作为对象的水属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c98881700.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检测自身是否能特殊召唤以及怪兽区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只表侧表示的水属性怪兽作为对象
	Duel.SelectTarget(tp,c98881700.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的效果处理（特殊召唤自身、对象怪兽攻击力减半、添加离场除外及额外卡组特召限制的约束）
function c98881700.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若自身仍符合卡片关系，则将自身特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
			-- 作为对象的怪兽的攻击力变成一半
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(math.ceil(tc:GetAttack()/2))
			tc:RegisterEffect(e1)
		end
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2,true)
	end
	-- 这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。②：把这张卡在「No.」怪兽的超量召唤使用的场合，可以把这张卡的等级当作3星或4星使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetTarget(c98881700.splimit)
	-- 给玩家注册直到回合结束不能从额外卡组特殊召唤超量怪兽以外怪兽的限制效果
	Duel.RegisterEffect(e3,tp)
end
-- 限制条件：不能从额外卡组特殊召唤超量怪兽以外的怪兽
function c98881700.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
-- 若用于「No.」怪兽的超量召唤，则将等级当作3星或4星使用
function c98881700.xyzlv(e,c,rc)
	if rc:IsSetCard(0x48) then
		return c:GetLevel()+0x10000*e:GetLabel()
	else
		return c:GetLevel()
	end
end
