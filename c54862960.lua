--鏡の御巫ニニ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡没有装备卡装备的场合，这张卡的战斗发生的对自己的战斗伤害变成0，有装备的场合，这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害由对方代受。
-- ②：对方回合，这张卡有装备卡装备的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
function c54862960.initial_effect(c)
	-- ①：这张卡没有装备卡装备的场合，这张卡的战斗发生的对自己的战斗伤害变成0
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c54862960.ndcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 有装备的场合，这张卡不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	e2:SetCondition(c54862960.indcon)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	c:RegisterEffect(e3)
	-- ②：对方回合，这张卡有装备卡装备的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e4:SetCountLimit(1,54862960)
	e4:SetCondition(c54862960.ctcon)
	e4:SetTarget(c54862960.cttg)
	e4:SetOperation(c54862960.ctop)
	c:RegisterEffect(e4)
end
-- 判断自身没有装备卡装备的条件函数
function c54862960.ndcon(e)
	return e:GetHandler():GetEquipCount()==0
end
-- 判断自身有装备卡装备的条件函数
function c54862960.indcon(e)
	return e:GetHandler():GetEquipCount()>0
end
-- 控制权转移效果的发动条件函数
function c54862960.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自身是否有装备卡装备，且当前是否为对方回合
	return e:GetHandler():GetEquipCount()>0 and Duel.GetTurnPlayer()==1-tp
end
-- 过滤对方场上表侧表示且可以改变控制权的怪兽
function c54862960.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
-- 控制权转移效果的发动目标选择与检测函数
function c54862960.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c54862960.filter(chkc) end
	-- 在效果发动时，检测对方场上是否存在至少1只满足条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c54862960.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给发动效果的玩家发送提示信息，提示选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只表侧表示怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c54862960.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息，表示该效果的处理为夺取所选怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 控制权转移效果的处理函数
function c54862960.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 让发动效果的玩家直到结束阶段得到目标怪兽的控制权
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
