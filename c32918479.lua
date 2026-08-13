--光神機－閃空
-- 效果：
-- 这张卡直接攻击给与对方基本分战斗伤害时，从自己卡组抽1张卡。这张卡在召唤·反转召唤·特殊召唤的回合的结束阶段时，这张卡送去墓地。
function c32918479.initial_effect(c)
	-- 这张卡直接攻击给与对方基本分战斗伤害时，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32918479,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c32918479.condition)
	e1:SetTarget(c32918479.target)
	e1:SetOperation(c32918479.operation)
	c:RegisterEffect(e1)
	-- 这张卡在召唤·反转召唤·特殊召唤的回合的结束阶段时，这张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c32918479.regop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 判定抽卡效果的发动条件：是否这张卡直接攻击给予对方战斗伤害（伤害玩家为对方且攻击目标为空）。
function c32918479.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确认受到战斗伤害的是对方玩家（ep≠tp）且本次攻击没有攻击对象（直接攻击）。
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 抽卡效果发动时登记目标：设定抽卡玩家为自己、抽1张卡，并登记抽卡类别操作信息。
function c32918479.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定当前连锁的对象玩家为这张卡的控制者，即抽卡玩家。
	Duel.SetTargetPlayer(tp)
	-- 设定当前连锁的对象参数为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 登记操作信息：将本次效果标记为抽卡效果，抽卡玩家为tp，抽卡数量为1（用于连锁时点检测）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,0,0,tp,1)
end
-- 抽卡效果的实际处理：读取连锁中记录的目标玩家和抽卡数，执行抽卡。
function c32918479.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的目标玩家和目标参数（抽卡数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让玩家p抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 当这张卡召唤/反转召唤/特殊召唤成功时，为这张卡注册一个结束阶段将自己送去墓地的诱发效果（不可被无效，仅当回合结束阶段发动一次）。
function c32918479.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡在召唤·反转召唤·特殊召唤的回合的结束阶段时，这张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32918479,1))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetTarget(c32918479.tgtg)
	e1:SetOperation(c32918479.tgop)
	e1:SetReset(RESET_EVENT+0xc6c0000)
	c:RegisterEffect(e1)
end
-- 送去墓地效果的目标处理：无特别条件，登记将这张卡自身送去墓地的操作信息。
function c32918479.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：将效果持有者（这张卡）自身作为送去墓地的对象（数量为1）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- 送去墓地效果的实际处理：若这张卡仍与效果关联且表侧表示，则将其送去墓地。
function c32918479.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 以效果原因将这张卡送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end
