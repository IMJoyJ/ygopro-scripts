--フォース・リゾネーター
-- 效果：
-- 把自己场上表侧表示存在的这张卡送去墓地，选择自己场上表侧表示存在的1只怪兽发动。这个回合，选择的怪兽攻击的场合，对方直到伤害步骤结束时不能把以怪兽为对象的魔法·陷阱·效果怪兽的效果发动。
function c40583194.initial_effect(c)
	-- 把自己场上表侧表示存在的这张卡送去墓地，选择自己场上表侧表示存在的1只怪兽发动。这个回合，选择的怪兽攻击的场合，对方直到伤害步骤结束时不能把以怪兽为对象的魔法·陷阱·效果怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40583194,0))  --"效果抑制"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c40583194.cost)
	e1:SetTarget(c40583194.target)
	e1:SetOperation(c40583194.operation)
	c:RegisterEffect(e1)
end
-- 代价函数：检查并执行把这张卡从自己场上送去墓地作为发动代价。
function c40583194.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡（效果发动者）以代价原因送入墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 发动目标选择函数：进行对象选择合法性检查，并选择自己场上表侧表示存在的1只怪兽作为效果对象。
function c40583194.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在发动合法性检查时，确认自己场上是否存在除这张卡以外的表侧表示怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 给出选择提示，提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上表侧表示怪兽中选择1只作为效果对象，并登记为连锁对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数：若对象怪兽仍在场上且与效果关联，则给该怪兽赋予一个持续限制效果，在它攻击时使对方不能发动以怪兽为对象的魔法·陷阱·效果怪兽的效果。
function c40583194.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 这个回合，选择的怪兽攻击的场合，对方直到伤害步骤结束时不能把以怪兽为对象的魔法·陷阱·效果怪兽的效果发动。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SELECT_EFFECT_TARGET)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(0,0xff)
		e1:SetValue(c40583194.etarget)
		e1:SetCondition(c40583194.limcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 限制效果的判定函数：不能成为对方效果对象的卡限定为怪兽，且为表侧表示或在怪兽区（里侧怪兽同样受限制）。
function c40583194.etarget(e,re,c)
	return c:IsType(TYPE_MONSTER) and (c:IsFaceup() or c:IsLocation(LOCATION_MZONE))
end
-- 限制效果的发动条件：仅在所选怪兽进行攻击时生效。
function c40583194.limcon(e)
	-- 判断当前攻击的怪兽是否为被赋予该限制效果的那只选择怪兽。
	return Duel.GetAttacker()==e:GetHandler()
end
