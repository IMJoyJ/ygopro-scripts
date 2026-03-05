--古代の遠眼鏡
-- 效果：
-- 查看对方卡组最上面的最多5张卡，然后放回原处。
function c17092736.initial_effect(c)
	-- 效果原文：查看对方卡组最上面的最多5张卡，然后放回原处。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c17092736.cftg)
	e1:SetOperation(c17092736.cfop)
	c:RegisterEffect(e1)
end
-- 效果作用：检查对方卡组是否为空，若不为空则设置目标玩家为当前玩家。
function c17092736.cftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查对方卡组是否为空，若不为空则返回true。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
	-- 效果作用：将当前连锁的目标玩家设置为当前玩家。
	Duel.SetTargetPlayer(tp)
end
-- 效果原文：查看对方卡组最上面的最多5张卡，然后放回原处。
function c17092736.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 效果作用：计算最多可查看的卡牌数量（不超过5张且不超过对方卡组数量）。
	local ct=math.min(5,Duel.GetFieldGroupCount(p,0,LOCATION_DECK))
	local t={}
	for i=1,ct do
		t[i]=i
	end
	-- 效果作用：提示玩家选择要查看的卡牌数量。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(17092736,0))  --"请选择要查看的数目"
	-- 效果作用：让玩家宣言一个要查看的卡牌数量。
	local ac=Duel.AnnounceNumber(p,table.unpack(t))
	-- 效果作用：获取对方卡组顶部指定数量的卡牌组。
	local g=Duel.GetDecktopGroup(1-p,ac)
	if g:GetCount()>0 then
		-- 效果作用：向玩家确认展示指定卡牌组。
		Duel.ConfirmCards(p,g)
	end
end
