--ギャンブル
-- 效果：
-- 对方的手卡6张以上，自己的手卡2张以下的时候才可以发动。猜硬币的正反。
-- ●猜中：自己的手卡抽到5张。
-- ●猜不中：跳过下次的自己的整个回合。
function c37313786.initial_effect(c)
	-- 对方的手卡6张以上，自己的手卡2张以下的时候才可以发动。猜硬币的正反。●猜中：自己的手卡抽到5张。●猜不中：跳过下次的自己的整个回合。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COIN+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c37313786.condition)
	e1:SetTarget(c37313786.target)
	e1:SetOperation(c37313786.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判断函数：确认我方手牌数在2张以下且对方手牌数在6张以上时，该卡才能发动。
function c37313786.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件判定：tp方自己的手牌数≤2，且以tp来看的对方手牌数≥6。
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<=2 and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>=6
end
-- 发动时点处理函数：该效果无需对象即可正常发动；在chk==0时返回true表示发动合法，并设置硬币效果的操作信息。
function c37313786.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁的操作信息：类别为硬币效果，由tp进行1次硬币判定，供后续硬币相关检测使用。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 效果处理流程：提示tp选择硬币正反面，然后实际投1枚硬币；若宣言与投掷结果相符（因正反数值相反，代码用coin~=res判定为猜中），则补抽手牌至5张；否则给tp附加跳过下次自己整个回合的效果。
function c37313786.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示“请选择硬币的正反面”，并让tp进行硬币正反宣言的选择缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 让tp宣言硬币的正反面（正面为0，反面为1），返回值存入coin。
	local coin=Duel.AnnounceCoin(tp)
	-- 让tp投掷1枚硬币，获得实际结果res（正面为1，反面为0）。
	local res=Duel.TossCoin(tp,1)
	if coin~=res then
		-- 获取tp当前手牌数量，用于计算需要补抽的差值。
		local gc=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		-- 以效果原因让tp抽取(5-当前手牌数)张卡，使手牌补齐到5张。
		Duel.Draw(tp,5-gc,REASON_EFFECT)
	else
		-- 猜不中：为tp创建“跳过整个回合”的场地效果，并设置合适的重置时机，使tp跳过下次自己的整个回合。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetCode(EFFECT_SKIP_TURN)
		-- 判断当前回合玩家是否为tp，以决定跳过效果的持续时长：当前为tp回合时重置计数为2，否则为1。
		if Duel.GetTurnPlayer()==tp then
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
		end
		-- 将该跳过回合效果注册给tp玩家，使tp受到跳过回合的影响。
		Duel.RegisterEffect(e1,tp)
	end
end
