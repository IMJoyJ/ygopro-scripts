--一撃必殺侍
-- 效果：
-- ①：这张卡和对方怪兽进行战斗的伤害步骤开始时发动。进行1次投掷硬币，对里表作猜测。猜中的场合，那只对方怪兽破坏。
function c64538655.initial_effect(c)
	-- ①：这张卡和对方怪兽进行战斗的伤害步骤开始时发动。进行1次投掷硬币，对里表作猜测。猜中的场合，那只对方怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64538655,0))  --"战斗怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCondition(c64538655.descon)
	e1:SetTarget(c64538655.destg)
	e1:SetOperation(c64538655.desop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：存在进行战斗的对方怪兽
function c64538655.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击对象是否不为空（即确认是否与怪兽进行战斗）
	return Duel.GetAttackTarget()~=nil
end
-- 效果发动时的目标确认与操作信息设置
function c64538655.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表明该效果包含投掷1次硬币的操作
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 效果处理：玩家猜测硬币正反并投掷，若猜中则破坏对方怪兽
function c64538655.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前的攻击目标怪兽
	local tc=Duel.GetAttackTarget()
	-- 如果自身是被攻击方，则将对方怪兽（攻击方）作为效果处理对象
	if c==tc then tc=Duel.GetAttacker() end
	if not tc:IsRelateToBattle() then return end
	-- 向玩家发送提示信息，要求选择硬币的正反面
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 让玩家宣言硬币的正反面（进行猜测）
	local coin=Duel.AnnounceCoin(tp)
	-- 进行1次投掷硬币
	local res=Duel.TossCoin(tp,1)
	if coin~=res then
		-- 将那只对方怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
