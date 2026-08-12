--ジュラゲド
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方的战斗步骤才能发动。这张卡从手卡特殊召唤，自己回复1000基本分。
-- ②：把这张卡解放，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到下个回合的结束时上升1000。这个效果在对方回合也能发动。
function c59546797.initial_effect(c)
	-- ①：自己·对方的战斗步骤才能发动。这张卡从手卡特殊召唤，自己回复1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59546797,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_STEP_END)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,59546797)
	e1:SetCondition(c59546797.spcon)
	e1:SetTarget(c59546797.sptg)
	e1:SetOperation(c59546797.spop)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到下个回合的结束时上升1000。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59546797,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置发动条件为不在伤害计算后（限制伤害步骤的发动时机）
	e2:SetCondition(aux.dscon)
	e2:SetCost(c59546797.atkcost)
	e2:SetTarget(c59546797.atktg)
	e2:SetOperation(c59546797.atkop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定函数
function c59546797.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否为战斗步骤
	return Duel.GetCurrentPhase()==PHASE_BATTLE_STEP
end
-- 效果①的发动准备与合法性检测函数
function c59546797.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定是否满足发动条件：此卡未在连锁中，且自己场上有空余的怪兽区域
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向系统宣告此效果包含特殊召唤自身的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 向系统宣告此效果包含回复生命值的操作
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 效果①的效果处理函数
function c59546797.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将此卡特殊召唤，若成功则进行后续处理
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 使自己回复1000基本分
		Duel.Recover(tp,1000,REASON_EFFECT)
	end
end
-- 效果②的发动代价检测与支付函数
function c59546797.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果②的发动准备与对象选择函数
function c59546797.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 判定是否满足发动条件：自己场上存在除自身以外的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 设置选择卡片时的提示信息为“请选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的效果处理函数
function c59546797.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 那只怪兽的攻击力直到下个回合的结束时上升1000。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
	tc:RegisterEffect(e1)
end
