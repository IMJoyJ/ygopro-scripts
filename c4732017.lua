--灼熱ゾンビ
-- 效果：
-- 这张卡从墓地的特殊召唤成功时，自己从卡组抽1张卡。
function c4732017.initial_effect(c)
	-- 这张卡从墓地的特殊召唤成功时，自己从卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4732017,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c4732017.condition)
	e1:SetTarget(c4732017.target)
	e1:SetOperation(c4732017.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时检查此卡是否由墓地特殊召唤
function c4732017.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 设置效果的对象玩家为自己，对象参数为1，操作信息为抽卡
function c4732017.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的效果对象玩家设置成自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的效果对象参数设置成1
	Duel.SetTargetParam(1)
	-- 设置当前处理的连锁的操作信息为抽卡效果，抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理时执行抽卡操作
function c4732017.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象玩家和对象参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让指定玩家以效果原因抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
