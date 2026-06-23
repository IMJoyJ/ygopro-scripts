--結束 UNITY
-- 效果：
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的守备力直到回合结束时变成自己场上的全部表侧表示怪兽的原本守备力合计数值。
function c14731897.initial_effect(c)
	-- 效果发动条件：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的守备力直到回合结束时变成自己场上的全部表侧表示怪兽的原本守备力合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c14731897.target)
	e1:SetOperation(c14731897.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选场上表侧表示且守备力大于0的怪兽。
function c14731897.sumfilter(c)
	return c:IsFaceup() and c:IsDefenseAbove(0)
end
-- 过滤函数，用于筛选场上表侧表示且守备力大于0且守备力不等于指定值的怪兽。
function c14731897.filter(c,def)
	return c:IsFaceup() and c:IsDefenseAbove(0) and not c:IsDefense(def)
end
-- 效果目标选择函数，用于选择符合条件的怪兽作为效果对象。
function c14731897.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上所有表侧表示怪兽的集合。
	local g=Duel.GetMatchingGroup(c14731897.sumfilter,tp,LOCATION_MZONE,0,nil)
	local sum=g:GetSum(Card.GetBaseDefense)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c14731897.filter(chkc,sum) end
	-- 判断是否满足效果发动条件，即是否存在符合条件的目标怪兽。
	if chk==0 then return Duel.IsExistingTarget(c14731897.filter,tp,LOCATION_MZONE,0,1,nil,sum) end
	-- 向玩家提示选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择符合条件的怪兽作为效果对象。
	Duel.SelectTarget(tp,c14731897.filter,tp,LOCATION_MZONE,0,1,1,nil,sum)
end
-- 效果发动时执行的处理函数。
function c14731897.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 获取自己场上所有表侧表示怪兽的集合。
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		local def=0
		local sc=g:GetFirst()
		while sc do
			local cdef=sc:GetBaseDefense()
			if cdef<0 then cdef=0 end
			def=def+cdef
			sc=g:GetNext()
		end
		-- 将目标怪兽的守备力设置为所有自己场上表侧表示怪兽的原本守备力合计数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetValue(def)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
