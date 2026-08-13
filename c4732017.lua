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
-- 判断特殊召唤成功的此卡在特殊召唤前是否位于墓地，即是否从墓地特殊召唤成功。
function c4732017.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 效果发动时进行目标设定：设置抽卡玩家为效果发动者、抽卡数量为1，并将操作信息登记为抽卡效果。
function c4732017.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的处理对象玩家设为效果发动者tp，表示由该玩家执行抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的处理对象参数设为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 登记操作信息：效果类别为抽卡（CATEGORY_DRAW），对象玩家为tp，预计处理数量为1张；因抽卡数量在处理时可以确定但卡组不取对象，所以目标卡为nil。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理时，从当前连锁信息中取得之前设定的对象玩家和抽卡数量，并让该玩家抽对应数量的卡。
function c4732017.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前正在处理的连锁信息中获取之前设置的对象玩家p和对象参数d（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让对象玩家p以效果原因（REASON_EFFECT）抽取d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
