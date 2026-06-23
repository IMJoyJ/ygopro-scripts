--幻木龍
-- 效果：
-- 1回合1次，选择自己场上1只龙族·水属性怪兽才能发动。这张卡的等级变成和选择的怪兽的等级相同。
function c50457953.initial_effect(c)
	-- 创建一个永续效果，用于发动幻木龙的等级变化效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50457953,0))  --"等级变化"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c50457953.lvtg)
	e1:SetOperation(c50457953.lvop)
	c:RegisterEffect(e1)
end
-- 筛选满足条件的怪兽（表侧表示、等级不等于目标等级、等级大于等于1、水属性、龙族）
function c50457953.lvfilter(c,lv)
	return c:IsFaceup() and not c:IsLevel(lv) and c:IsLevelAbove(1) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_DRAGON)
end
-- 设置效果的目标选择函数，用于选择符合条件的怪兽
function c50457953.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c50457953.lvfilter(chkc,e:GetHandler():GetLevel()) end
	-- 判断是否满足发动条件，即场上是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c50457953.lvfilter,tp,LOCATION_MZONE,0,1,nil,e:GetHandler():GetLevel()) end
	-- 提示玩家选择一张表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c50457953.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,e:GetHandler():GetLevel())
end
-- 设置效果的处理函数，用于执行等级变化操作
function c50457953.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将幻木龙的等级修改为与目标怪兽相同
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
