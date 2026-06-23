--閃刀姫－カイナ
-- 效果：
-- 地属性以外的「闪刀姬」怪兽1只
-- 自己对「闪刀姬-魁奈」1回合只能有1次特殊召唤。
-- ①：这张卡特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽直到对方回合结束时不能攻击。
-- ②：只要这张卡在怪兽区域存在，每次自己把「闪刀」魔法卡的效果发动，自己回复100基本分。
function c12421694.initial_effect(c)
	c:SetSPSummonOnce(12421694)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用1到1个满足过滤条件的连接素材
	aux.AddLinkProcedure(c,c12421694.matfilter,1,1)
	-- ①：这张卡特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽直到对方回合结束时不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12421694,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c12421694.atktg)
	e1:SetOperation(c12421694.atkop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，每次自己把「闪刀」魔法卡的效果发动，自己回复100基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	-- 记录连锁发生时这张卡在场上存在
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- 当连锁处理结束时，如果满足条件则触发效果
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c12421694.reccon)
	e3:SetOperation(c12421694.recop)
	c:RegisterEffect(e3)
end
-- 定义连接素材的过滤条件，要求是「闪刀姬」卡组且属性不是地属性
function c12421694.matfilter(c)
	return c:IsLinkSetCard(0x1115) and c:IsLinkAttribute(ATTRIBUTE_ALL&~ATTRIBUTE_EARTH)
end
-- 定义效果发动时选择目标的处理函数
function c12421694.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 判断是否满足选择目标的条件，检查对方场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择对方场上的一只表侧表示怪兽作为目标
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 定义效果发动时的处理函数
function c12421694.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 给目标怪兽添加不能攻击的效果，直到对方回合结束
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
	end
end
-- 定义连锁处理结束时的条件判断函数
function c12421694.reccon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsSetCard(0x115) and rp==tp and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0
end
-- 定义连锁处理结束时的处理函数
function c12421694.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 使玩家回复100基本分
	Duel.Recover(tp,100,REASON_EFFECT)
end
