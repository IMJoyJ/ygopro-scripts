--エレクトリック・スネーク
-- 效果：
-- 这张卡被对方的卡的效果从手卡丢弃去墓地时，从自己卡组抽2张卡。
function c11324436.initial_effect(c)
	-- 这张卡被对方的卡的效果从手卡丢弃去墓地时，从自己卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11324436,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c11324436.drcon)
	e1:SetTarget(c11324436.drtg)
	e1:SetOperation(c11324436.drop)
	c:RegisterEffect(e1)
end
-- 触发条件判定：这只怪兽在被对方发动的效果处理中，从手卡被丢弃送去墓地（之前位置在手卡，丢弃原因同时包含效果与丢弃，且效果发动者为对方玩家）。
function c11324436.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040 and rp==1-tp
end
-- 发动时的目标处理：无需选择卡片，直接记录目标玩家为当前玩家、抽卡数量为2，并登记抽卡的效果信息。
function c11324436.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁处理的对象玩家设置为效果发动者自己（即抽卡的玩家）。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁处理的对象参数设置为2，表示抽卡数量为2张。
	Duel.SetTargetParam(2)
	-- 登记操作信息：本效果属于抽卡效果，预期由当前玩家抽2张卡（目标卡未知，所以目标组为空，数量参数为2）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理时的操作：从当前连锁信息中取出之前记录的对象玩家和抽卡数量，令该玩家以效果原因抽相应数量的卡。
function c11324436.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁信息中记录的对象玩家和对象参数，分别存入p和d，p为抽卡玩家，d为抽卡张数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以卡片效果的原因抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
