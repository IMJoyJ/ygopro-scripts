--副作用？
-- 效果：
-- ①：对方从卡组抽出1～3张的任意数量。那之后，自己回复这个效果让对方抽出的数量×2000基本分。
function c30922149.initial_effect(c)
	-- ①：对方从卡组抽出1～3张的任意数量。那之后，自己回复这个效果让对方抽出的数量×2000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTarget(c30922149.target)
	e1:SetOperation(c30922149.activate)
	c:RegisterEffect(e1)
end
-- 发动时的效果处理：确认对方是否可以抽卡，并把对方设置为该效果的对象玩家，同时登记抽卡效果的操作信息。
function c30922149.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：若对方不能抽卡，则效果不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp,1) end
	-- 将对方（1-tp）设置为该连锁效果的对象玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 登记操作信息：该效果涉及抽卡，对象玩家为对方，目标区域为卡组。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
-- 效果处理：取得对象玩家，若其不能抽卡则效果不处理；根据对方卡组剩余数量，让其在1～3张的范围内选择抽卡数量并抽卡。
function c30922149.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出记录的对象玩家（即对方）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 若对象玩家不能抽卡，则终止本次效果处理。
	if not Duel.IsPlayerCanDraw(p) then return end
	-- 获取对象玩家卡组剩余卡的数量，用于限制可选择抽卡的数量。
	local ct=Duel.GetFieldGroupCount(p,LOCATION_DECK,0)
	local ac=0
	if ct==1 then ac=1 end
	if ct>1 then
		-- 向对象玩家发送选择消息提示，让其为抽卡数量进行选择。
		Duel.Hint(HINT_SELECTMSG,p,aux.Stringid(30922149,0))  --"请选择要抽卡的数量"
		-- 若对方卡组只有2张，则只能宣言抽1张或抽2张。
		if ct==2 then ac=Duel.AnnounceNumber(p,1,2)
		-- 否则（卡组数量至少3张），让对方宣言抽1张、2张或3张。
		else ac=Duel.AnnounceNumber(p,1,2,3) end
	end
	-- 以效果原因让对方抽取ac张卡，并记录实际抽取数量。
	local dr=Duel.Draw(p,ac,REASON_EFFECT)
	if p~=tp and dr~=0 then
		-- 中断当前效果处理，使抽卡结果和后续回复基本分分为不同处理段，规避时点问题。
		Duel.BreakEffect()
		-- 自己回复实际抽卡数量×2000基本分。
		Duel.Recover(tp,dr*2000,REASON_EFFECT)
	end
end
