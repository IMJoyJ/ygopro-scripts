--幻影騎士団シャドーベイル
-- 效果：
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力上升300。
-- ②：这张卡在墓地存在的场合，对方的直接攻击宣言时才能发动。这张卡变成通常怪兽（战士族·暗·4星·攻0/守300）在怪兽区域守备表示特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c77462146.initial_effect(c)
	-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置发动条件为非伤害计算后（限制在伤害步骤的伤害计算前发动）
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c77462146.target)
	e1:SetOperation(c77462146.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，对方的直接攻击宣言时才能发动。这张卡变成通常怪兽（战士族·暗·4星·攻0/守300）在怪兽区域守备表示特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77462146,0))  --"当作通常怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c77462146.spcon)
	e2:SetTarget(c77462146.sptg)
	e2:SetOperation(c77462146.spop)
	c:RegisterEffect(e2)
end
-- ①号效果的靶向与对象选择判定函数
function c77462146.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 在发动时，检查自己场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果的对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①号效果的发动处理（数值上升）函数
function c77462146.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果处理中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力·守备力上升300。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(300)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- ②号效果的发动条件判定函数
function c77462146.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定攻击怪兽的控制者为对方，且没有攻击对象（即直接攻击）
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- ②号效果的发动准备与合法性检测函数
function c77462146.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查此卡是否未在连锁中，且自己场上有可用的怪兽区域
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能将此卡作为特定属性、种族、等级、攻守的通常怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,77462146,0x10db,TYPES_NORMAL_TRAP_MONSTER,0,300,4,RACE_WARRIOR,ATTRIBUTE_DARK) end
	-- 设置连锁操作信息，表明将特殊召唤1张卡（自身）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②号效果的发动处理（特殊召唤及后续限制）函数
function c77462146.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上已无可用怪兽区域，则不进行特殊召唤处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 确认此卡仍与效果相关，且玩家仍能将其作为特定怪兽特殊召唤
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,77462146,0x10db,TYPES_NORMAL_TRAP_MONSTER,0,300,4,RACE_WARRIOR,ATTRIBUTE_DARK) then
		c:AddMonsterAttribute(TYPE_NORMAL)
		-- 将此卡在自己场上以表侧守备表示进行特殊召唤的单步处理
		Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP_DEFENSE)
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2,true)
		-- 完成特殊召唤的最终处理，使特殊召唤正式生效
		Duel.SpecialSummonComplete()
	end
end
