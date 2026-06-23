--C・コイル
-- 效果：
-- 选择自己场上存在的1只名字带有「链」的怪兽发动。那只怪兽的攻击力·守备力上升300。这个效果1回合只能使用1次。
function c53152590.initial_effect(c)
	-- 创建一个起动效果，效果描述为“攻守上升”，属于改变攻击效果，发动范围在主要怪兽区，只能发动一次，需要选择对象
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
-- 过滤函数：检查目标是否为表侧表示且卡名含有「链」
function c53152590.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x25)
end
-- 设置效果的目标选择函数，用于选择自己场上表侧表示的1只名字带有「链」的怪兽
function c53152590.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c53152590.filter(chkc) end
	-- 判断是否满足选择目标的条件：自己场上是否存在1只名字带有「链」的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c53152590.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示“请选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标：从自己场上选择1只名字带有「链」的表侧表示怪兽
	Duel.SelectTarget(tp,c53152590.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数：使选中的怪兽攻击力和守备力上升300
function c53152590.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 给目标怪兽增加300攻击力
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
