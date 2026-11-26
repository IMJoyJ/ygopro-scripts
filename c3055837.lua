--黒板消しの罠
-- 效果：
-- 给与战斗伤害以外伤害的效果发动时才能发动。使自己所受的效果伤害无效，对方从手卡中选择1张丢弃。
function c3055837.initial_effect(c)
	-- 给与战斗伤害以外伤害的效果发动时才能发动。使自己所受的效果伤害无效，对方从手卡中选择1张丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_HANDES_OPPO)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c3055837.condition)
	e1:SetTarget(c3055837.target)
	e1:SetOperation(c3055837.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：若为魔法·陷阱卡则必须是卡片的发动，且调用aux.damcon1确认该连锁会对己方造成效果伤害
function c3055837.condition(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 调用aux.damcon1检查当前触发的连锁是否会给己方造成效果伤害
	return aux.damcon1(e,tp,eg,ep,ev,re,r,rp)
end
-- 发动前确认对方至少有1张手卡，并登记使对方丢弃1张手卡的操作信息
function c3055837.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手卡数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 登记使对方丢弃1张手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,1)
end
-- 效果处理：让对方自选1张手卡丢弃，并注册临时效果将触发本次连锁的效果对己方造成的伤害变为0
function c3055837.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 让对方从自己手卡中选择1张卡以效果丢弃
	Duel.DiscardHand(1-tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	-- 获取引发此卡发动的伤害效果所在连锁的唯一连锁ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	-- 使自己所受的效果伤害无效，
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetLabel(cid)
	e1:SetValue(c3055837.refcon)
	e1:SetReset(RESET_CHAIN)
	-- 为己方玩家注册持续至本连锁结束的伤害数值修改效果
	Duel.RegisterEffect(e1,tp)
end
-- 伤害修改回调函数：当处于目标连锁ID的效果伤害处理时，将己方受到的伤害值改为0，其他情况维持原伤害val
function c3055837.refcon(e,re,val,r,rp,rc)
	-- 获取当前正在处理的连锁序号
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return end
	-- 获取当前正在处理的效果所属连锁的唯一连锁ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cid==e:GetLabel() then return 0
	else return val end
end
