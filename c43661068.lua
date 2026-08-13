--星に願いを
-- 效果：
-- 选择自己场上表侧表示存在的1只怪兽发动。持有和选择的怪兽相同攻击力或者相同守备力的自己场上的怪兽的等级直到结束阶段时变成和选择的怪兽相同。
function c43661068.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只怪兽发动。持有和选择的怪兽相同攻击力或者相同守备力的自己场上的怪兽的等级直到结束阶段时变成和选择的怪兽相同。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c43661068.target)
	e1:SetOperation(c43661068.activate)
	c:RegisterEffect(e1)
end
-- 发动时选择对象的处理：检查并选择自己场上1只满足条件的表侧表示怪兽作为效果对象。
function c43661068.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c43661068.tfilter(chkc,tp) end
	-- 效果发动时确认自己场上是否存在满足条件的表侧表示怪兽作为合法对象（表侧且等级大于0，且场上有其他怪兽攻击力或守备力与之相同）。
	if chk==0 then return Duel.IsExistingTarget(c43661068.tfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向操作玩家显示“请选择表侧表示的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家从自己场上选择1只满足条件的表侧表示怪兽，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,c43661068.tfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 定义过滤函数：筛选自己场上表侧表示、等级大于0，且攻击力等于指定值或守备力等于指定值的怪兽（即要被改变等级的怪兽）。
function c43661068.filter(c,atk,def)
	return c:IsFaceup() and c:GetLevel()>0 and (c:IsAttack(atk) or c:IsDefense(def))
end
-- 定义选对象过滤函数：选择自己场上表侧表示、等级大于0，且场上存在另一只与之攻击力或守备力相同的表侧表示怪兽作为效果对象。
function c43661068.tfilter(c,tp)
	return c:IsFaceup() and c:GetLevel()>0
		-- 追加条件：自己场上存在另一只怪兽，其攻击力等于该对象怪兽的攻击力，或守备力等于该对象怪兽的守备力（排除对象自身）。
		and Duel.IsExistingMatchingCard(c43661068.filter,tp,LOCATION_MZONE,0,1,c,c:GetAttack(),c:GetDefense())
end
-- 效果处理：若对象怪兽仍表侧表示且与效果关联，则获取所有符合条件的我方怪兽，将其等级统一变为对象怪兽的等级，直到结束阶段。
function c43661068.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 获取自己场上除对象怪兽以外，所有表侧表示且等级大于0、攻击力等于对象攻击力或守备力等于对象守备力的怪兽。
		local g=Duel.GetMatchingGroup(c43661068.filter,tp,LOCATION_MZONE,0,tc,tc:GetAttack(),tc:GetDefense())
		local lv=tc:GetLevel()
		local lc=g:GetFirst()
		while lc do
			-- 直到结束阶段时变成和选择的怪兽相同。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			lc:RegisterEffect(e1)
			lc=g:GetNext()
		end
	end
end
