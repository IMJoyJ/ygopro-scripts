--ダークシー・フロート
-- 效果：
-- 场上存在的这张卡被卡的效果破坏送去墓地时，从自己卡组抽1张卡。
function c70054514.initial_effect(c)
	-- 场上存在的这张卡被卡的效果破坏送去墓地时，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70054514,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(c70054514.drcon)
	e1:SetTarget(c70054514.drtg)
	e1:SetOperation(c70054514.drop)
	c:RegisterEffect(e1)
end
-- 判断这张卡是否是在场上被卡的效果破坏并送去墓地
function c70054514.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 设置抽卡效果的发动目标（玩家与抽卡数量）及操作信息
function c70054514.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的对象玩家设置为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 将效果的对象参数设置为1（抽卡张数）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为抽卡分类，数量为1张，操作玩家为当前玩家
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果的具体处理
function c70054514.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和对象参数（抽卡张数）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因卡的效果从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
