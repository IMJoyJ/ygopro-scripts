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
-- 效果作用：检查卡片是否在墓地且被同调召唤作为素材
function c34659866.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 效果作用：设置抽卡目标玩家和抽卡数量
function c34659866.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：将当前玩家设置为连锁操作的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 效果作用：将抽卡数量设置为1
	Duel.SetTargetParam(1)
	-- 效果作用：设置连锁操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果作用：执行抽卡操作
function c34659866.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 效果作用：让目标玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
