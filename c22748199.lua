--神の氷結
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：场上有水属性怪兽2只以上存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽不能攻击，效果无效化。
-- ②：这张卡在墓地存在的状态，自己场上有5星以上的水属性怪兽召唤·特殊召唤的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
function c22748199.initial_effect(c)
	-- ①：场上有水属性怪兽2只以上存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽不能攻击，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22748199,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_ATTACK)
	e1:SetCondition(c22748199.condition)
	e1:SetTarget(c22748199.target)
	e1:SetOperation(c22748199.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上有5星以上的水属性怪兽召唤·特殊召唤的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22748199,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,22748199)
	e2:SetCondition(c22748199.setcon)
	e2:SetTarget(c22748199.settg)
	e2:SetOperation(c22748199.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选场上表侧表示的水属性怪兽
function c22748199.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 判断场上是否存在至少2只水属性怪兽
function c22748199.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在至少2只水属性怪兽
	return Duel.IsExistingMatchingCard(c22748199.filter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil)
end
-- 设置效果目标，选择对方场上一张可被无效的怪兽
function c22748199.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 设置效果目标，选择对方场上一张可被无效的怪兽
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateMonsterFilter(chkc) end
	-- 检查是否有满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上一张可被无效的怪兽作为效果对象
	Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 处理效果的发动，使目标怪兽不能攻击并无效其效果
function c22748199.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果目标
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使目标怪兽不能攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if not c:IsDisabled() then
			-- 使目标怪兽相关的连锁无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 使目标怪兽效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			-- 使目标怪兽效果无效
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetValue(RESET_TURN_SET)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
end
-- 过滤函数，用于筛选自己场上表侧表示的5星以上水属性怪兽
function c22748199.setfilter(c,tp)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsControler(tp)
end
-- 判断是否有满足条件的怪兽被召唤或特殊召唤
function c22748199.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c22748199.setfilter,1,nil,tp)
end
-- 设置效果处理信息，确定将要盖放的卡
function c22748199.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置效果处理信息，确定将要盖放的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 处理效果的发动，将卡盖放到场上
function c22748199.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查卡是否能被盖放
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 then
		-- 设置卡离开场上时的处理，将其移除
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
