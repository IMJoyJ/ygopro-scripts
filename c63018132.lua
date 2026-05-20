--ドラゴン・ライダー
-- 效果：
-- 反转：在回合结束前得到对方场上的1只表侧表示存在的龙族怪兽。
function c63018132.initial_effect(c)
	-- 反转：在回合结束前得到对方场上的1只表侧表示存在的龙族怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63018132,0))  --"获得控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c63018132.target)
	e1:SetOperation(c63018132.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示、龙族且可以改变控制权的怪兽
function c63018132.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAbleToChangeControler()
end
-- 效果发动的目标选择，选择对方场上1只符合条件的怪兽作为对象
function c63018132.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c63018132.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家发送选择改变控制权怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只符合过滤条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c63018132.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为改变1个对象的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理的执行，在效果处理时获得作为对象的怪兽的控制权
function c63018132.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 让当前玩家获得目标怪兽的控制权，直到回合结束
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
