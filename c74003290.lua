--迷い風
-- 效果：
-- ①：以场上1只特殊召唤的表侧表示怪兽为对象才能发动。那只怪兽的效果无效化，原本攻击力变成一半。
-- ②：这张卡在墓地存在的状态，从对方的额外卡组有怪兽特殊召唤的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
function c74003290.initial_effect(c)
	-- ①：以场上1只特殊召唤的表侧表示怪兽为对象才能发动。那只怪兽的效果无效化，原本攻击力变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74003290,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	-- 限制该效果在伤害步骤中只能在伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c74003290.target)
	e1:SetOperation(c74003290.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，从对方的额外卡组有怪兽特殊召唤的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74003290,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c74003290.setcon)
	e2:SetTarget(c74003290.settg)
	e2:SetOperation(c74003290.setop)
	c:RegisterEffect(e2)
end
-- 过滤场上特殊召唤的表侧表示怪兽
function c74003290.filter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果①的对象选择与发动准备
function c74003290.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c74003290.filter(chkc) end
	-- 检查场上是否存在至少1只满足条件的特殊召唤的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c74003290.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择表侧表示卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只特殊召唤的表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c74003290.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果①的处理：使目标怪兽效果无效，且原本攻击力减半
function c74003290.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使与该怪兽相关的连锁中已发动的效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		-- 手动刷新该怪兽的无效状态
		Duel.AdjustInstantly(tc)
		local batk=tc:GetBaseAttack()
		local e3=e1:Clone()
		e3:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e3:SetValue(math.ceil(batk/2))
		tc:RegisterEffect(e3)
	end
end
-- 过滤从对方额外卡组特殊召唤的怪兽
function c74003290.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsPreviousControler(1-tp)
end
-- 检查是否有怪兽从对方额外卡组特殊召唤，作为效果②的发动条件
function c74003290.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c74003290.cfilter,1,nil,tp)
end
-- 效果②的发动准备，检查自身是否可以盖放并设置操作信息
function c74003290.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息为将墓地的这张卡移出墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果②的处理：将这张卡在场上盖放，并添加离场除外的限制
function c74003290.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于墓地，则在自己场上盖放
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 then
		-- 这个效果盖放的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
