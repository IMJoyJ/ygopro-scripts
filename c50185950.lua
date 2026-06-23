--サクリボー
-- 效果：
-- ①：这张卡被解放的场合发动。自己从卡组抽1张。
-- ②：自己怪兽被战斗破坏的场合，可以作为代替把墓地的这张卡除外。
function c50185950.initial_effect(c)
	-- ①：这张卡被解放的场合发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50185950,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_RELEASE)
	e1:SetTarget(c50185950.drtg)
	e1:SetOperation(c50185950.drop)
	c:RegisterEffect(e1)
	-- ②：自己怪兽被战斗破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c50185950.reptg)
	e2:SetValue(c50185950.repval)
	e2:SetOperation(c50185950.repop)
	c:RegisterEffect(e2)
end
-- 设置效果目标为抽卡动作
function c50185950.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的目标玩家设为自己
	Duel.SetTargetPlayer(tp)
	-- 将效果的目标参数设为1（抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果
function c50185950.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 判断目标怪兽是否满足被战斗破坏且未被代替破坏的条件
function c50185950.filter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsReason(REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否满足代替破坏的触发条件并询问玩家是否发动
function c50185950.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c50185950.filter,1,nil,tp) and e:GetHandler():IsAbleToRemove() end
	-- 询问玩家是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 返回目标怪兽是否满足代替破坏条件的结果
function c50185950.repval(e,c)
	return c50185950.filter(c,e:GetHandlerPlayer())
end
-- 执行将卡片从墓地除外的操作
function c50185950.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将卡片以除外形式移除，原因包含效果和代替
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
