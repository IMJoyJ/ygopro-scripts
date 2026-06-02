--こちょぼの人形祀り
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，以场上1只机械族怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽的攻击力变成一半。这个效果特殊召唤的这张卡等级变成和作为对象的怪兽相同，从场上离开的场合除外。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，定义①效果为手卡·墓地发动的起动效果，取对象，同名卡1回合只能使用1次。
function s.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，以场上1只机械族怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽的攻击力变成一半。这个效果特殊召唤的这张卡等级变成和作为对象的怪兽相同，从场上离开的场合除外。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示、等级1以上且是机械族的怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsLevelAbove(1)
end
-- 效果发动的目标选择与合法性检测，包括判断是否存在可选的机械族怪兽、自身是否能特殊召唤以及怪兽区域是否有空位。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.cfilter(chkc) end
	-- 检查场上是否存在可以作为对象的、表侧表示且等级1以上的机械族怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查当前玩家的怪兽区域是否有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择场上1只表侧表示且等级1以上的机械族怪兽作为对象。
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表明此效果包含将自身特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理函数，执行特殊召唤、减半对象怪兽攻击力、改变自身等级、设置离场除外以及限制后续额外卡组特殊召唤等处理。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认自身卡片仍与效果相关、不受王家之谷影响，并尝试将其以表侧表示特殊召唤。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and not tc:IsImmuneToEffect(e) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(math.ceil(tc:GetAttack()/2))
			tc:RegisterEffect(e1)
			-- 这个效果特殊召唤的这张卡等级变成和作为对象的怪兽相同
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CHANGE_LEVEL)
			e2:SetValue(tc:GetLevel())
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e2)
		end
		-- 完成特殊召唤的流程。
		Duel.SpecialSummonComplete()
		-- 从场上离开的场合除外
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e3:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e3,true)
	end
	-- 这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	e4:SetReset(RESET_PHASE+PHASE_END)
	e4:SetTarget(s.splimit)
	-- 将不能从额外卡组特殊召唤超量以外怪兽的限制效果注册给玩家。
	Duel.RegisterEffect(e4,tp)
end
-- 限制条件的具体判定：非超量怪兽且从额外卡组特殊召唤。
function s.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
