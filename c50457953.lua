--幻木龍
-- 效果：
-- 1回合1次，选择自己场上1只龙族·水属性怪兽才能发动。这张卡的等级变成和选择的怪兽的等级相同。
function c50457953.initial_effect(c)
	-- 对应卡片效果原文：“1回合1次，选择自己场上1只龙族·水属性怪兽才能发动。这张卡的等级变成和选择的怪兽的等级相同。”
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
-- 定义可选怪兽的筛选条件：表侧表示、等级不是本卡当前等级、等级为1星以上、水属性、龙族怪兽。
function c50457953.lvfilter(c,lv)
	return c:IsFaceup() and not c:IsLevel(lv) and c:IsLevelAbove(1) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_DRAGON)
end
-- 目标选择处理：先判断被选对象是否合法，再确认发动时是否存在符合条件的对象，最后弹窗选择1只自己场上的龙族·水属性怪兽作为对象。
function c50457953.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c50457953.lvfilter(chkc,e:GetHandler():GetLevel()) end
	-- 发动时判定：检查自己场上是否存在至少1只满足条件的龙族·水属性怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c50457953.lvfilter,tp,LOCATION_MZONE,0,1,nil,e:GetHandler():GetLevel()) end
	-- 向玩家发出“请选择表侧表示的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只符合条件的表侧表示龙族·水属性怪兽，并将其设为效果对象。
	Duel.SelectTarget(tp,c50457953.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,e:GetHandler():GetLevel())
end
-- 效果处理：取得效果发动者与目标怪兽；若双方都仍与效果关联且表侧表示，则为发动者施加一个持续改变等级的效果，使其等级变成目标怪兽的当前等级。
function c50457953.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得本次效果发动时所选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 对应卡片效果原文：“这张卡的等级变成和选择的怪兽的等级相同。”
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
