--EMレインゴート
-- 效果：
-- ①：给与自己伤害的魔法·陷阱·怪兽的效果发动时，把这张卡从手卡丢弃才能发动。那个效果让自己受到的伤害变成0。
-- ②：自己·对方的主要阶段把这张卡从手卡丢弃，以自己场上1张「娱乐伙伴」卡或者「异色眼」卡为对象才能发动。这个回合，那张卡不会被战斗·效果破坏。
function c16617334.initial_effect(c)
	-- ①：给与自己伤害的魔法·陷阱·怪兽的效果发动时，把这张卡从手卡丢弃才能发动。那个效果让自己受到的伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16617334,0))  --"伤害变成0"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	-- 判断是否在伤害步骤或伤害计算时触发效果
	e1:SetCondition(aux.damcon1)
	e1:SetCost(c16617334.effcost)
	e1:SetOperation(c16617334.operation)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段把这张卡从手卡丢弃，以自己场上1张「娱乐伙伴」卡或者「异色眼」卡为对象才能发动。这个回合，那张卡不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16617334,1))  --"不会被破坏"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c16617334.condition2)
	e2:SetCost(c16617334.effcost)
	e2:SetTarget(c16617334.target2)
	e2:SetOperation(c16617334.operation2)
	c:RegisterEffect(e2)
end
-- 支付效果代价，将自身从手牌丢入墓地
function c16617334.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身从手牌丢入墓地作为效果的代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 创建一个影响伤害数值的效果，用于将特定连锁的伤害归零
function c16617334.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	-- 注册一个用于改变伤害数值的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetLabel(cid)
	e1:SetValue(c16617334.damcon)
	e1:SetReset(RESET_CHAIN)
	-- 将效果e1注册给玩家tp
	Duel.RegisterEffect(e1,tp)
end
-- 判断是否为当前连锁，并决定是否将伤害设为0
function c16617334.damcon(e,re,val,r,rp,rc)
	-- 获取当前正在处理的连锁序号
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return end
	-- 获取当前连锁的唯一标识ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cid==e:GetLabel() then return 0 end
	return val
end
-- 判断是否处于主要阶段1或主要阶段2
function c16617334.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为主要阶段1或主要阶段2时效果可用
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 筛选场上表侧表示的「娱乐伙伴」或「异色眼」卡
function c16617334.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f,0x99)
end
-- 选择目标卡，要求为场上表侧表示的「娱乐伙伴」或「异色眼」卡
function c16617334.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() and c16617334.filter(chkc) end
	-- 检查是否存在符合条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(c16617334.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择目标卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的场上一张卡作为效果对象
	Duel.SelectTarget(tp,c16617334.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
end
-- 使目标卡在本回合内不会被战斗或效果破坏
function c16617334.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 给目标卡添加不会被战斗破坏的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end
