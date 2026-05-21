--ニトロ・シンクロン
-- 效果：
-- 这张卡被名字带有「氮素」的同调怪兽的同调召唤使用送去墓地的场合，从自己卡组抽1张卡。
function c96182448.initial_effect(c)
	-- 这张卡被名字带有「氮素」的同调怪兽的同调召唤使用送去墓地的场合，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96182448,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c96182448.drcon)
	e1:SetTarget(c96182448.drtg)
	e1:SetOperation(c96182448.drop)
	c:RegisterEffect(e1)
end
-- 判断发动条件：此卡是否作为同调素材送去墓地，且用于同调召唤的怪兽是「氮素战士」（卡号18013090）
function c96182448.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO and c:GetReasonCard():IsCode(18013090)
end
-- 定义抽卡效果的发动准备（Target），设置目标玩家、抽卡数量并声明操作信息
function c96182448.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为自己（发动效果的玩家）
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为1（抽卡张数）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：玩家tp从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义抽卡效果的实际处理（Operation），获取目标玩家和抽卡数量并执行抽卡
function c96182448.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和目标参数（抽卡张数）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
