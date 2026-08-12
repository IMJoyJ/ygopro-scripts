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
-- 发动条件：战斗伤害的承受方不是自己，即这张卡给与对方战斗伤害时才能发动
function c26308721.ctcon1(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 目标处理：从对方场上选择1只可以放置捕食指示物的表侧表示怪兽作为效果对象
function c26308721.cttg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsCanAddCounter(0x1041,1) end
	-- 发动可行性检测：对方场上需存在至少1只可以放置捕食指示物的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x1041,1) end
	-- 向玩家提示「请选择表侧表示的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 以对方场上1只可以放置捕食指示物的怪兽为对象
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x1041,1)
end
-- 效果处理：给对象怪兽放置1个捕食指示物，若该怪兽等级在2星以上，则对其赋予等级变成1星的永续效果
function c26308721.ctop1(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象卡
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
-- 等级变更效果的适用条件：该怪兽上放置有捕食指示物
function c26308721.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
-- 对象筛选条件：表侧表示、等级在这张卡的等级以下且可以改变控制权的怪兽
function c26308721.ctfilter2(c,mc)
	return c:IsFaceup() and c:IsLevelBelow(mc:GetLevel()) and c:IsControlerCanBeChanged()
end
-- 目标处理：从对方场上选择1只等级在这张卡以下且可改变控制权的表侧表示怪兽为对象，并设置控制权变更的操作信息
function c26308721.cttg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c26308721.ctfilter2(chkc,c) end
	-- 发动可行性检测：对方场上需存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c26308721.ctfilter2,tp,0,LOCATION_MZONE,1,nil,c) end
	-- 向玩家提示「请选择要改变控制权的怪兽」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 以对方场上1只满足条件的怪兽为对象
	local g=Duel.SelectTarget(tp,c26308721.ctfilter2,tp,0,LOCATION_MZONE,1,1,nil,c)
	-- 设置操作信息：效果分类为控制权变更，影响对象为所选的那1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：若对象怪兽仍与效果关联，则得到那只怪兽的控制权直到结束阶段
function c26308721.ctop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 得到对象怪兽的控制权，直到结束阶段为止（1次结束阶段后归还）
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
