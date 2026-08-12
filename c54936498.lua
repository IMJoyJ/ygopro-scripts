--インフルーエンス・ドラゴン
-- 效果：
-- 1回合1次，选择自己场上表侧表示存在的1只怪兽才能发动。选择的怪兽直到结束阶段时变成龙族。
function c54936498.initial_effect(c)
	-- 1回合1次，选择自己场上表侧表示存在的1只怪兽才能发动。选择的怪兽直到结束阶段时变成龙族。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54936498,0))  --"种族变化"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c54936498.tg)
	e1:SetOperation(c54936498.op)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选场上表侧表示且不是龙族的怪兽
function c54936498.filter(c)
	return c:IsFaceup() and not c:IsRace(RACE_DRAGON)
end
-- 效果发动的目标选择与判定
function c54936498.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c54936498.filter(chkc) end
	-- 在发动阶段，检查自己场上是否存在符合条件的怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c54936498.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置选择卡片时的提示信息为“请选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c54936498.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使选择的对象怪兽直到结束阶段时变成龙族
function c54936498.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的怪兽直到结束阶段时变成龙族。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_DRAGON)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
