--宇宙的ハリケーン
local s,id,o=GetID()
-- 创建并注册一张永续魔法卡的效果，包括效果描述、分类、类型、发动条件、发动次数限制、目标选择函数和效果处理函数
function s.initial_effect(c)
	-- local e1=Effect.CreateEffect(c)  e1:SetDescription(aux.Stringid(id,0))  e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)  e1:SetType(EFFECT_TYPE_ACTIVATE)  e1:SetCode(EVENT_FREE_CHAIN)  e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)  e1:SetTarget(s.target)  e1:SetOperation(s.activate)  c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 效果处理的目标选择函数，检查场上是否有能送入手牌的卡，并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：场上是否存在至少一张可以送去手牌的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取所有可以送去手牌的场上卡组成的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息为将目标卡送去手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置连锁操作信息为将双方手牌送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_ALL,LOCATION_HAND)
end
-- 用于判断某张卡是否在手牌且属于指定玩家的过滤函数
function s.cfilter(c,tp)
	return c:IsLocation(LOCATION_HAND) and c:IsControler(tp)
end
-- 效果处理函数，选择场上卡送入手牌，并根据送入手牌的卡所属玩家决定其手牌返回卡组
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动玩家提示“请选择要返回手牌的卡”的选择消息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从场上选择1到2张可以送去手牌的卡作为目标
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	if g:GetCount()>0 then
		-- 为选中的卡显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 将选中的卡送入手牌，若成功则继续处理后续逻辑
		if Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
			-- 获取上一次操作实际处理的卡片组
			local og=Duel.GetOperatedGroup()
			local gs={}
			-- 遍历当前回合玩家和对方玩家
			for p in aux.TurnPlayers() do
				local etg=Group.CreateGroup()
				gs[p]=etg
				if og:IsExists(s.cfilter,1,nil,p) then
					local ct=og:FilterCount(s.cfilter,nil,p)
					-- 向指定玩家提示“请选择要返回卡组的卡”的选择消息
					Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
					-- 从指定玩家手牌中选择与送入手牌数量相同的卡作为返回卡组的目标
					gs[p]=Duel.GetFieldGroup(p,LOCATION_HAND,0):Select(p,ct,ct,nil)
					-- 将指定玩家的手牌洗切
					Duel.ShuffleHand(p)
				end
			end
			-- 再次遍历当前回合玩家和对方玩家
			for p in aux.TurnPlayers() do
				local sg=gs[p]
				if sg:GetCount()>0 then
					-- 将指定玩家选中的卡放回卡组底端
					aux.PlaceCardsOnDeckBottom(p,sg)
				end
			end
		end
	end
end
