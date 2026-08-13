--ミュートリアル・ビースト
-- 效果：
-- 这张卡不用「秘异三变」卡的效果不能特殊召唤。这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡不会成为对方怪兽的效果的对象。
-- ②：对方把魔法卡的效果发动时，从自己的手卡·场上把1张卡除外才能发动。那个发动无效并除外。
-- ③：这张卡被对方破坏的场合，以除外的1张自己的「秘异三变」陷阱卡为对象才能发动。那张卡加入手卡。
function c34695290.initial_effect(c)
	-- 这张卡不用「秘异三变」卡的效果不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c34695290.splimit)
	c:RegisterEffect(e1)
	-- ①：这张卡不会成为对方怪兽的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c34695290.ctval)
	c:RegisterEffect(e2)
	-- 这个卡名的②③的效果1回合各能使用1次。②：对方把魔法卡的效果发动时，从自己的手卡·场上把1张卡除外才能发动。那个发动无效并除外。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCountLimit(1,34695290)
	e3:SetCondition(c34695290.negcon)
	e3:SetCost(c34695290.negcost)
	-- 设置目标判定函数：使用通用函数 aux.nbtg 检查并声明当前连锁的魔法卡发动将无效并除外，并自动登记必要操作信息（若该魔法在墓地发动则追加 CATEGORY_GRAVE_ACTION）。
	e3:SetTarget(aux.nbtg)
	e3:SetOperation(c34695290.negop)
	c:RegisterEffect(e3)
	-- ③：这张卡被对方破坏的场合，以除外的1张自己的「秘异三变」陷阱卡为对象才能发动。那张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,34695291)
	e4:SetCondition(c34695290.thcon)
	e4:SetTarget(c34695290.thtg)
	e4:SetOperation(c34695290.thop)
	c:RegisterEffect(e4)
end
-- 特殊召唤条件判定：仅当进行特殊召唤的效果的发动卡（se:GetHandler()）属于「秘异三变」字段时，此卡才允许被特殊召唤，用于实现“不用「秘异三变」卡的效果不能特殊召唤”。
function c34695290.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0x157)
end
-- 设置“不能成为效果对象”的判定值：当效果发动者是这张卡的对方玩家且该效果为怪兽效果时返回 true，即对方怪兽效果不能以这张卡为对象。
function c34695290.ctval(e,re,rp)
	-- 该判定条件为：效果来源为对方（aux.tgoval）且效果类型是怪兽效果。
	return aux.tgoval(e,re,rp) and re:IsActiveType(TYPE_MONSTER)
end
-- ②效果的发动条件：这张卡不处于战斗破坏确定状态；当前连锁的发动者是对方；对方发动的效果是魔法卡；且该魔法卡的发动的确可以被无效。
function c34695290.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep==1-tp
		-- 追加条件：当前连锁发动的效果必须是魔法卡，且该魔法卡发动的连锁能够被无效。
		and re:IsActiveType(TYPE_SPELL) and Duel.IsChainNegatable(ev)
end
-- ②效果的发动代价：从自己的手牌或场上选择1张卡表侧除外。先检查是否存在可除外的卡，再让玩家选择并支付代价。
function c34695290.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己的手牌和场上合计存在至少1张可以作为代价除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	-- 显示“请选择要除外的卡”的提示，让玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己的手牌和场上筛选出可以除外作为代价的卡，并让玩家选择其中1张，存入组对象 g。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的代价卡以表侧表示除外，完成代价支付。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果处理：先使对方那张魔法卡的发动无效；若该魔法卡仍与那个效果关联，则将其以表侧表示除外，实现“那个发动无效并除外”。
function c34695290.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断并执行：若无效对方连锁成功且该魔法卡仍然与效果关联，则继续将其除外。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将当前连锁中对方发动的魔法卡（eg）以表侧表示除外。
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
-- ③效果的触发条件：这张卡被对方破坏，且破坏前控制者是自己，满足时才能发动。
function c34695290.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp)
end
-- ③效果的对象筛选：选择除外区中表侧表示、属于「秘异三变」字段的陷阱卡，并且该卡可以加入手牌。
function c34695290.thtgfilter(c)
	return c:IsSetCard(0x157) and c:IsType(TYPE_TRAP) and c:IsAbleToHand() and c:IsFaceup()
end
-- ③效果的发动目标处理：从自己的除外区选择1张满足条件的「秘异三变」陷阱卡作为对象，并设置加入手牌的操作信息。
function c34695290.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c34695290.thtgfilter(chkc) end
	-- 目标检查：确认除外区是否存在至少1张满足条件的自己的「秘异三变」陷阱卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c34695290.thtgfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 显示“请选择要加入手牌的卡”的提示，引导玩家选择目标卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从除外区选择1张符合条件的「秘异三变」陷阱卡作为对象，并自动登记为当前连锁对象。
	local g=Duel.SelectTarget(tp,c34695290.thtgfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息：本次效果处理分类为 CATEGORY_TOHAND，处理对象为选中的卡 g，数量为1，用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ③效果处理：取得发动时选择的对象卡，若仍与效果关联则将其加入手卡。
function c34695290.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这张效果发动时选择的对象卡（唯一对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡直接加入持有者手卡，完成“那张卡加入手卡”的处理。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
