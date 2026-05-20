--フォトン・サテライト
-- 效果：
-- 1回合1次，选择这张卡以外的自己场上1只名字带有「光子」的怪兽才能发动。选择的怪兽和这张卡变成各自等级合计的等级。
function c63223260.initial_effect(c)
	-- 1回合1次，选择这张卡以外的自己场上1只名字带有「光子」的怪兽才能发动。选择的怪兽和这张卡变成各自等级合计的等级。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63223260,0))  --"等级变化"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(c63223260.target)
	e1:SetOperation(c63223260.operation)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示、等级1以上且卡名含有「光子」的怪兽
function c63223260.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x55) and c:IsLevelAbove(1)
end
-- 效果发动的对象选择与确认
function c63223260.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c63223260.filter(chkc) end
	-- 检查自己场上是否存在除这张卡以外、满足条件的「光子」怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c63223260.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 设置选择卡片时的提示信息为选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只除这张卡以外、表侧表示的「光子」怪兽作为效果对象
	Duel.SelectTarget(tp,c63223260.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 效果处理：将这张卡和选择的怪兽的等级变更为两者等级的合计值
function c63223260.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local lv=c:GetLevel()+tc:GetLevel()
		-- 选择的怪兽和这张卡变成各自等级合计的等级。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		tc:RegisterEffect(e2)
	end
end
