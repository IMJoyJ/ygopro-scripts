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
-- 效果发动的条件：造成战斗伤害的玩家不是自己
function c26308721.ctcon1(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 选择对象：对方场上1只可以放置捕食指示物的表侧表示怪兽
function c26308721.cttg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsCanAddCounter(0x1041,1) end
	-- 检查是否有满足条件的对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x1041,1) end
	-- 提示选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x1041,1)
end
-- 效果处理：给目标怪兽放置1个捕食指示物，若其等级高于1星则变为1星
function c26308721.ctop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:AddCounter(0x1041,1) and tc:GetLevel()>1 then
		-- 创建等级变更效果，使目标怪兽等级变为1星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c26308721.lvcon)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
-- 等级变更效果的发动条件：目标怪兽拥有捕食指示物
function c26308721.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
-- 筛选函数：选择对方场上表侧表示、等级不超过自身等级且可以改变控制权的怪兽
function c26308721.ctfilter2(c,mc)
	return c:IsFaceup() and c:IsLevelBelow(mc:GetLevel()) and c:IsControlerCanBeChanged()
end
-- 选择对象：对方场上1只满足条件的表侧表示怪兽
function c26308721.cttg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c26308721.ctfilter2(chkc,c) end
	-- 检查是否有满足条件的对象
	if chk==0 then return Duel.IsExistingTarget(c26308721.ctfilter2,tp,0,LOCATION_MZONE,1,nil,c) end
	-- 提示选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c26308721.ctfilter2,tp,0,LOCATION_MZONE,1,1,nil,c)
	-- 设置操作信息：将目标怪兽的控制权变更效果加入连锁
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：获得目标怪兽的控制权直到结束阶段
function c26308721.ctop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 获得目标怪兽的控制权直到结束阶段
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
