--霊魂の円環
-- 效果：
-- 「灵魂的圆环」的①②的效果1回合各能使用1次。
-- ①：这张卡在魔法与陷阱区域存在，自己场上的表侧表示的灵魂怪兽回到自己手卡的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
-- ②：对方怪兽的攻击宣言时把自己墓地1只灵魂怪兽除外才能发动。那次攻击无效，那之后战斗阶段结束。
function c276357.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：对方怪兽的攻击宣言时把自己墓地1只灵魂怪兽除外才能发动。那次攻击无效，那之后战斗阶段结束。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(276357,0))  --"卡片破坏"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCountLimit(1,276357)
	e2:SetCondition(c276357.condition)
	e2:SetCost(c276357.cost)
	e2:SetOperation(c276357.activate)
	c:RegisterEffect(e2)
	-- ①：这张卡在魔法与陷阱区域存在，自己场上的表侧表示的灵魂怪兽回到自己手卡的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(276357,1))  --"攻击无效"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,276358)
	e3:SetCondition(c276357.descon)
	e3:SetTarget(c276357.destg)
	e3:SetOperation(c276357.desop)
	c:RegisterEffect(e3)
end
c276357.has_text_type=TYPE_SPIRIT
-- 定义②效果的发动条件，检查当前攻击宣言的怪兽是否由对方控制，即只允许在对方怪兽进行攻击宣言时发动。
function c276357.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击宣言怪兽的控制者为对方（1-tp），满足对方怪兽攻击宣言这一发动条件。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 定义②效果代价的过滤器：要求墓地中的卡是灵魂怪兽，并且能够作为代价从墓地除外。
function c276357.cfilter(c)
	return c:IsType(TYPE_SPIRIT) and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动代价处理：先检查自己墓地是否存在可除外的灵魂怪兽，若存在则让玩家选择1只，将其表侧除外作为发动代价。
function c276357.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段：确认自己墓地中是否存在至少1只满足条件的灵魂怪兽（灵魂怪兽且可作为代价除外），若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c276357.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择要除外的卡”的选择提示，用于下一步选择墓地中的灵魂怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地中筛选符合cfilter条件的卡中选择1张，作为发动代价而除外的对象。
	local g=Duel.SelectMatchingCard(tp,c276357.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的灵魂怪兽表侧表示除外，作为该效果的发动代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的处理：先无效那次攻击；若无效成功，则中断当前效果时点，并跳过对方的战斗阶段。
function c276357.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效当前攻击，若无效成功（返回true）则继续执行后续的结束战斗阶段处理。
	if Duel.NegateAttack() then
		-- 中断当前连锁的效果处理，使之后的处理不与本次效果同时进行，避免错过时点。
		Duel.BreakEffect()
		-- 跳过对方（1-tp）的战斗阶段，且在该战斗步骤结束时重置，使战斗阶段直接结束。
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
-- 定义①效果的移动怪兽过滤器：判断回到手卡的怪兽此前位于主要怪兽区、为表侧表示、由自己控制且场上种类为灵魂怪兽。
function c276357.filter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsControler(tp) and c:GetPreviousTypeOnField()&TYPE_SPIRIT>0
end
-- ①效果的发动条件：回到手卡的怪兽群中存在满足条件的我方表侧灵魂怪兽，并且这张“灵魂的圆环”的效果处于有效状态时才可发动。
function c276357.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c276357.filter,1,nil,tp) and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- ①效果的发动时选择对象：从对方场上选择1张卡作为对象，并登记破坏该卡的操作信息。
function c276357.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 发动时检查：确认对方场上存在至少1张可以作为效果对象的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示“请选择要破坏的卡”的选择提示，用于选择对方场上的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为效果对象（取对象），为后续破坏做准备。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，登记本次连锁将破坏1张卡（对象为g），使相关时点与判定能够正确响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果的处理：取出对象卡，若该卡仍与本次效果有关联则将其破坏。
function c276357.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡（此效果只选择1张，因此取第一个目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因（REASON_EFFECT）将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
