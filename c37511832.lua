--サルガッソの灯台
-- 效果：
-- 给与自己伤害的魔法卡的效果发动时才能发动。那个效果让自己受到的效果伤害变成0。此外，只要这张卡在墓地存在，「异次元的古战场-死域海」的效果让自己受到的效果伤害变成0。盖放的这张卡被送去墓地时，可以从卡组把1张「异次元的古战场-死域海」加入手卡。
function c37511832.initial_effect(c)
	-- 给与自己伤害的魔法卡的效果发动时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c37511832.condition)
	e1:SetOperation(c37511832.operation)
	c:RegisterEffect(e1)
	-- 只要这张卡在墓地存在，「异次元的古战场-死域海」的效果让自己受到的效果伤害变成0。
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
-- 检查连锁效果是否为魔法卡发动且对玩家造成伤害
function c37511832.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查连锁效果是否为魔法卡发动且对玩家造成伤害
	return re:IsActiveType(TYPE_SPELL) and aux.damcon1(e,tp,eg,ep,ev,re,r,rp)
end
-- 创建一个影响伤害数值的效果，用于将特定连锁的伤害归零
function c37511832.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的唯一标识ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	-- 注册一个影响伤害数值的效果，使其在特定连锁时将伤害设为0
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetLabel(cid)
	e1:SetValue(c37511832.damcon)
	e1:SetReset(RESET_CHAIN)
	-- 将效果注册到玩家的全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 判断当前连锁是否为目标连锁，若是则将伤害设为0，否则保持原值
function c37511832.damcon(e,re,val,r,rp,rc)
	-- 获取当前正在处理的连锁序号
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return val end
	-- 获取当前连锁的唯一标识ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cid==e:GetLabel() then return 0 else return val end
end
-- 确认该卡是从场上盖放状态被送去墓地
function c37511832.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsPreviousPosition(POS_FACEDOWN)
end
-- 过滤函数，用于检索卡组中编号为1127737的卡
function c37511832.filter(c)
	return c:IsCode(1127737) and c:IsAbleToHand()
end
-- 设置检索卡组中编号为1127737的卡并加入手牌的操作信息
function c37511832.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在编号为1127737的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c37511832.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索并加入手牌的操作
function c37511832.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组中检索编号为1127737的卡
	local tc=Duel.GetFirstMatchingCard(c37511832.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 确认对手查看该卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
