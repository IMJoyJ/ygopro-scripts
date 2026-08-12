--カードガンナー
-- 效果：
-- ①：1回合1次，从自己卡组上面把最多3张卡送去墓地才能发动。这张卡的攻击力直到回合结束时上升因为这个效果发动而送去墓地的卡数量×500。
-- ②：自己场上的这张卡被破坏送去墓地的场合发动。自己抽1张。
function c85087012.initial_effect(c)
	-- ①：1回合1次，从自己卡组上面把最多3张卡送去墓地才能发动。这张卡的攻击力直到回合结束时上升因为这个效果发动而送去墓地的卡数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85087012,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c85087012.cost)
	e1:SetOperation(c85087012.operation)
	c:RegisterEffect(e1)
	-- ②：自己场上的这张卡被破坏送去墓地的场合发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85087012,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c85087012.drcon)
	e2:SetTarget(c85087012.drtg)
	e2:SetOperation(c85087012.drop)
	c:RegisterEffect(e2)
end
-- 从卡组上面把最多3张卡送去墓地的发动代价（Cost）处理
function c85087012.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能将至少1张卡从卡组送去墓地作为代价
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
	local ct={}
	for i=3,1,-1 do
		-- 检查玩家是否能将指定数量的卡从卡组送去墓地作为代价
		if Duel.IsPlayerCanDiscardDeckAsCost(tp,i) then
			table.insert(ct,i)
		end
	end
	if #ct==1 then
		-- 当只能送去1张卡时，直接将卡组最上方1张卡送去墓地作为代价
		Duel.DiscardDeck(tp,ct[1],REASON_COST)
		e:SetLabel(1)
	else
		-- 提示玩家选择要送去墓地的卡片数量
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(85087012,2))  --"请选择要送去墓地的卡的数量"
		-- 让玩家宣言要送去墓地的卡片数量
		local ac=Duel.AnnounceNumber(tp,table.unpack(ct))
		-- 将玩家宣言数量的卡片从卡组最上方送去墓地作为代价
		Duel.DiscardDeck(tp,ac,REASON_COST)
		e:SetLabel(ac)
	end
end
-- 攻击力上升效果的实际处理
function c85087012.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local ct=e:GetLabel()
		-- 这张卡的攻击力直到回合结束时上升因为这个效果发动而送去墓地的卡数量×500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(ct*500)
		c:RegisterEffect(e1)
	end
end
-- 检查是否满足“自己场上的这张卡被破坏送去墓地”的发动条件
function c85087012.drcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_DESTROY)~=0 and e:GetHandler():IsPreviousControler(tp)
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 抽卡效果的发动准备，设置效果的对象玩家、参数以及操作信息
function c85087012.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的实际处理
function c85087012.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
