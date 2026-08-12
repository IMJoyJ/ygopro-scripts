--A宝玉獣 エメラルド・タートル
-- 效果：
-- ①：场地区域没有「高等暗黑结界」存在的场合这只怪兽送去墓地。
-- ②：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的表示形式变更。这个效果在对方回合也能发动。
-- ③：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c46358784.initial_effect(c)
	-- 记录此卡具有「高等暗黑结界」的卡片密码，用于后续判断场地卡是否存在
	aux.AddCodeList(c,12644061)
	-- 启用全局标记GLOBALFLAG_SELF_TOGRAVE，用于处理送墓时的特殊判定
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	-- ①：场地区域没有「高等暗黑结界」存在的场合这只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SELF_TOGRAVE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCondition(c46358784.tgcon)
	c:RegisterEffect(e1)
	-- ③：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(c46358784.repcon)
	e2:SetOperation(c46358784.repop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的表示形式变更。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1)
	e3:SetTarget(c46358784.postg)
	e3:SetOperation(c46358784.posop)
	c:RegisterEffect(e3)
end
-- 判断当前是否没有「高等暗黑结界」场地卡存在
function c46358784.tgcon(e)
	-- 若无「高等暗黑结界」场地卡存在则触发效果
	return not Duel.IsEnvironment(12644061)
end
-- 判断此卡是否以表侧表示在怪兽区域被破坏
function c46358784.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
-- 将此卡变为永续魔法卡并放置于魔法与陷阱区域
function c46358784.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将此卡的卡片种类更改为魔法卡+永续效果
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end
-- 筛选场上可以改变表示形式的表侧表示怪兽
function c46358784.posfilter(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- 选择目标怪兽并提示玩家进行表示形式变更操作
function c46358784.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c46358784.posfilter(chkc) end
	-- 检查是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c46358784.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，提示其选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择场上一只符合条件的怪兽作为目标
	Duel.SelectTarget(tp,c46358784.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 执行表示形式变更效果
function c46358784.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽变为表侧守备、里侧守备、表侧攻击、表侧攻击的形式
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
