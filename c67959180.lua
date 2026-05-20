--きまぐれの女神
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。进行1次投掷硬币，对里表作猜测。猜中的场合，这张卡的攻击力直到回合结束时变成2倍。猜错的场合，这张卡的攻击力直到回合结束时变成一半。
function c67959180.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。进行1次投掷硬币，对里表作猜测。猜中的场合，这张卡的攻击力直到回合结束时变成2倍。猜错的场合，这张卡的攻击力直到回合结束时变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67959180,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c67959180.target)
	e1:SetOperation(c67959180.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的目标选择与操作信息设置
function c67959180.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为进行1次投掷硬币
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 效果处理的执行，进行硬币投掷并根据结果改变自身攻击力
function c67959180.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 提示玩家选择硬币的正反面
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
		-- 让玩家宣言硬币的正反面（进行猜测）
		local opt=Duel.AnnounceCoin(tp)
		-- 进行1次投掷硬币
		local coin=Duel.TossCoin(tp,1)
		-- 猜中的场合，这张卡的攻击力直到回合结束时变成2倍。猜错的场合，这张卡的攻击力直到回合结束时变成一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		if opt==coin then
			e1:SetValue(math.ceil(c:GetAttack()/2))
		else
			e1:SetValue(c:GetAttack()*2)
		end
		c:RegisterEffect(e1)
	end
end
