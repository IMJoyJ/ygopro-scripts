--ヴェルズ・コッペリアル
-- 效果：
-- 这张卡不能特殊召唤。这张卡因对方从场上离开时，选择对方场上表侧表示存在的1只怪兽直到下次的自己的结束阶段时得到控制权。
function c77841719.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡因对方从场上离开时，选择对方场上表侧表示存在的1只怪兽直到下次的自己的结束阶段时得到控制权。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetDescription(aux.Stringid(77841719,0))  --"获得控制权"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c77841719.condition)
	e2:SetTarget(c77841719.target)
	e2:SetOperation(c77841719.operation)
	c:RegisterEffect(e2)
end
-- 判定此卡是否在自己场上因对方的操作而离场
function c77841719.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and rp==1-tp
end
-- 过滤对方场上表侧表示且可以转移控制权的怪兽
function c77841719.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
-- 效果发动的对象选择与操作信息设置
function c77841719.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c77841719.filter(chkc) end
	-- 检查对方场上是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c77841719.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只表侧表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c77841719.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：获取对象怪兽，并根据当前回合和阶段计算控制权转移持续到第几个结束阶段
function c77841719.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象怪兽
	local tc=Duel.GetFirstTarget()
	local tct=1
	-- 如果当前不是自己的回合，则控制权持续到第2个结束阶段（即下次自己的结束阶段）
	if Duel.GetTurnPlayer()~=tp then tct=2
	-- 如果当前是自己的结束阶段，则控制权持续到第3个结束阶段（即下次自己的结束阶段）
	elseif Duel.GetCurrentPhase()==PHASE_END then tct=3 end
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 让玩家获得该怪兽的控制权，直到指定的结束阶段
		Duel.GetControl(tc,tp,PHASE_END,tct)
	end
end
