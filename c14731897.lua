--結束 UNITY
-- 效果：
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的守备力直到回合结束时变成自己场上的全部表侧表示怪兽的原本守备力合计数值。
function c14731897.initial_effect(c)
	-- 以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的守备力直到回合结束时变成自己场上的全部表侧表示怪兽的原本守备力合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果的发动条件为：当前不是伤害步骤，或者在伤害计算前，即只允许在伤害计算前的伤害步骤中发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c14731897.target)
	e1:SetOperation(c14731897.activate)
	c:RegisterEffect(e1)
end
-- 过滤出自己场上表侧表示且守备力不低于0的怪兽，用于后续合计原本守备力。
function c14731897.sumfilter(c)
	return c:IsFaceup() and c:IsDefenseAbove(0)
end
-- 对象选择的过滤条件：自己场上表侧表示、守备力不低于0、且当前守备力不等于目标合计值，以确保守备力会实际发生改变。
function c14731897.filter(c,def)
	return c:IsFaceup() and c:IsDefenseAbove(0) and not c:IsDefense(def)
end
-- 效果发动前的目标选择处理：先计算自己场上全部表侧表示怪兽的原本守备力合计，再确认存在可选择的合法对象，并提示玩家选择1只表侧表示怪兽作为对象。
function c14731897.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上所有满足sumfilter条件（表侧表示且守备力>=0）的怪兽集合，用于计算原本守备力合计。
	local g=Duel.GetMatchingGroup(c14731897.sumfilter,tp,LOCATION_MZONE,0,nil)
	local sum=g:GetSum(Card.GetBaseDefense)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c14731897.filter(chkc,sum) end
	-- 在发动合法性检查（chk==0）时，确认自己场上至少存在1只可以作为效果对象的表侧表示怪兽；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c14731897.filter,tp,LOCATION_MZONE,0,1,nil,sum) end
	-- 向发动玩家发出选择提示，告知接下来需要选择“表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上表侧表示怪兽中选择1只满足过滤条件的怪兽，将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,c14731897.filter,tp,LOCATION_MZONE,0,1,1,nil,sum)
end
-- 效果处理阶段：取得对象怪兽，若其仍与效果相关且表侧表示，则重新计算自己场上全部表侧表示怪兽的原本守备力合计（负值按0计），并给对象怪兽赋予“守备力变为该合计数值”的效果，持续到回合结束。
function c14731897.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 获取自己场上当前全部表侧表示怪兽，用于计算原本守备力合计。
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		local def=0
		local sc=g:GetFirst()
		while sc do
			local cdef=sc:GetBaseDefense()
			if cdef<0 then cdef=0 end
			def=def+cdef
			sc=g:GetNext()
		end
		-- 那只怪兽的守备力直到回合结束时变成自己场上的全部表侧表示怪兽的原本守备力合计数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetValue(def)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
