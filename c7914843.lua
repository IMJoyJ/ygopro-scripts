--電磁ミノ虫
-- 效果：
-- ①：这张卡反转的场合，以对方场上1只机械族怪兽为对象发动。直到下次的自己结束阶段，得到那只机械族怪兽的控制权。
-- ②：这张卡被和怪兽的战斗破坏的场合发动。那只怪兽的攻击力·守备力下降500。
function c7914843.initial_effect(c)
	-- ①：这张卡反转的场合，以对方场上1只机械族怪兽为对象发动。直到下次的自己结束阶段，得到那只机械族怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7914843,0))  --"获得控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c7914843.target)
	e1:SetOperation(c7914843.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被和怪兽的战斗破坏的场合发动。那只怪兽的攻击力·守备力下降500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7914843,1))  --"攻守下降"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetOperation(c7914843.desop)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示、机械族且可以改变控制权的怪兽
function c7914843.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAbleToChangeControler()
end
-- 反转效果的发动准备，进行对象选择并设置操作信息
function c7914843.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c7914843.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只表侧表示的机械族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c7914843.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为改变1只怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 反转效果的处理，获取目标怪兽的控制权并计算持续时间
function c7914843.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsRace(RACE_MACHINE) then
		local tct=1
		-- 如果当前不是自己的回合，控制权转移效果将持续2个回合（直到下次自己的结束阶段）
		if Duel.GetTurnPlayer()~=tp then tct=2
		-- 如果当前是自己回合的结束阶段，控制权转移效果将持续3个回合（直到下次自己的结束阶段）
		elseif Duel.GetCurrentPhase()==PHASE_END then tct=3 end
		-- 让玩家获得目标怪兽的控制权，直到指定的结束阶段
		Duel.GetControl(tc,tp,PHASE_END,tct)
	end
end
-- 战斗破坏效果的处理，使战斗对手的攻击力和守备力下降500
function c7914843.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not bc:IsRelateToBattle() or bc:IsFacedown() then return end
	-- 那只怪兽的攻击力……下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(-500)
	bc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	bc:RegisterEffect(e2)
end
