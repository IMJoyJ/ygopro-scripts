--ヴァイロン・ヴァンガード
-- 效果：
-- 这张卡被卡的效果破坏送去墓地时，可以从自己卡组抽出这张卡装备的装备卡数量的卡。
function c87836938.initial_effect(c)
	-- 这张卡被卡的效果破坏送去墓地时，可以从自己卡组抽出这张卡装备的装备卡数量的卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87836938,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetCondition(c87836938.drcon)
	e1:SetTarget(c87836938.drtg)
	e1:SetOperation(c87836938.drop)
	c:RegisterEffect(e1)
end
-- 判断发动条件：此卡被效果破坏送去墓地，且离场前有装备卡装备，并将装备卡数量保存至Label中
function c87836938.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local et=c:GetEquipCount()
	if et>0 and c:IsReason(REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:IsLocation(LOCATION_GRAVE) then
		e:SetLabel(et)
		return true
	else return false end
end
-- 设置效果发动的目标：检查玩家是否能抽卡，并设定抽卡的目标玩家、抽卡数量及操作信息
function c87836938.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动性检查时，确认自己是否可以从卡组抽出对应数量的卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,e:GetLabel()) end
	-- 将当前连锁的对象玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为保存的装备卡数量
	Duel.SetTargetParam(e:GetLabel())
	-- 设置当前连锁的操作信息为：由自己抽对应数量的卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,e:GetLabel())
end
-- 执行效果处理：获取设定的目标玩家和抽卡数量，并执行抽卡
function c87836938.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果从卡组抽出对应数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
