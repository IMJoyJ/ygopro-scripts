--D-HERO ディフェンドガイ
-- 效果：
-- 对方回合的准备阶段时这张卡表侧守备表示存在的场合，对方玩家抽1张卡。
function c54749427.initial_effect(c)
	-- 对方回合的准备阶段时这张卡表侧守备表示存在的场合，对方玩家抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54749427,0))  --"对方抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c54749427.condition)
	e1:SetTarget(c54749427.target)
	e1:SetOperation(c54749427.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判定：在对方回合的准备阶段发动
function c54749427.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方玩家
	return tp~=Duel.GetTurnPlayer()
end
-- 效果发动时的目标选择与处理：确认自身处于守备表示，并设置对方玩家为效果对象
function c54749427.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDefensePos() end
	-- 设置当前连锁的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数为1（抽卡张数）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：对方玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
-- 效果处理：确认自身仍表侧守备表示存在，让对方玩家抽卡
function c54749427.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsPosition(POS_FACEUP_DEFENSE) then return end
	-- 获取当前连锁设定的对象玩家和参数（抽卡张数）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作，让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
