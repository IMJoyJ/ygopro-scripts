--拡散する波動
-- 效果：
-- ①：对方场上有怪兽存在的场合，支付1000基本分，以自己场上1只7星以上的魔法师族怪兽为对象才能发动。这个回合，那只怪兽以外的怪兽不能攻击，作为对象的怪兽必须尽可能向对方怪兽全部各作1次攻击。那些攻击破坏的怪兽的效果不能发动并无效化。
function c87880531.initial_effect(c)
	-- ①：对方场上有怪兽存在的场合，支付1000基本分，以自己场上1只7星以上的魔法师族怪兽为对象才能发动。这个回合，那只怪兽以外的怪兽不能攻击，作为对象的怪兽必须尽可能向对方怪兽全部各作1次攻击。那些攻击破坏的怪兽的效果不能发动并无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c87880531.condition)
	e1:SetCost(c87880531.cost)
	e1:SetTarget(c87880531.target)
	e1:SetOperation(c87880531.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：检查对方场上是否存在怪兽
function c87880531.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方怪兽区域的卡片数量是否大于0
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 定义发动代价函数：检查并支付1000基本分
function c87880531.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果前，检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让玩家支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 定义过滤函数：选择自己场上表侧表示的7星以上的魔法师族怪兽
function c87880531.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(7)
end
-- 定义发动目标函数：检查并选择符合条件的对象怪兽
function c87880531.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c87880531.filter(chkc) end
	-- 检查当前回合玩家能否进入战斗阶段，且自己场上是否存在符合条件的对象
	if chk==0 then return Duel.IsAbleToEnterBP() and Duel.IsExistingTarget(c87880531.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上1只符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c87880531.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 定义效果处理函数：使目标怪兽获得必须攻击所有怪兽的效果，并限制其他怪兽攻击，且被破坏的怪兽效果无效化
function c87880531.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsControler(tp) and tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽以外的怪兽不能攻击
		local ae=Effect.CreateEffect(e:GetHandler())
		ae:SetType(EFFECT_TYPE_FIELD)
		ae:SetCode(EFFECT_CANNOT_ATTACK)
		ae:SetTargetRange(LOCATION_MZONE,0)
		ae:SetTarget(c87880531.ftarget)
		ae:SetLabel(tc:GetFieldID())
		ae:SetReset(RESET_PHASE+PHASE_END)
		-- 将“其他怪兽不能攻击”的限制效果注册给玩家
		Duel.RegisterEffect(ae,tp)
		-- 作为对象的怪兽必须尽可能向对方怪兽全部各作1次攻击
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_MUST_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 作为对象的怪兽必须尽可能向对方怪兽全部各作1次攻击
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_ATTACK_ALL)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
		-- 那些攻击破坏的怪兽的效果不能发动并无效化。
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_BATTLED)
		e4:SetOperation(c87880531.disop)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e4)
	end
end
-- 定义过滤函数：筛选出除目标怪兽以外的其他怪兽
function c87880531.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 定义效果处理函数：在伤害计算后，使被战斗破坏的怪兽效果不能发动且无效化
function c87880531.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not bc or not bc:IsStatus(STATUS_BATTLE_DESTROYED) then return end
	-- 那些攻击破坏的怪兽的效果不能发动并无效化。
	local e1=Effect.CreateEffect(e:GetOwner())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_TRIGGER)
	e1:SetReset(RESET_EVENT+0x17a0000)
	bc:RegisterEffect(e1,true)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE)
	bc:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_DISABLE_EFFECT)
	bc:RegisterEffect(e3)
end
