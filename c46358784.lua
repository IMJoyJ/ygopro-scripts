--A宝玉獣 エメラルド・タートル
-- 效果：
-- ①：场地区域没有「高等暗黑结界」存在的场合这只怪兽送去墓地。
-- ②：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的表示形式变更。这个效果在对方回合也能发动。
-- ③：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c46358784.initial_effect(c)
	-- 将卡号12644061（高等暗黑结界）记录为此卡效果文本中记载的卡名，便于其他效果进行关联判定。
	aux.AddCodeList(c,12644061)
	-- 启用GLOBALFLAG_SELF_TOGRAVE全局标记，使系统支持EFFECT_SELF_TOGRAVE这类不入连锁的自我送墓效果的检测与处理。
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
-- tgcon条件函数：判定①效果是否满足触发条件，即场地区域是否存在「高等暗黑结界」。
function c46358784.tgcon(e)
	-- 返回“当前场地没有「高等暗黑结界」”为真，满足①效果中“没有「高等暗黑结界」存在的场合”的条件。
	return not Duel.IsEnvironment(12644061)
end
-- repcon条件函数：判定③效果是否满足发动条件，即这张卡必须是表侧表示、位于怪兽区域、并且是被破坏。
function c46358784.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
-- repop处理函数：当③效果条件满足时，通过给这张卡赋予EFFECT_CHANGE_TYPE效果，使其变为永续魔法卡，实现“当作永续魔法卡使用”的处理。
function c46358784.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 当作永续魔法卡使用
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end
-- posfilter过滤函数：用于选择②效果的对象，要求怪兽为表侧表示且可以变更表示形式。
function c46358784.posfilter(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- postg目标函数：处理②效果的发动条件与对象选择，包括判断是否有可选的表侧表示怪兽，并让玩家选择1只对象。
function c46358784.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c46358784.posfilter(chkc) end
	-- 效果发动时检查场上是否存在至少1只满足条件（表侧表示且可变更表示形式）的怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c46358784.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择要改变表示形式的怪兽”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家从双方怪兽区域选择1只表侧表示且可变更表示形式的怪兽，将其设为效果对象。
	Duel.SelectTarget(tp,c46358784.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- posop处理函数：②效果处理时，获取选择的对象，若对象仍与效果相关，则变更其表示形式。
function c46358784.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此前选择的目标怪兽，用于后续变更表示形式。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽的表示形式进行变更：表侧守备、里侧守备、表侧攻击、表侧攻击分别对应从当前形式切换为相反/指定形式。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
