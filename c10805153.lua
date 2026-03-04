--ウィッチクラフト・コラボレーション
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1只「魔女术」怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击，那只怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ②：这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合，自己结束阶段才能发动。这张卡加入手卡。
function c10805153.initial_effect(c)
	-- ①：以自己场上1只「魔女术」怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击，那只怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,10805153)
	e1:SetTarget(c10805153.target)
	e1:SetOperation(c10805153.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合，自己结束阶段才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10805153,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1,10805153)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c10805153.thcon)
	e2:SetTarget(c10805153.thtg)
	e2:SetOperation(c10805153.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选场上表侧表示的「魔女术」怪兽，且未拥有额外攻击效果
function c10805153.filter(c)
	return c:IsSetCard(0x128) and c:IsFaceup() and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 效果处理时的取对象函数，用于选择目标怪兽
function c10805153.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc,exc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 判断是否满足发动条件，包括是否处于战斗阶段
	if chk==0 then return aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
		-- 判断场上是否存在满足条件的「魔女术」怪兽作为目标
		and Duel.IsExistingTarget(c10805153.filter,tp,LOCATION_MZONE,0,1,exc) end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择满足条件的1只怪兽作为目标
	Duel.SelectTarget(tp,c10805153.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数，用于处理①效果的发动
function c10805153.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 为选中的怪兽添加额外攻击次数效果，使其在同1次战斗阶段中可攻击2次
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 为选中的怪兽添加战斗相关效果，使其攻击时对方不能发动魔法·陷阱卡
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetTargetRange(0,1)
		e2:SetValue(c10805153.aclimit)
		e2:SetCondition(c10805153.actcon)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 限制对方发动魔法·陷阱卡的过滤函数，仅对发动的魔法·陷阱卡生效
function c10805153.aclimit(e,re,tp)
	return re:GetHandler():IsType(TYPE_SPELL+TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 判断是否处于攻击状态的条件函数
function c10805153.actcon(e)
	-- 判断当前攻击的怪兽是否为该效果的持有者
	return Duel.GetAttacker()==e:GetHandler()
end
-- 过滤函数，用于筛选场上表侧表示的「魔女术」怪兽
function c10805153.rccfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- ②效果的发动条件函数，判断是否处于自己的结束阶段且己方场上存在「魔女术」怪兽
function c10805153.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果发动者
	return Duel.GetTurnPlayer()==tp
		-- 判断己方场上是否存在「魔女术」怪兽
		and Duel.IsExistingMatchingCard(c10805153.rccfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的处理函数，用于设置效果处理信息
function c10805153.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置效果处理信息，指定将该卡送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果的处理函数，用于执行将卡加入手牌的操作
function c10805153.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡以效果原因送入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
