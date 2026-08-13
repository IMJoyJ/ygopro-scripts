--ダークシー・レスキュー
-- 效果：
-- 这张卡被同调怪兽的同调召唤使用送去墓地的场合，从自己卡组抽1张卡。
function c34659866.initial_effect(c)
	-- 这张卡被同调怪兽的同调召唤使用送去墓地的场合，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34659866,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(c34659866.drcon)
	e1:SetTarget(c34659866.drtg)
	e1:SetOperation(c34659866.drop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：该卡作为同调素材被使用后存在于墓地，且此次作为素材的原因为同调召唤。
function c34659866.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 效果发动时的处理：允许发动，并将抽卡玩家设为效果发动者自己、抽卡数量设为1，同时向系统登记本次操作为抽1张卡。
function c34659866.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次连锁的目标玩家设为效果发动者（自己），指定由谁抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将本次连锁的目标参数设为1，指定抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 向系统登记当前连锁为抽卡效果，目标玩家为tp，预期抽卡数量为1，用于后续效果交互判定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：从连锁信息中取得之前设定的抽卡玩家与抽卡数量，让该玩家执行抽卡，抽卡原因记为效果。
function c34659866.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的目标玩家和目标参数（抽卡玩家和数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p因效果抽取d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
