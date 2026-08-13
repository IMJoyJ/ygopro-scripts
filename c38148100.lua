--アロマセラフィ－ローズマリー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：只要自己基本分比对方多并有这张卡在怪兽区域存在，自己场上的植物族怪兽的攻击力·守备力上升500。
-- ②：1回合1次，自己基本分回复的场合，以对方场上1张表侧表示卡为对象发动。那张卡的效果直到回合结束时无效。
function c38148100.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整 + 1只以上调整以外的怪兽（无其他素材限制），并设定召唤条件，同时满足同调召唤的苏生限制。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：只要自己基本分比对方多并有这张卡在怪兽区域存在，自己场上的植物族怪兽的攻击力·守备力上升500。（该段实现攻击力上升部分）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(c38148100.adcon)
	-- 设置该永续效果只对自己场上的植物族怪兽适用（以植物族作为目标筛选条件）。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_PLANT))
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己基本分回复的场合，以对方场上1张表侧表示卡为对象发动。那张卡的效果直到回合结束时无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(38148100,0))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_RECOVER)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c38148100.negcon)
	e3:SetTarget(c38148100.negtg)
	e3:SetOperation(c38148100.negop)
	c:RegisterEffect(e3)
end
-- 永续攻击力上升效果的发动条件函数：返回一个条件，用于判断是否存在“自己基本分比对方多”的局势，只有满足时才适用①卡的增攻/增防效果。
function c38148100.adcon(e)
	local tp=e:GetHandlerPlayer()
	-- 比较当前自己LP是否大于对方LP，若大于则条件成立（用于①效果的“自己基本分比对方多”条件判定）。
	return Duel.GetLP(tp)>Duel.GetLP(1-tp)
end
-- ②效果的发动条件函数：判断当前触发的事件是否为自己基本分回复（ep==tp），是则允许发动（结合EVENT_RECOVER事件，即“自己基本分回复的场合”）。
function c38148100.negcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- ②效果的目标选择函数：选择对方场上1张表侧表示卡作为对象，并要求该卡当前能被无效效果（aux.NegateAnyFilter），同时设置无效分类信息。
function c38148100.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 当连锁处理中重新指定/检查对象chkc时，判断该卡是否满足：对方场上表侧表示且可以被无效；若不满足则不能作为本效果对象（防止对象转移成不合法卡）。
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	if chk==0 then return true end
	-- 发动取对象选择前，向操作玩家显示“请选择要无效的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让发动玩家从对方场上选择1张表侧表示且可被无效的卡作为效果对象，并将选择结果登记为本连锁的对象（取对象操作）。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁的操作信息，标明该连锁包含“无效”（CATEGORY_DISABLE）分类，对象为选出的卡g，数量1，供其他卡对该效果进行响应与判定。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ②效果实际处理：将对象卡的效果无效化直到回合结束，若对象卡为陷阱怪兽则额外无效其陷阱怪兽化状态；同时无效以该卡为来源的相关连锁。
function c38148100.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从当前连锁中获取发动时选择的目标对象卡（这里只有1个对象，所以取第一张）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 将对象卡作为发动源的相关连锁一并无效，重置时机为变里侧时（RESET_TURN_SET），保证“那张卡的效果无效”能覆盖其连锁。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那张卡的效果直到回合结束时无效。（此处通过EFFECT_DISABLE使作为怪兽卡的效果无效）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那张卡的效果直到回合结束时无效。（此处通过EFFECT_DISABLE_EFFECT使卡面记载的效果文字无效）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那张卡的效果直到回合结束时无效。（若对象是陷阱怪兽，则额外将其作为陷阱怪兽的效果无效，使其不再当作怪兽）
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
