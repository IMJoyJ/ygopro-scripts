--フレムベル・アーチャー
-- 效果：
-- 把自己场上表侧表示存在的1只炎族怪兽解放发动。场上存在的名字带有「炎狱」的怪兽的攻击力直到结束阶段时上升800。这个效果1回合只能使用1次。
function c54326448.initial_effect(c)
	-- 把自己场上表侧表示存在的1只炎族怪兽解放发动。场上存在的名字带有「炎狱」的怪兽的攻击力直到结束阶段时上升800。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54326448,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c54326448.attg)
	e1:SetOperation(c54326448.atop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的炎族怪兽，且该怪兽以外的场上存在名字带有「炎狱」的怪兽
function c54326448.cfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_PYRO)
		-- 检查场上是否存在除该怪兽以外的名字带有「炎狱」的怪兽
		and Duel.IsExistingMatchingCard(c54326448.filter,tp,LOCATION_MZONE,0,1,c)
end
-- 过滤条件：场上表侧表示的名字带有「炎狱」的怪兽
function c54326448.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x2c)
end
-- 效果的发动与代价支付：检查并解放自己场上1只表侧表示的炎族怪兽
function c54326448.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己场上是否存在可作为代价解放的炎族怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c54326448.cfilter,1,nil,tp) end
	-- 选择自己场上1只表侧表示的炎族怪兽作为解放对象
	local g=Duel.SelectReleaseGroup(tp,c54326448.cfilter,1,1,nil,tp)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 效果处理：使场上所有名字带有「炎狱」的怪兽攻击力上升800，直到结束阶段
function c54326448.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有表侧表示的名字带有「炎狱」的怪兽组
	local g=Duel.GetMatchingGroup(c54326448.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	while tc do
		-- 攻击力直到结束阶段时上升800
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
