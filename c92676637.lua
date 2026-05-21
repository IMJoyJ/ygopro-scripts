--チューニング・サポーター
-- 效果：
-- ①：把场上的这张卡作为同调素材的场合，这张卡可以当作2星怪兽使用。
-- ②：这张卡作为同调素材送去墓地的场合发动。自己从卡组抽1张。
function c92676637.initial_effect(c)
	-- ②：这张卡作为同调素材送去墓地的场合发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92676637,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(c92676637.drcon)
	e1:SetTarget(c92676637.drtg)
	e1:SetOperation(c92676637.drop)
	c:RegisterEffect(e1)
	-- ①：把场上的这张卡作为同调素材的场合，这张卡可以当作2星怪兽使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SYNCHRO_LEVEL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c92676637.slevel)
	c:RegisterEffect(e2)
end
-- 计算并返回作为同调素材时的可选等级（2星或原本等级）
function c92676637.slevel(e,c)
	-- 获取该卡在安全阈值内的当前等级
	local lv=aux.GetCappedLevel(e:GetHandler())
	return (2<<16)+lv
end
-- 确认发动条件：此卡在墓地存在，且是因为作为同调素材而被送去墓地
function c92676637.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 抽卡效果的发动准备，设置目标玩家、抽卡数量并注册操作信息
function c92676637.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为1（抽卡张数）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：玩家tp从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的执行函数，获取目标玩家和参数并执行抽卡
function c92676637.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
