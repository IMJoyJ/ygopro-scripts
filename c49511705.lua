--銃砲撃
-- 效果：
-- ①：1回合1次，进行投掷硬币的效果发动的场合，那个效果让表出现次数的以下效果适用。
-- ●1次以上：给与对方500伤害。
-- ●2次以上：选对方场上1张卡破坏。
-- ●3次以上：把对方手卡确认，从那之中选1张卡丢弃。
-- ②：进行投掷硬币2次以上的效果发动时，把墓地的这张卡除外才能发动。那些投掷硬币的结果全部当作表出现的状态使用。
function c49511705.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：进行投掷硬币2次以上的效果发动时，把墓地的这张卡除外才能发动。那些投掷硬币的结果全部当作表出现的状态使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c49511705.regcon)
	e2:SetOperation(c49511705.regop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，进行投掷硬币的效果发动的场合，那个效果让表出现次数的以下效果适用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(49511705,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(c49511705.coincon1)
	-- 将此卡从墓地除外作为费用
	e3:SetCost(aux.bfgcost)
	e3:SetOperation(c49511705.coinop1)
	c:RegisterEffect(e3)
end
-- 判断连锁效果是否为投掷硬币效果
function c49511705.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果是否包含投掷硬币的提示信息
	local ex=Duel.GetOperationInfo(ev,CATEGORY_COIN)
	return ex
end
-- 注册一个在投掷硬币时触发的效果，用于处理铳炮击的效果
function c49511705.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 当投掷硬币时触发的效果，根据投掷次数执行对应效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TOSS_COIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c49511705.effcon)
	e1:SetOperation(c49511705.effop)
	e1:SetLabelObject(re)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN)
	c:RegisterEffect(e1)
end
-- 判断当前投掷硬币效果是否为之前记录的连锁效果
function c49511705.effcon(e,tp,eg,ep,ev,re,r,rp)
	return re==e:GetLabelObject()
end
-- 根据投掷结果执行对应效果：1次以上造成500伤害，2次以上破坏对方场上一张卡，3次以上确认对方手牌并丢弃一张
function c49511705.effop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家此卡发动
	Duel.Hint(HINT_CARD,0,49511705)
	local ct=0
	-- 获取当前投掷硬币的结果数组
	local res={Duel.GetCoinResult()}
	for i=1,ev do
		if res[i]==1 then
			ct=ct+1
		end
	end
	if ct>0 then
		-- 给对方造成500点伤害
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
	if ct>1 then
		-- 提示选择要破坏的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上的一张卡作为破坏目标
		local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 显示所选卡片被破坏的动画效果
			Duel.HintSelection(g)
			-- 将所选卡片从游戏中破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
	if ct>2 then
		-- 获取对方手牌组
		local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if hg:GetCount()>0 then
			-- 确认对方手牌内容
			Duel.ConfirmCards(tp,hg)
			-- 提示选择要丢弃的手牌
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
			local sg=hg:Select(tp,1,1,nil)
			-- 将所选手牌送入墓地并标记为丢弃
			Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
			-- 洗切对方手牌
			Duel.ShuffleHand(1-tp)
		end
	end
end
-- 判断是否为投掷硬币且次数大于1的效果
function c49511705.coincon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的投掷硬币信息
	local ex,eg,et,cp,ct=Duel.GetOperationInfo(ev,CATEGORY_COIN)
	if ex and ct>1 then
		e:SetLabelObject(re)
		return true
	else return false end
end
-- 注册一个在投掷硬币时触发的效果，用于修改投掷结果
function c49511705.coinop1(e,tp,eg,ep,ev,re,r,rp)
	-- 将修改后的投掷结果应用到游戏环境中
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TOSS_COIN_NEGATE)
	e1:SetCountLimit(1)
	e1:SetCondition(c49511705.coincon2)
	e1:SetOperation(c49511705.coinop2)
	e1:SetLabelObject(e:GetLabelObject())
	e1:SetReset(RESET_CHAIN)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 判断当前投掷硬币效果是否为之前记录的连锁效果
function c49511705.coincon2(e,tp,eg,ep,ev,re,r,rp)
	return re==e:GetLabelObject()
end
-- 将所有投掷结果设为正面（1）
function c49511705.coinop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家此卡发动
	Duel.Hint(HINT_CARD,0,49511705)
	-- 获取当前投掷硬币的结果数组
	local res={Duel.GetCoinResult()}
	local ct=ev
	for i=1,ct do
		res[i]=1
	end
	-- 设置投掷结果为全为正面
	Duel.SetCoinResult(table.unpack(res))
end
