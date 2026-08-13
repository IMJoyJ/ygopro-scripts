--古代の遠眼鏡
-- 效果：
-- 查看对方卡组最上面的最多5张卡，然后放回原处。
function c17092736.initial_effect(c)
	-- 查看对方卡组最上面的最多5张卡，然后放回原处。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c17092736.cftg)
	e1:SetOperation(c17092736.cfop)
	c:RegisterEffect(e1)
end
-- 发动时的目标判定函数：检查对方卡组是否有卡，并将发动者设置为效果的对象玩家，以便后续由发动者选择查看数量。
function c17092736.cftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查时（chk==0），要求对方卡组至少存在1张卡，否则不能发动。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
	-- 将当前连锁的效果对象玩家设置为发动者tp，表示查看数量和确认对象均为该玩家。
	Duel.SetTargetPlayer(tp)
end
-- 效果处理函数：根据对象玩家选择要查看的张数，从对方卡组顶端取出相应数量的卡给对方确认，确认后仍放回原处。
function c17092736.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的对象玩家，即发动者。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算可查看数量：取5和对方卡组现存卡数的较小值，因为效果最多查看5张且不能超过对方卡组剩余数量。
	local ct=math.min(5,Duel.GetFieldGroupCount(p,0,LOCATION_DECK))
	local t={}
	for i=1,ct do
		t[i]=i
	end
	-- 给发动者显示选择提示，提示文字为“请选择要查看的数目”。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(17092736,0))  --"请选择要查看的数目"
	-- 让对象玩家p从1到ct的数字中宣言一个数字ac，作为实际要查看的卡牌数量。
	local ac=Duel.AnnounceNumber(p,table.unpack(t))
	-- 获取对方（1-p）卡组最上方ac张卡组成的卡组对象g。
	local g=Duel.GetDecktopGroup(1-p,ac)
	if g:GetCount()>0 then
		-- 将取出的对方卡组顶端卡组g展示给玩家p确认，完成“查看”效果。
		Duel.ConfirmCards(p,g)
	end
end
