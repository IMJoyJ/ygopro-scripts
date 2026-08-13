--C・コイル
-- 效果：
-- 选择自己场上存在的1只名字带有「链」的怪兽发动。那只怪兽的攻击力·守备力上升300。这个效果1回合只能使用1次。
function c53152590.initial_effect(c)
	-- 选择自己场上存在的1只名字带有「链」的怪兽发动。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53152590,0))  --"攻守上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c53152590.atktg)
	e1:SetOperation(c53152590.atkop)
	c:RegisterEffect(e1)
end
-- 判断卡是否为表侧表示且卡名含有「链」字段。
function c53152590.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x25)
end
-- 发动条件的判定与对象选择：验证指定对象合法、确认存在可选的表侧表示「链」怪兽，提示玩家并选择1只作为效果对象。
function c53152590.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c53152590.filter(chkc) end
	-- 效果发动时检查自己场上是否存在至少1只表侧表示且名字带有「链」的怪兽，若没有则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c53152590.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 进行对象选择前向玩家显示“请选择表侧表示的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只满足条件的表侧表示「链」怪兽，并将其指定为效果的对象。
	Duel.SelectTarget(tp,c53152590.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：当对象怪兽仍表侧表示且与效果关联时，为其附加攻击力·守备力各上升300的效果。
function c53152590.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力·守备力上升300
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
