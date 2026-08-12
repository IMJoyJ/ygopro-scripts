--ふわんだりぃずと未知の風
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，自己作需要怪兽2只解放的上级召唤的场合，可以不把怪兽2只解放而把自己场上1只怪兽和对方场上1张卡送去墓地来上级召唤。
-- ②：自己主要阶段才能发动。手卡最多2只鸟兽族怪兽给对方观看，用喜欢的顺序回到卡组最下面。那之后，自己从卡组抽出回去的数量。
function c55521751.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己作需要怪兽2只解放的上级召唤的场合，可以不把怪兽2只解放而把自己场上1只怪兽和对方场上1张卡送去墓地来上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55521751,0))  --"使用「随风旅鸟与未知之风」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c55521751.otcon)
	e1:SetTarget(c55521751.ottg)
	e1:SetOperation(c55521751.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。手卡最多2只鸟兽族怪兽给对方观看，用喜欢的顺序回到卡组最下面。那之后，自己从卡组抽出回去的数量。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(55521751,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,55521751)
	e3:SetTarget(c55521751.drtg)
	e3:SetOperation(c55521751.drop)
	c:RegisterEffect(e3)
end
-- 过滤自己场上可以送去墓地且能腾出怪兽区域的怪兽
function c55521751.otfilter(c,e,tp)
	-- 检查卡片是否能送去墓地、是否不受该效果影响，以及该卡离开场上后是否能留出可用的怪兽区域
	return c:IsAbleToGrave() and not c:IsImmuneToEffect(e) and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤对方场上可以送去墓地且未处于确认离场状态的卡片
function c55521751.otfilter2(c,e)
	return c:IsAbleToGrave() and not c:IsImmuneToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED)
end
-- 替代解放上级召唤的条件判断：需要解放的怪兽数量不超过2，且自己场上和对方场上分别存在至少1张满足送墓条件的卡
function c55521751.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return minc<=2
		-- 检查自己场上是否存在至少1只可以送去墓地且能腾出怪兽区域的怪兽
		and Duel.IsExistingMatchingCard(c55521751.otfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
		-- 检查对方场上是否存在至少1张可以送去墓地的卡
		and Duel.IsExistingMatchingCard(c55521751.otfilter2,tp,0,LOCATION_ONFIELD,1,nil,e)
end
-- 限制该替代召唤效果仅适用于需要解放2只怪兽的上级召唤
function c55521751.ottg(e,c)
	local mi,ma=c:GetTributeRequirement()
	return mi<=2 and ma>=2
end
-- 替代解放上级召唤的具体操作：分别从自己场上和对方场上选择1张卡送去墓地，并清除召唤所需的解放素材
function c55521751.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己场上选择1只满足条件的怪兽
	local g1=Duel.SelectMatchingCard(tp,c55521751.otfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从对方场上选择1张满足条件的卡
	local g2=Duel.SelectMatchingCard(tp,c55521751.otfilter2,tp,0,LOCATION_ONFIELD,1,1,nil,e)
	g1:Merge(g2)
	-- 将选中的卡片（自己场上1张和对方场上1张）送去墓地
	Duel.SendtoGrave(g1,REASON_EFFECT)
	c:SetMaterial(nil)
end
-- 过滤手卡中未公开且可以回到卡组的鸟兽族怪兽
function c55521751.drfilter(c)
	return c:IsRace(RACE_WINDBEAST) and c:IsAbleToDeck() and not c:IsPublic()
end
-- 抽卡效果的发动准备：检查玩家是否能抽卡，以及手卡中是否存在可回到卡组的鸟兽族怪兽，并设置操作信息
function c55521751.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家是否具有抽卡的效果许可
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 检查手卡中是否存在至少1只满足条件的鸟兽族怪兽
		and Duel.IsExistingMatchingCard(c55521751.drfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置当前效果的处理对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁操作信息：将手卡的卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 抽卡效果的具体处理：让玩家选择手卡最多2只鸟兽族怪兽给对方观看并回到卡组最下面，然后抽出相同数量的卡
function c55521751.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择手卡1到2张满足条件的鸟兽族怪兽
	local g=Duel.SelectMatchingCard(p,c55521751.drfilter,p,LOCATION_HAND,0,1,2,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽给对方玩家确认（观看）
		Duel.ConfirmCards(1-p,g)
		-- 将选中的卡片以玩家喜欢的顺序放回卡组最下面，并返回实际放回的卡片数量
		local ct=aux.PlaceCardsOnDeckBottom(p,g)
		if ct==0 then return end
		-- 中断当前效果处理，使后续的抽卡处理不与放回卡组同时进行
		Duel.BreakEffect()
		-- 玩家从卡组抽出与放回卡组数量相同的卡片
		Duel.Draw(p,ct,REASON_EFFECT)
	end
end
