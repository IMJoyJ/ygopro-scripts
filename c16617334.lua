--EMレインゴート
-- 效果：
-- ①：给与自己伤害的魔法·陷阱·怪兽的效果发动时，把这张卡从手卡丢弃才能发动。那个效果让自己受到的伤害变成0。
-- ②：自己·对方的主要阶段把这张卡从手卡丢弃，以自己场上1张「娱乐伙伴」卡或者「异色眼」卡为对象才能发动。这个回合，那张卡不会被战斗·效果破坏。
function c16617334.initial_effect(c)
	-- ①：给与自己伤害的魔法·陷阱·怪兽的效果发动时，把这张卡从手卡丢弃才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16617334,0))  --"伤害变成0"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	-- 设置①效果的发动条件，使用通用函数判定当前连锁的魔法·陷阱·怪兽效果将会给与自己伤害
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
-- 检查手卡中的自身是否能够作为代价丢弃，并在支付代价时将其丢弃送去墓地
function c16617334.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 把作为效果发动源的这张卡从手卡以代价和丢弃的原因送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 执行①效果处理：获取触发连锁的唯一标识，为自己注册一个持续到连锁结束、将对应连锁造成的效果伤害变为0的场上效果
function c16617334.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所连锁的给与伤害效果的唯一连锁ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	-- 那个效果让自己受到的伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetLabel(cid)
	e1:SetValue(c16617334.damcon)
	e1:SetReset(RESET_CHAIN)
	-- 为自己全局注册修改效果伤害数值的效果
	Duel.RegisterEffect(e1,tp)
end
-- 计算效果伤害变更值：若当前处于连锁处理中且伤害原因为效果伤害，则对比当前连锁ID是否与记录的目标连锁ID一致，一致时将伤害改为0，否则维持原伤害值
function c16617334.damcon(e,re,val,r,rp,rc)
	-- 获取当前正在处理的连锁序号
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return end
	-- 获取当前正在处理的连锁的唯一ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cid==e:GetLabel() then return 0 end
	return val
end
-- 检查②效果的发动条件：当前是否处于自己或对方的主要阶段1或主要阶段2
function c16617334.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前决斗阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤场上的卡片：须为表侧表示且属于「娱乐伙伴」或「异色眼」字段
function c16617334.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f,0x99)
end
-- ②效果的取对象处理：检查自己场上是否存在符合条件的表侧表示卡片，并让玩家选择其中1张作为效果对象
function c16617334.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() and c16617334.filter(chkc) end
	-- 检查自己场上是否存在至少1张可成为对象的表侧表示「娱乐伙伴」或「异色眼」卡
	if chk==0 then return Duel.IsExistingTarget(c16617334.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 向发动玩家发送选择表侧表示卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让发动玩家从自己场上选择1张表侧表示「娱乐伙伴」或「异色眼」卡作为本次连锁的对象
	Duel.SelectTarget(tp,c16617334.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
end
-- 执行②效果处理：若对象卡仍与效果关联且为表侧表示，则为其附加持续到回合结束为止不会被战斗破坏和不会被效果破坏的永续效果
function c16617334.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的场上对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，那张卡不会被战斗·效果破坏。
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
