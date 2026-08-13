--百獣のパラディオン
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以从手卡往作为连接怪兽所连接区的自己场上守备表示特殊召唤。
-- ②：以自己场上1只「圣像骑士」连接怪兽为对象才能发动。这个回合，那只怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c28031913.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次，①：这张卡可以从手卡往作为连接怪兽所连接区的自己场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetCountLimit(1,28031913+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c28031913.spcon)
	e1:SetValue(c28031913.spval)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次，②：以自己场上1只「圣像骑士」连接怪兽为对象才能发动。这个回合，那只怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28031913,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,28031914)
	e2:SetCondition(c28031913.condition)
	e2:SetTarget(c28031913.target)
	e2:SetOperation(c28031913.operation)
	c:RegisterEffect(e2)
end
-- 规则特殊召唤的发动条件：若c为nil则视为可发动；否则获取该卡控制者的连接区，检查其场上连接区是否存在可用空格。
function c28031913.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 取得tp玩家场上所有连接怪兽所连接的区域（zone掩码），作为可特殊召唤的位置。
	local zone=Duel.GetLinkedZone(tp)
	-- 检查在可用zone内是否存在至少1个空位，若有则满足规则特殊召唤的场上条件。
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 为规则特殊召唤提供附加参数：第一个返回值0表示使用默认特殊召唤手续，第二个返回值为该卡控制者当前的连接区，用于指定特殊召唤到的区域。
function c28031913.spval(e,c)
	-- 返回参数：(0, 连接区zone)，0表示特殊召唤类型为通常规则特殊召唤（无额外条件），连接区zone表示允许特殊召唤到的位置。
	return 0,Duel.GetLinkedZone(c:GetControler())
end
-- ②效果的发动条件：当前回合玩家可以进入战斗阶段，即发动时处于主要阶段且没有其他禁止进入战斗阶段的限制，满足才能发动。
function c28031913.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否允许进入战斗阶段；若允许则该效果的发动条件成立。
	return Duel.IsAbleToEnterBP()
end
-- 对象选择过滤器：选择自己场上表侧表示的、「圣像骑士」字段的连接怪兽，且该怪兽尚未被赋予贯穿伤害效果（避免重复赋予）。
function c28031913.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x116) and c:IsType(TYPE_LINK) and not c:IsHasEffect(EFFECT_PIERCE)
end
-- ②效果发动时的目标选择流程：验证选择对象是否合法，在发动时确认存在至少1张可选对象，提示玩家选择，并选定1张符合条件的卡作为效果对象。
function c28031913.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 在效果发动的合法性检查阶段（chk==0），检查场上是否存在至少1张满足过滤条件的卡，若不存在则无法发动。
	if chk==0 then return Duel.IsExistingTarget(c28031913.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向发动玩家显示选择卡片提示，提示内容为“请选择表侧表示的卡”（HINTMSG_FACEUP）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1张符合条件的「圣像骑士」连接怪兽，并将其登记为当前连锁的效果对象（取对象）。
	Duel.SelectTarget(tp,c28031913.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理时，若对象仍然存在于场上且与效果关联，则给对象怪兽赋予贯穿伤害效果，该效果持续到这个回合结束。
function c28031913.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择并登记的第一个目标怪兽，用于后续赋予效果。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
