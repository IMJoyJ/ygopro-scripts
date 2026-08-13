--エッジインプ・DTモドキ
-- 效果：
-- 这张卡在规则上也当作「魔玩具」卡使用。「锋利小鬼·仿DT」的效果1回合只能使用1次。
-- ①：以自己的场上·墓地1只「魔玩具」融合怪兽为对象才能发动。这张卡的攻击力·守备力直到回合结束时变成和那只怪兽的原本数值相同。
function c34566435.initial_effect(c)
	-- 对应效果原文：“「锋利小鬼·仿DT」的效果1回合只能使用1次。①：以自己的场上·墓地1只「魔玩具」融合怪兽为对象才能发动。这张卡的攻击力·守备力直到回合结束时变成和那只怪兽的原本数值相同。” 本段代码创建并注册该起动效果，设置取对象、怪兽区发动、1回合1次以及目标与处理函数。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34566435,0))  --"攻守变化"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,34566435)
	e1:SetTarget(c34566435.target)
	e1:SetOperation(c34566435.operation)
	c:RegisterEffect(e1)
end
-- 对象筛选函数：卡必须位于自己墓地，或在自己场上表侧表示；必须是融合怪兽；必须是卡名含有「魔玩具」（0xad）的怪兽。
function c34566435.filter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_FUSION) and c:IsSetCard(0xad)
end
-- 目标选择处理函数：负责在连锁时验证对象合法性、发动时检查是否存在合法对象，并让玩家从自己场上（表侧）·墓地选择1只符合条件的「魔玩具」融合怪兽作为对象。
function c34566435.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c34566435.filter(chkc) end
	-- 发动条件判定：确认自己场上（表侧）·墓地存在至少1只符合条件的「魔玩具」融合怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c34566435.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送选择提示，UI显示为“请选择表侧表示的卡”，用于引导选择符合条件的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上（表侧）·墓地选择1只符合条件的「魔玩具」融合怪兽，并将所选卡登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,c34566435.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
end
-- 效果处理逻辑：当发动怪兽仍在自己场上表侧、且对象仍然合法时，将这张卡的攻击力和守备力各变为对象怪兽的原本攻击力和原本守备力，持续到回合结束。
function c34566435.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得本效果选定的对象怪兽（因为是取1只对象，所以用GetFirstTarget直接获取）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and (tc:IsLocation(LOCATION_GRAVE) or tc:IsFaceup()) then
		-- 对应①效果中的攻击力变化部分：来自原文‘这张卡的攻击力·守备力直到回合结束时变成和那只怪兽的原本数值相同’中的攻击力部分——将这张卡的攻击力变为对象怪兽的原本攻击力，直到回合结束。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(tc:GetBaseDefense())
		c:RegisterEffect(e2)
	end
end
