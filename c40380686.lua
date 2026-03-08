--ドロゴン・ベビー
-- 效果：
-- ①：把自己场上的这张卡作为同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
-- ②：这张卡作为同调素材送去墓地的场合，宣言1个种族或者属性，以自己场上1只同调怪兽为对象才能发动。那只怪兽直到回合结束时变成宣言的种族或者属性。
function c40380686.initial_effect(c)
	-- 效果原文内容：①：把自己场上的这张卡作为同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_NONTUNER)
	e1:SetValue(c40380686.tnval)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：这张卡作为同调素材送去墓地的场合，宣言1个种族或者属性，以自己场上1只同调怪兽为对象才能发动。那只怪兽直到回合结束时变成宣言的种族或者属性。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(c40380686.condition)
	e2:SetTarget(c40380686.target)
	e2:SetOperation(c40380686.operation)
	c:RegisterEffect(e2)
end
-- 规则层面操作：使该卡在同调召唤时可以当作调整以外的怪兽使用
function c40380686.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler())
end
-- 规则层面操作：判断该卡是否作为同调素材被送入墓地
function c40380686.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 规则层面操作：筛选场上表侧表示的同调怪兽
function c40380686.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 规则层面操作：选择宣言种族或属性，选择目标同调怪兽
function c40380686.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c40380686.filter(chkc) end
	-- 规则层面操作：判断是否存在符合条件的目标同调怪兽
	if chk==0 then return Duel.IsExistingTarget(c40380686.filter,tp,LOCATION_MZONE,0,1,nil) end
	local ar=0
	-- 规则层面操作：让玩家选择宣言种族或属性
	local op=Duel.SelectOption(tp,aux.Stringid(40380686,0),aux.Stringid(40380686,1))  --"改变种族/改变属性"
	if op==0 then
		-- 规则层面操作：提示玩家选择种族
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
		-- 规则层面操作：让玩家宣言一个种族
		ar=Duel.AnnounceRace(tp,1,RACE_ALL)
	else
		-- 规则层面操作：提示玩家选择属性
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
		-- 规则层面操作：让玩家宣言一个属性
		ar=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	end
	e:SetLabel(op,ar)
	-- 规则层面操作：提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 规则层面操作：选择场上一只表侧表示的同调怪兽作为对象
	Duel.SelectTarget(tp,c40380686.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 规则层面操作：根据选择的种族或属性改变目标怪兽的种族或属性
function c40380686.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	local c,op,ar=e:GetHandler(),e:GetLabel()
	if op==0 then
		-- 效果原文内容：那只怪兽直到回合结束时变成宣言的种族
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(ar)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	else
		-- 效果原文内容：那只怪兽直到回合结束时变成宣言的属性
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(ar)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
