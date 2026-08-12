--ギャンブル
-- 效果：
-- 对方的手卡6张以上，自己的手卡2张以下的时候才可以发动。猜硬币的正反。
-- ●猜中：自己的手卡抽到5张。
-- ●猜不中：跳过下次的自己的整个回合。
function c37313786.initial_effect(c)
	-- 效果发动条件：对方的手卡6张以上，自己的手卡2张以下时才能发动
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COIN+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c37313786.condition)
	e1:SetTarget(c37313786.target)
	e1:SetOperation(c37313786.activate)
	c:RegisterEffect(e1)
end
-- 判断是否满足发动条件，即自己的手卡不超过2张且对方手卡不少于6张
function c37313786.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前玩家手卡数量不超过2张且对方手卡数量不少于6张
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<=2 and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>=6
end
-- 设置连锁处理时的操作信息，包括硬币效果和抽卡效果
function c37313786.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为硬币效果，目标玩家为当前玩家
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 效果处理函数，执行猜硬币并根据结果执行抽卡或跳过回合
function c37313786.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择硬币正反面
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 让玩家宣言硬币正反面
	local coin=Duel.AnnounceCoin(tp)
	-- 投掷1次硬币并获取结果
	local res=Duel.TossCoin(tp,1)
	if coin~=res then
		-- 获取当前玩家手卡数量
		local gc=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		-- 根据手卡数量抽卡，确保总共抽到5张
		Duel.Draw(tp,5-gc,REASON_EFFECT)
	else
		-- 创建跳过回合效果并注册给当前玩家
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetCode(EFFECT_SKIP_TURN)
		-- 如果当前回合玩家是自己，则跳过2个回合
		if Duel.GetTurnPlayer()==tp then
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
		end
		-- 将跳过回合效果注册给当前玩家
		Duel.RegisterEffect(e1,tp)
	end
end
