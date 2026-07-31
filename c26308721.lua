--捕食植物プテロペンテス
-- 效果：
-- ①：这张卡给与对方战斗伤害时，以对方场上1只表侧表示怪兽为对象才能发动。给那只怪兽放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
-- ②：1回合1次，以持有这张卡的等级以下的等级的对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
function c26308721.initial_effect(c)
	-- ①：这张卡给与对方战斗伤害时，以对方场上1只表侧表示怪兽为对象才能发动。给那只怪兽放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26308721,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c26308721.ctcon1)
	e1:SetTarget(c26308721.cttg1)
	e1:SetOperation(c26308721.ctop1)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以持有这张卡的等级以下的等级的对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26308721,1))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c26308721.cttg2)
	e2:SetOperation(c26308721.ctop2)
	c:RegisterEffect(e2)
end
c26308721.mentioned_counter={
	[0x1041]=true,
}
-- 判断造成战斗伤害的玩家是否为对手（即是否为对方玩家）
function c26308721.ctcon1(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 设置效果目标选择函数，用于选择对方场上的表侧表示且能放置捕食指示物的怪兽
function c26308721.cttg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsCanAddCounter(0x1041,1) end
	-- 检查是否存在满足条件的目标怪兽（即对方场上可放置捕食指示物的怪兽）
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x1041,1) end
	-- 向玩家提示“请选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一个满足条件的对方场上的表侧表示怪兽作为目标
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x1041,1)
end
-- 处理效果发动后的操作，包括给目标怪兽放置捕食指示物，并在符合条件时改变其等级
function c26308721.ctop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:AddCounter(0x1041,1) and tc:GetLevel()>1 then
		-- 有捕食指示物放置的2星以上的怪兽的等级变成1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c26308721.lvcon)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
-- 判断目标怪兽是否拥有捕食指示物（用于触发等级变更效果）
function c26308721.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
-- 筛选符合条件的目标怪兽（必须为表侧表示、等级不超过本卡等级且可以改变控制权）
function c26308721.ctfilter2(c,mc)
	return c:IsFaceup() and c:IsLevelBelow(mc:GetLevel()) and c:IsControlerCanBeChanged()
end
-- 设置第二个效果的目标选择函数，用于选择对方场上满足条件的怪兽
function c26308721.cttg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c26308721.ctfilter2(chkc,c) end
	-- 检查是否存在满足条件的目标怪兽（即对方场上有等级不超过本卡等级且可改变控制权的怪兽）
	if chk==0 then return Duel.IsExistingTarget(c26308721.ctfilter2,tp,0,LOCATION_MZONE,1,nil,c) end
	-- 向玩家提示“请选择要改变控制权的怪兽”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择一个满足条件的对方场上的怪兽作为目标
	local g=Duel.SelectTarget(tp,c26308721.ctfilter2,tp,0,LOCATION_MZONE,1,1,nil,c)
	-- 设置当前连锁的操作信息，表明将要改变目标怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 处理第二个效果发动后的操作，即获得目标怪兽的控制权直到结束阶段
function c26308721.ctop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 让玩家获得目标怪兽的控制权直到结束阶段
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
