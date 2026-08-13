--ドロゴン・ベビー
-- 效果：
-- ①：把自己场上的这张卡作为同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
-- ②：这张卡作为同调素材送去墓地的场合，宣言1个种族或者属性，以自己场上1只同调怪兽为对象才能发动。那只怪兽直到回合结束时变成宣言的种族或者属性。
function c40380686.initial_effect(c)
	-- ①：把自己场上的这张卡作为同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_NONTUNER)
	e1:SetValue(c40380686.tnval)
	c:RegisterEffect(e1)
	-- ②：这张卡作为同调素材送去墓地的场合，宣言1个种族或者属性，以自己场上1只同调怪兽为对象才能发动。那只怪兽直到回合结束时变成宣言的种族或者属性。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(c40380686.condition)
	e2:SetTarget(c40380686.target)
	e2:SetOperation(c40380686.operation)
	c:RegisterEffect(e2)
end
-- 判定这张卡作为同调素材时是否可被当作调整以外的怪兽：仅当这张卡与同调素材中的另一只怪兽的控制者相同（即双方都在自己场上作为素材）时返回真。
function c40380686.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler())
end
-- 效果②的发动条件：这张卡因同调召唤被作为素材送去墓地时，且在墓地中才能发动。
function c40380686.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 效果②选择对象的过滤条件：选择自己场上表侧表示的同调怪兽。
function c40380686.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 效果②发动时的目标选择与宣言操作：确认有可选的表侧同调怪兽后，先选择改变‘种族’还是‘属性’，再宣言对应的种族或属性，最后从自己场上选择1只表侧同调怪兽作为取对象目标。
function c40380686.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c40380686.filter(chkc) end
	-- 发动时检查自己场上是否存在至少1只表侧表示的同调怪兽可以作为效果对象，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c40380686.filter,tp,LOCATION_MZONE,0,1,nil) end
	local ar=0
	-- 让玩家选择要宣言的种类：0表示宣言种族，1表示宣言属性，选择结果存入op。
	local op=Duel.SelectOption(tp,aux.Stringid(40380686,0),aux.Stringid(40380686,1))  --"改变种族/改变属性"
	if op==0 then
		-- 向玩家提示‘请选择要宣言的种族’，随后进入种族宣言界面。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
		-- 从全种族中宣言1个种族，将宣言结果存入ar，用于后续改变对象的种族。
		ar=Duel.AnnounceRace(tp,1,RACE_ALL)
	else
		-- 向玩家提示‘请选择要宣言的属性’，随后进入属性宣言界面。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
		-- 从全属性中宣言1个属性，将宣言结果存入ar，用于后续改变对象的属性。
		ar=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	end
	e:SetLabel(op,ar)
	-- 提示玩家选择表侧表示的卡，作为选择目标的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上选择1只满足过滤条件（表侧同调怪兽）的卡作为效果对象，并登记为该连锁的对象。
	Duel.SelectTarget(tp,c40380686.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②处理时：取出对象卡，确认其仍与效果有关且表侧表示后，根据玩家之前选择的是种族还是属性，为目标怪兽赋予改变种族或属性的效果，持续到回合结束。
function c40380686.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的效果对象（自己场上的1只同调怪兽）。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	local c,op,ar=e:GetHandler(),e:GetLabel()
	if op==0 then
		-- 那只怪兽直到回合结束时变成宣言的种族或者属性。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(ar)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	else
		-- 那只怪兽直到回合结束时变成宣言的种族或者属性。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(ar)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
