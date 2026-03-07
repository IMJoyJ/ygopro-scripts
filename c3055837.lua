--黒板消しの罠
-- 效果：
-- 给与战斗伤害以外伤害的效果发动时才能发动。使自己所受的效果伤害无效，对方从手卡中选择1张丢弃。
function c3055837.initial_effect(c)
	-- 效果发动时才能发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c3055837.condition)
	e1:SetTarget(c3055837.target)
	e1:SetOperation(c3055837.operation)
	c:RegisterEffect(e1)
end
-- 给与战斗伤害以外伤害的效果发动时才能发动
function c3055837.condition(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取连锁中是否包含伤害效果
	local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
	if ex then return true end
	-- 获取连锁中是否包含回复效果
	ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_RECOVER)
	if not ex then return false end
	-- 若对象玩家不为双方，则判断该玩家是否受到回复变伤害效果影响
	if cp~=PLAYER_ALL then return Duel.IsPlayerAffectedByEffect(cp,EFFECT_REVERSE_RECOVER)
	-- 若对象玩家为双方，则判断玩家0是否受到回复变伤害效果影响
	else return Duel.IsPlayerAffectedByEffect(0,EFFECT_REVERSE_RECOVER)
		-- 若对象玩家为双方，则判断玩家1是否受到回复变伤害效果影响
		or Duel.IsPlayerAffectedByEffect(1,EFFECT_REVERSE_RECOVER)
	end
end
-- 判断对方手牌数量是否大于0
function c3055837.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方手牌数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 设置连锁操作信息为对方丢弃1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
-- 使对方丢弃1张手牌，并注册一个改变伤害值的效果
function c3055837.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方丢弃1张手牌
	Duel.DiscardHand(1-tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	-- 获取当前连锁的唯一标识ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	-- 注册一个改变伤害值的效果，用于使本次连锁造成的伤害无效
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetLabel(cid)
	e1:SetValue(c3055837.refcon)
	e1:SetReset(RESET_CHAIN)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 判断当前连锁是否为本次效果触发的连锁，并返回0或原伤害值
function c3055837.refcon(e,re,val,r,rp,rc)
	-- 获取当前正在处理的连锁序号
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return end
	-- 获取当前连锁的唯一标识ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cid==e:GetLabel() then return 0
	else return val end
end
