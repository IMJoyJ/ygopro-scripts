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
-- 判断是否为直接攻击且对方玩家受到战斗伤害
function c32918479.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方玩家不是当前处理效果的玩家且攻击对象为空
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 设置抽卡效果的目标玩家和抽卡数量
function c32918479.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置操作信息为抽卡效果，目标玩家为当前玩家，抽卡数量为1
	Duel.SetOperationInfo(0,CATEGORY_DRAW,0,0,tp,1)
end
-- 执行抽卡操作
function c32918479.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 注册在召唤成功时触发的效果
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
-- 设置送去墓地效果的目标卡片
function c32918479.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为送去墓地效果，目标为当前卡片
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- 执行送去墓地操作
function c32918479.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将卡片送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end
