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
	-- 设置效果①的发动条件：当有会给与自己伤害的魔法·陷阱·怪兽效果发动时（aux.damcon1检测到该连锁包含对己方玩家的伤害效果）才能发动。
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
-- 效果发动代价函数：检查手牌中的此卡是否可丢弃（chk==0时只检查不支付），若可丢弃则将其送去墓地作为发动代价。
function c16617334.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡从手卡送去墓地，作为发动代价（丢弃），对应效果原文中的“把这张卡从手卡丢弃”。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 效果①处理：生成一个影响己方玩家的伤害变更效果，记录当前连锁ID，使同一连锁中对应的效果伤害变为0，连锁结束后该效果重置。
function c16617334.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发此效果的连锁的ID（ev为触发连锁序号），用于后续识别是哪一个伤害效果，避免误改其他伤害。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	-- ②：自己·对方的主要阶段把这张卡从手卡丢弃，以自己场上1张「娱乐伙伴」卡或者「异色眼」卡为对象才能发动。这个回合，那张卡不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetLabel(cid)
	e1:SetValue(c16617334.damcon)
	e1:SetReset(RESET_CHAIN)
	-- 将创建的伤害变更效果e1注册到场上，使它开始影响玩家tp的伤害结算，从而实现“那个效果让自己受到的伤害变成0”。
	Duel.RegisterEffect(e1,tp)
end
-- 伤害变更效果的值函数：若当前处于连锁处理中、伤害来源为效果，并且当前连锁ID与记录的连锁ID一致，则将伤害值改为0；否则返回原伤害值。
function c16617334.damcon(e,re,val,r,rp,rc)
	-- 获取当前正在处理的连锁序号，用于判断是否有连锁正在处理；若为0则说明不在效果处理中，不应修改伤害。
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return end
	-- 获取当前正在处理的连锁的ID，用于与效果中保存的连锁ID进行比较，确认当前伤害是否来自目标效果。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cid==e:GetLabel() then return 0 end
	return val
end
-- 效果②的发动条件函数：仅允许在自己或对方的主要阶段发动。
function c16617334.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2，满足任一即为主要阶段，允许发动效果②。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 对象过滤器：选择我方场上表侧表示且属于「娱乐伙伴」或「异色眼」字段的卡。
function c16617334.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f,0x99)
end
-- 效果②的取对象处理：检查对象合法性（若在连锁中指定则验证其是否为自己场上符合条件的表侧表示「娱乐伙伴」或「异色眼」卡），发动时确认存在可选的卡，然后提示玩家选择1张作为效果对象。
function c16617334.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() and c16617334.filter(chkc) end
	-- 发动时检查：自己场上是否存在至少1张符合条件的表侧表示卡，若不存在则效果②不能发动。
	if chk==0 then return Duel.IsExistingTarget(c16617334.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 向操作玩家显示选择提示，要求选择1张表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选出1张符合条件的表侧表示「娱乐伙伴」或「异色眼」卡，并将其登记为效果②的对象。
	Duel.SelectTarget(tp,c16617334.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
end
-- 效果②处理：取得对象卡，若对象仍与效果关联且表侧表示，则给它分别附加“不会被战斗破坏”和“不会被效果破坏”的效果，持续到这个回合结束。
function c16617334.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②发动时选择的对象卡（此效果只取1张对象，因此取第一张目标）。
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
