--ラインモンスター スピア・ホイール
-- 效果：
-- 1回合1次，选择这张卡以外的自己场上1只兽战士族·3星怪兽才能发动。选择的怪兽和这张卡变成各自等级合计的等级。
function c32476434.initial_effect(c)
	-- 创建1个永续效果，用于发动卡片效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32476434,0))  --"等级变化"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(c32476434.target)
	e1:SetOperation(c32476434.operation)
	c:RegisterEffect(e1)
end
-- 定义过滤函数，用于筛选表侧表示的3星兽战士族怪兽
function c32476434.filter(c)
	return c:IsFaceup() and c:IsLevel(3) and c:IsRace(RACE_BEASTWARRIOR)
end
-- 设置效果的目标选择函数，用于选择符合条件的怪兽
function c32476434.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c32476434.filter(chkc) and chkc~=e:GetHandler() end
	-- 判断是否满足发动条件，即场上是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c32476434.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择一张表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一张符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c32476434.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 设置效果的发动处理函数，用于改变怪兽等级
function c32476434.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local lv=c:GetLevel()+tc:GetLevel()
		-- 为选择的怪兽设置等级变化效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		tc:RegisterEffect(e2)
	end
end
