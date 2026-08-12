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
-- 过滤条件：自己场上表侧表示、且未拥有增加攻击次数效果的「魔女术」怪兽
function c10805153.filter(c)
	return c:IsSetCard(0x128) and c:IsFaceup() and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 效果①的发动目标（确认是否可以进行战斗相关操作并选择表侧表示的「魔女术」怪兽作为效果的对象）
function c10805153.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc,exc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c10805153.filter(chkc) end
	-- 在进行合法性检测时，确认当前玩家是否能够进入战斗阶段或正处于战斗阶段中
	if chk==0 then return aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
		-- 在进行合法性检测时，确认自己场上是否存在满足过滤条件的「魔女术」怪兽
		and Duel.IsExistingTarget(c10805153.filter,tp,LOCATION_MZONE,0,1,exc) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上一只表侧表示的「魔女术」怪兽作为效果的对象
	Duel.SelectTarget(tp,c10805153.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的效果处理（赋予目标怪兽同一次战斗阶段可以作2次攻击以及攻击时封锁对方魔法·陷阱的效果）
function c10805153.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在效果发动时选择的目标「魔女术」怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
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
-- 限制对方玩家不能发动任何魔法或陷阱卡（包括卡片的发动和效果的发动）
function c10805153.aclimit(e,re,tp)
	return re:GetHandler():IsType(TYPE_SPELL+TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 攻击时封锁对方魔法·陷阱卡的触发判定条件
function c10805153.actcon(e)
	-- 检查当前攻击的怪兽是否为被赋予此效果的目标怪兽自身
	return Duel.GetAttacker()==e:GetHandler()
end
-- 过滤条件：自己场上表侧表示的「魔女术」怪兽
function c10805153.rccfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- 效果②的发动条件判断（自己回合的结束阶段，且场上有魔女术怪兽存在）
function c10805153.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的回合
	return Duel.GetTurnPlayer()==tp
		-- 检查自己场上是否存在至少1只表侧表示的「魔女术」怪兽
		and Duel.IsExistingMatchingCard(c10805153.rccfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果②的发动目标与合法性检测
function c10805153.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁处理信息：将自身加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理（将墓地的这张卡加入手牌）
function c10805153.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡回收加入到持有者的手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
