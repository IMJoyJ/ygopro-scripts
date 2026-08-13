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
	-- ①：1回合1次，进行投掷硬币的效果发动的场合，那个效果让表出现次数的以下效果适用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c49511705.regcon)
	e2:SetOperation(c49511705.regop)
	c:RegisterEffect(e2)
	-- ②：进行投掷硬币2次以上的效果发动时，把墓地的这张卡除外才能发动。那些投掷硬币的结果全部当作表出现的状态使用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(49511705,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(c49511705.coincon1)
	-- 设置②效果发动时需将墓地的此卡除外作为COST（代价）。
	e3:SetCost(aux.bfgcost)
	e3:SetOperation(c49511705.coinop1)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件判定：当选场上有效果发动并且该效果的操作信息中包含投掷硬币分类（CATEGORY_COIN）时，允许本卡的监视效果启动，对应“1回合1次，进行投掷硬币的效果发动的场合”。
function c49511705.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的操作信息中是否包含投掷硬币分类（CATEGORY_COIN），用于判定是否为“进行投掷硬币的效果发动”。
	local ex=Duel.GetOperationInfo(ev,CATEGORY_COIN)
	return ex
end
-- 在硬币效果发动后，于本卡上注册一个对应此次硬币结果的延迟连续效果，监听后续的投硬币结果（EVENT_TOSS_COIN），并把发动时的效果re保存到标签，确保只处理本次效果；该效果在连锁处理结束或本卡离场等情况下重置。
function c49511705.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ①：1回合1次，进行投掷硬币的效果发动的场合，那个效果让表出现次数的以下效果适用。●1次以上：给与对方500伤害。●2次以上：选对方场上1张卡破坏。●3次以上：把对方手卡确认，从那之中选1张卡丢弃。
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
-- 判断当前产生的硬币结果是否来自被监视的那次投硬币效果（通过事件中的效果re与保存的标签比对），是才执行①的效果。
function c49511705.effcon(e,tp,eg,ep,ev,re,r,rp)
	return re==e:GetLabelObject()
end
-- 根据本次投硬币结果中“表”出现的次数，依次适用①效果：1次以上给500伤害；2次以上选对方场上1张卡破坏；3次以上确认对方手卡并丢弃1张。
function c49511705.effop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方展示“铳炮击”的卡片动画，作为效果处理的提示（通常用于不入连锁的效果处理）。
	Duel.Hint(HINT_CARD,0,49511705)
	local ct=0
	-- 获取本次投掷硬币的结果序列并存入表res，用于统计“表”出现的次数（通常1代表表，0代表里）。
	local res={Duel.GetCoinResult()}
	for i=1,ev do
		if res[i]==1 then
			ct=ct+1
		end
	end
	if ct>0 then
		-- 给与对方玩家（1-tp）500点效果伤害，对应“●1次以上：给与对方500伤害”。
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
	if ct>1 then
		-- 弹出手卡选择提示，提示当前玩家选择要破坏的卡（HINTMSG_DESTROY）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 令当前玩家从对方场上选择1张卡（任意条件）作为破坏对象，对应“选对方场上1张卡破坏”。
		local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 展示所选的卡并标记为对象（广义），用于向玩家显示选中动画。
			Duel.HintSelection(g)
			-- 以效果原因破坏所选择的对方卡片。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
	if ct>2 then
		-- 获取对方手牌的所有卡作为组hg，用于后续确认和选择丢弃。
		local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if hg:GetCount()>0 then
			-- 向当前玩家展示对方手牌，对应“把对方手卡确认”。
			Duel.ConfirmCards(tp,hg)
			-- 弹出手牌选择提示，提示当前玩家选择要丢弃的对方手牌（HINTMSG_DISCARD）。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
			local sg=hg:Select(tp,1,1,nil)
			-- 将被选中的那张手牌以效果原因并作为丢弃（REASON_DISCARD）送去墓地，对应“从那之中选1张卡丢弃”。
			Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
			-- 因为对方手牌被确认过，重新洗切对方手牌，避免手牌顺序信息泄露。
			Duel.ShuffleHand(1-tp)
		end
	end
end
-- 效果②的发动条件判定：当前连锁的效果操作信息中包含投掷硬币分类，且硬币投掷次数大于1（即“投掷硬币2次以上的效果发动时”），满足则保存该效果并允许②发动。
function c49511705.coincon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果关于投掷硬币的操作信息：ex表示是否存在该分类，ct表示投掷硬币的次数，用于判断是否满足“2次以上”的条件。
	local ex,eg,et,cp,ct=Duel.GetOperationInfo(ev,CATEGORY_COIN)
	if ex and ct>1 then
		e:SetLabelObject(re)
		return true
	else return false end
end
-- ②效果发动后，注册一个EVENT_TOSS_COIN_NEGATE的连续效果，用于在投硬币结果生成后强制把结果全部改为表；该效果只在本连锁内有效且一连锁只处理一次。
function c49511705.coinop1(e,tp,eg,ep,ev,re,r,rp)
	-- 那些投掷硬币的结果全部当作表出现的状态使用。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TOSS_COIN_NEGATE)
	e1:SetCountLimit(1)
	e1:SetCondition(c49511705.coincon2)
	e1:SetOperation(c49511705.coinop2)
	e1:SetLabelObject(e:GetLabelObject())
	e1:SetReset(RESET_CHAIN)
	-- 将上述用于修改硬币结果的效果e1注册到全场（属于玩家tp），使它在本次连锁中监视对应的投硬币结果并强制全表。
	Duel.RegisterEffect(e1,tp)
end
-- 判断当前投硬币事件是否来自②所对应的那个原发动效果（通过re与保存标签比较），是才修改结果。
function c49511705.coincon2(e,tp,eg,ep,ev,re,r,rp)
	return re==e:GetLabelObject()
end
-- 将本次投硬币的结果数组全部改为1（表），并通过Duel.SetCoinResult写入，从而实际把“所有结果当作表出现”。
function c49511705.coinop2(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方展示“铳炮击”的卡片动画，作为②效果生效处理的提示。
	Duel.Hint(HINT_CARD,0,49511705)
	-- 获取当前投硬币的结果数组，用于修改为全表。
	local res={Duel.GetCoinResult()}
	local ct=ev
	for i=1,ct do
		res[i]=1
	end
	-- 将修改后的全表结果数组写回游戏，使后续效果把此次投硬币结果全部视为表。
	Duel.SetCoinResult(table.unpack(res))
end
