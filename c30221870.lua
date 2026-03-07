--機皇帝ワイゼル∞－S・アブソープション
-- 效果：
-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：对方回合，把自己场上1只表侧表示的「机皇」怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤成功的场合，以对方场上1只怪兽为对象才能发动。这个回合，那只怪兽不能攻击。
-- ③：要让场上的卡破坏的效果发动时，把这张卡解放才能发动。那个发动无效并破坏。
function c30221870.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文内容：这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：对方回合，把自己场上1只表侧表示的「机皇」怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30221870,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,30221870)
	e2:SetCost(c30221870.spcost)
	e2:SetCondition(c30221870.spcon)
	e2:SetTarget(c30221870.sptg)
	e2:SetOperation(c30221870.spop)
	c:RegisterEffect(e2)
	-- 效果原文内容：②：这张卡特殊召唤成功的场合，以对方场上1只怪兽为对象才能发动。这个回合，那只怪兽不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30221870,1))  --"对方怪兽不能攻击"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(c30221870.atktg)
	e3:SetOperation(c30221870.atkop)
	c:RegisterEffect(e3)
	-- 效果原文内容：③：要让场上的卡破坏的效果发动时，把这张卡解放才能发动。那个发动无效并破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(30221870,2))  --"发动无效并破坏"
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c30221870.negcon)
	e4:SetCost(c30221870.negcost)
	e4:SetTarget(c30221870.negtg)
	e4:SetOperation(c30221870.negop)
	c:RegisterEffect(e4)
end
-- 规则层面操作：过滤满足条件的场上表侧表示的「机皇」怪兽（包括其怪兽区可用数量检查）
function c30221870.cfilter(c,tp)
	-- 规则层面操作：检查该怪兽是否为表侧表示、是否为「机皇」卡族、是否能作为墓地代价以及其所在区域是否可用
	return c:IsFaceup() and c:IsSetCard(0x13) and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 规则层面操作：检索满足条件的场上表侧表示的「机皇」怪兽并将其送去墓地作为特殊召唤的代价
function c30221870.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查是否存在满足条件的场上表侧表示的「机皇」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c30221870.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 规则层面操作：向玩家提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 规则层面操作：选择满足条件的场上表侧表示的「机皇」怪兽
	local g=Duel.SelectMatchingCard(tp,c30221870.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 规则层面操作：将所选怪兽送去墓地作为特殊召唤的代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果原文内容：对方回合，把自己场上1只表侧表示的「机皇」怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
function c30221870.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断当前回合玩家是否为非自己
	return Duel.GetTurnPlayer()~=tp
end
-- 效果原文内容：①：对方回合，把自己场上1只表侧表示的「机皇」怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
function c30221870.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	-- 规则层面操作：设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果原文内容：①：对方回合，把自己场上1只表侧表示的「机皇」怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
function c30221870.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面操作：将此卡特殊召唤到场上并完成召唤程序
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- 效果原文内容：②：这张卡特殊召唤成功的场合，以对方场上1只怪兽为对象才能发动。这个回合，那只怪兽不能攻击。
function c30221870.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 规则层面操作：检查是否存在对方场上的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 规则层面操作：向玩家提示选择对方场上的表侧表示怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 规则层面操作：选择对方场上的表侧表示怪兽
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果原文内容：②：这张卡特殊召唤成功的场合，以对方场上1只怪兽为对象才能发动。这个回合，那只怪兽不能攻击。
function c30221870.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 效果原文内容：②：这张卡特殊召唤成功的场合，以对方场上1只怪兽为对象才能发动。这个回合，那只怪兽不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 效果原文内容：③：要让场上的卡破坏的效果发动时，把这张卡解放才能发动。那个发动无效并破坏。
function c30221870.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断此卡是否处于战斗破坏状态或是否可以被无效
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	if re:IsHasCategory(CATEGORY_NEGATE)
		-- 规则层面操作：排除连锁中为永续魔法发动的无效效果
		and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 规则层面操作：获取连锁中涉及破坏的处理信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsOnField,nil)-tg:GetCount()>0
end
-- 效果原文内容：③：要让场上的卡破坏的效果发动时，把这张卡解放才能发动。那个发动无效并破坏。
function c30221870.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 规则层面操作：将此卡解放作为无效发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果原文内容：③：要让场上的卡破坏的效果发动时，把这张卡解放才能发动。那个发动无效并破坏。
function c30221870.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面操作：设置无效发动的处理信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 规则层面操作：设置破坏发动的处理信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果原文内容：③：要让场上的卡破坏的效果发动时，把这张卡解放才能发动。那个发动无效并破坏。
function c30221870.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断是否成功无效发动并确认目标卡是否有效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 规则层面操作：破坏连锁中涉及的目标卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
