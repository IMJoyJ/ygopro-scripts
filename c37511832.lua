--サルガッソの灯台
-- 效果：
-- 给与自己伤害的魔法卡的效果发动时才能发动。那个效果让自己受到的效果伤害变成0。此外，只要这张卡在墓地存在，「异次元的古战场-死域海」的效果让自己受到的效果伤害变成0。盖放的这张卡被送去墓地时，可以从卡组把1张「异次元的古战场-死域海」加入手卡。
function c37511832.initial_effect(c)
	-- 给与自己伤害的魔法卡的效果发动时才能发动。那个效果让自己受到的效果伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c37511832.condition)
	e1:SetOperation(c37511832.operation)
	c:RegisterEffect(e1)
	-- 此外，只要这张卡在墓地存在，「异次元的古战场-死域海」的效果让自己受到的效果伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(37511832)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
	-- 盖放的这张卡被送去墓地时，可以从卡组把1张「异次元的古战场-死域海」加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37511832,0))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c37511832.thcon)
	e3:SetTarget(c37511832.thtg)
	e3:SetOperation(c37511832.thop)
	c:RegisterEffect(e3)
end
-- 定义发动条件：被连锁的效果必须是魔法卡效果，且该效果会给己方玩家造成效果伤害（或对应恢复的反转情况），满足时才可发动。
function c37511832.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断被连锁的效果为魔法卡类型，且根据aux.damcon1检测该效果会对己方造成效果伤害（或恢复反转），两个条件同时满足则返回true。
	return re:IsActiveType(TYPE_SPELL) and aux.damcon1(e,tp,eg,ep,ev,re,r,rp)
end
-- 效果处理：获取被连锁效果的连锁ID，创建一个改变伤害数值的场上效果，只影响己方，记录该连锁ID，并设置回调；在连锁处理中若伤害来自同一个连锁ID则改为0，连锁结束后该效果重置。
function c37511832.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得被连锁的效果所在连锁的连锁ID，用于标识是哪一个效果发动的伤害。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	-- 那个效果让自己受到的效果伤害变成0。盖放的这张卡被送去墓地时，可以从卡组把1张「异次元的古战场-死域海」加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetLabel(cid)
	e1:SetValue(c37511832.damcon)
	e1:SetReset(RESET_CHAIN)
	-- 将新生成的伤害变换效果注册到场上，对当前玩家tp生效，使其在当前连锁中实际发挥作用。
	Duel.RegisterEffect(e1,tp)
end
-- 伤害值计算回调：若不在连锁处理中，或伤害原因不是效果伤害，则保持原值；若当前连锁ID与记录的连锁ID相等，则将伤害变为0，否则保持原值。
function c37511832.damcon(e,re,val,r,rp,rc)
	-- 获取当前正在处理的连锁序号，用于判断当前是否正处于连锁处理阶段。
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return val end
	-- 获取当前正在处理的连锁的连锁ID，用于与之前记录的连锁ID进行比对。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cid==e:GetLabel() then return 0 else return val end
end
-- 检索效果发动条件：此卡在被送去墓地前位于场上且为里侧表示，即里侧盖放的此卡被送去墓地时才满足发动条件。
function c37511832.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsPreviousPosition(POS_FACEDOWN)
end
-- 检索过滤器：卡片卡号为1127737（「异次元的古战场-死域海」），并且能够加入手卡。
function c37511832.filter(c)
	return c:IsCode(1127737) and c:IsAbleToHand()
end
-- 检索效果的发动目标判定：在检查模式chk==0时，确认卡组中有符合条件的卡；随后设置操作信息，处理时从卡组把1张卡加入手卡。
function c37511832.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查时，若己方卡组中不存在至少1张满足filter条件的卡，则不能发动该检索效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c37511832.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：预定从卡组将1张卡加入手卡，供后续效果处理及相关连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果处理：从卡组找到符合条件的「异次元的古战场-死域海」，将其加入持有者手卡，并向对手展示该卡。
function c37511832.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 从己方卡组中取回第一张满足filter条件的卡；若没有则为nil，后续再判断。
	local tc=Duel.GetFirstMatchingCard(c37511832.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将检索到的卡以效果原因送入其持有者的手卡，即加入手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 将检索到的卡片展示给对方玩家确认，保证检索信息公开。
		Duel.ConfirmCards(1-tp,tc)
	end
end
