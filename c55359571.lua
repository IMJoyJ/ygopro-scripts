--こちょぼの人形祀り
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，以场上1只机械族怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽的攻击力变成一半。这个效果特殊召唤的这张卡等级变成和作为对象的怪兽相同，从场上离开的场合除外。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册起动效果e1，该效果在手卡或墓地发动，以场上1只机械族怪兽为对象，将自身特殊召唤
function s.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，以场上1只机械族怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽的攻击力变成一半。
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
-- 过滤函数：检测场上表侧表示、等级在1级以上的机械族怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsLevelAbove(1)
end
-- 特殊召唤效果的Target函数：检测场上是否存在机械族怪兽，己方是否有空怪兽区域，以及这张卡能否特殊召唤，并在发动时选择场上的1只机械族怪兽作为对象，设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.cfilter(chkc) end
	-- 在检测阶段，检查场上是否存在可以作为对象的表侧表示且等级1以上的机械族怪兽
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 并检查己方场上是否有可用于特殊召唤的空怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择作为效果对象的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上的1只表侧表示且等级1以上的机械族怪兽作为连锁的对象
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的Operation函数：将这张卡特殊召唤，使作为对象的怪兽的攻击力减半，此卡等级变成和对象怪兽相同，且离场时除外，本回合限制自己只能从额外卡组特殊召唤超量怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为连锁对象的场上机械族怪兽
	local tc=Duel.GetFirstTarget()
	-- 如果这张卡与效果有关、不受墓地针对卡影响且成功在己方场上以表侧表示特殊召唤
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and not tc:IsImmuneToEffect(e) then
			-- 作为对象的怪兽的攻击力变成一半。
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
		-- 完成特殊召唤的后续处理
		Duel.SpecialSummonComplete()
		-- 从场上离开的场合除外。
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
	-- 将限制自己不能特殊召唤超量怪兽以外怪兽的效果注册给玩家
	Duel.RegisterEffect(e4,tp)
end
-- 特殊召唤限制的过滤函数：限制自己不能从额外卡组将超量怪兽以外的怪兽特殊召唤
function s.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
