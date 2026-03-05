--神の見えざる手
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。这张卡也能把自己场上1张其他卡送去墓地来发动。
-- ①：从卡组把1只「不可见之手」怪兽加入手卡。把卡送去墓地来把这张卡发动的场合，可以再从卡组把「神的不可见之手」以外的1张「不可见之手」魔法·陷阱卡在自己场上盖放。
-- ②：把墓地的这张卡除外才能发动。对方抽1张。那之后，对方选自身1张手卡丢弃。
local s,id,o=GetID()
-- 注册两个效果：①检索怪兽并可能盖放魔法/陷阱；②从墓地发动抽卡并丢弃手牌
function s.initial_effect(c)
	-- ①：从卡组把1只「不可见之手」怪兽加入手卡。把卡送去墓地来把这张卡发动的场合，可以再从卡组把「神的不可见之手」以外的1张「不可见之手」魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。对方抽1张。那之后，对方选自身1张手卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,id+o)
	-- 效果②的发动需要将此卡从场上除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查场上是否有可作为发动费用送去墓地的卡
function s.tgfilter(c)
	return c:IsAbleToGraveAsCost()
end
-- 处理效果①的发动费用：询问是否将场上一张卡送去墓地作为发动费用，若选择则执行送去墓地操作
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检查场上是否存在可作为发动费用送去墓地的卡
	if Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		-- 询问玩家是否选择将卡送去墓地来发动此卡
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡送去墓地来发动？"
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择场上一张可送去墓地的卡
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
		-- 将选中的卡送去墓地作为发动费用
		Duel.SendtoGrave(g,REASON_COST)
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
-- 过滤函数：检索卡组中「不可见之手」怪兽
function s.thfilter(c)
	return c:IsSetCard(0x1d3) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果①的发动条件：检查卡组中是否存在「不可见之手」怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「不可见之手」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果①的发动信息：准备从卡组检索一张怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数：检索卡组中「不可见之手」魔法/陷阱卡并可盖放
function s.setfilter(c,tp)
	return not c:IsCode(id) and c:IsSetCard(0x1d3)
		and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
		-- 检查玩家场上是否有空置的魔法/陷阱区域或该卡为场地魔法
		and (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 or c:IsType(TYPE_FIELD))
end
-- 处理效果①的发动效果：检索一张怪兽加入手牌，若满足条件则可再盖放一张魔法/陷阱卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择一张「不可见之手」怪兽加入手牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的怪兽
		Duel.ConfirmCards(1-tp,g)
		if e:GetLabel()==1
			-- 检查卡组中是否存在可盖放的「不可见之手」魔法/陷阱卡
			and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,tp)
			-- 询问玩家是否选择盖放魔法/陷阱卡
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否盖放？"
			-- 提示玩家选择要盖放的魔法/陷阱卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			-- 选择一张可盖放的「不可见之手」魔法/陷阱卡
			local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
			local tc=sg:GetFirst()
			if tc then
				-- 中断当前效果处理，使后续处理视为错时点
				Duel.BreakEffect()
				-- 将选中的魔法/陷阱卡盖放在场上
				Duel.SSet(tp,tc)
			end
		end
	end
end
-- 设置效果②的发动条件：检查对方是否可以抽卡
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp,1) end
	-- 设置效果②的发动信息：准备让对方丢弃一张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
	-- 设置效果②的发动信息：准备让对方抽一张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
-- 处理效果②的发动效果：对方抽一张卡，然后对方选择丢弃一张手牌
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方是否成功抽到一张卡
	if Duel.Draw(1-tp,1,REASON_EFFECT)>0 then
		-- 提示对方选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 选择对方一张手牌丢弃
		local dg=Duel.SelectMatchingCard(1-tp,aux.TRUE,1-tp,LOCATION_HAND,0,1,1,nil)
		-- 将对方手牌洗切
		Duel.ShuffleHand(1-tp)
		-- 将选中的手牌送去墓地作为丢弃
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	end
end
