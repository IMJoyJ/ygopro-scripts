--ヒール・ウェーバー
-- 效果：
-- 选择这张卡以外的自己场上表侧表示存在的1只怪兽发动。回复选择怪兽的等级×100的数值的基本分。这个效果1回合只能使用1次。
function c31281980.initial_effect(c)
	-- 创建效果，设置效果描述为“LP回复”，分类为回复效果，类型为起动效果，生效位置为主怪兽区，限制一回合只能使用1次，效果为取对象效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31281980,0))  --"LP回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c31281980.rectg)
	e1:SetOperation(c31281980.recop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选表侧表示且等级大于0的怪兽
function c31281980.filter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 效果处理时的处理函数，用于选择目标怪兽并设置操作信息
function c31281980.rectg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c31281980.filter(chkc) end
	-- 判断是否满足选择目标的条件，即自己场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c31281980.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向玩家提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c31281980.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置操作信息，确定回复的LP值为所选怪兽等级乘以100
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetLevel()*100)
end
-- 效果发动后的处理函数，用于执行回复LP的操作
function c31281980.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使玩家回复所选怪兽等级乘以100的LP值
		Duel.Recover(tp,tc:GetLevel()*100,REASON_EFFECT)
	end
end
