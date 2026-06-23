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
-- 检查对方是否可以抽卡
function c30922149.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp,1) end
	-- 设置效果对象为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁操作信息为对方抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
-- 处理效果发动
function c30922149.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中效果的对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 检查对象玩家是否可以抽卡
	if not Duel.IsPlayerCanDraw(p) then return end
	-- 获取对方卡组中的卡数量
	local ct=Duel.GetFieldGroupCount(p,LOCATION_DECK,0)
	local ac=0
	if ct==1 then ac=1 end
	if ct>1 then
		-- 提示对方选择抽卡数量
		Duel.Hint(HINT_SELECTMSG,p,aux.Stringid(30922149,0))  --"请选择要抽卡的数量"
		-- 对方宣言抽1或2张卡
		if ct==2 then ac=Duel.AnnounceNumber(p,1,2)
		-- 对方宣言抽1或2或3张卡
		else ac=Duel.AnnounceNumber(p,1,2,3) end
	end
	-- 让对方从卡组抽指定数量的卡
	local dr=Duel.Draw(p,ac,REASON_EFFECT)
	if p~=tp and dr~=0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 自己回复对方抽卡数量×2000的基本分
		Duel.Recover(tp,dr*2000,REASON_EFFECT)
	end
end
