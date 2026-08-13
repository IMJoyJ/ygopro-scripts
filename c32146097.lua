--DDパンドラ
-- 效果：
-- ①：这张卡被战斗或者对方的效果破坏送去墓地时，自己场上没有卡存在的场合才能发动。自己从卡组抽2张。
function c32146097.initial_effect(c)
	-- ①：这张卡被战斗或者对方的效果破坏送去墓地时，自己场上没有卡存在的场合才能发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(c32146097.drcon)
	e1:SetTarget(c32146097.drtg)
	e1:SetOperation(c32146097.drop)
	c:RegisterEffect(e1)
end
-- 发动条件判断：本卡因战斗被破坏送去墓地，或由对方玩家效果以破坏原因送去墓地且被破坏前控制者是己方时，且己方场上没有卡片存在，才允许发动。
function c32146097.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE)
		or rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp))
		-- 追加判断己方场上不存在任何卡片（自己场上区域卡数为0），以满足“自己场上没有卡存在的场合”。
		and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0
end
-- 发动时处理：先检查己方是否因效果可抽2张卡，若可则设置目标玩家为己方、抽卡数为2，并登记操作信息为抽卡类别；随后效果处理时执行抽卡。
function c32146097.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动的合法性检查阶段（chk==0），返回己方是否能够通过效果抽2张卡，若不能则不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的目标玩家设为自己（tp），表示抽卡动作的受益玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设为2，表示需要抽取的卡牌数量为2。
	Duel.SetTargetParam(2)
	-- 登记操作信息：该连锁将进行抽卡效果处理，目标玩家为自己，预计抽卡数为2张（卡组具体卡数未知故目标为nil）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理时执行：读取发动时保存的目标玩家和抽卡数量，并让该玩家以效果原因抽对应数量的卡。
function c32146097.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得目标玩家p和目标参数d（即抽卡玩家和抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以“效果”为原因抽取d张卡，完成抽2张的效果。
	Duel.Draw(p,d,REASON_EFFECT)
end
