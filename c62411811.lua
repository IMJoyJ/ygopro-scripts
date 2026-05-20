--迷宮に潜むシャドウ・グール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张「迷宫壁」卡加入手卡。
-- ②：对方怪兽进行战斗的伤害步骤开始时，自己场上有「迷宫壁」卡存在的场合，把墓地的这张卡除外才能发动。那只对方怪兽破坏。
function c62411811.initial_effect(c)
	-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张「迷宫壁」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62411811,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,62411811)
	e1:SetCost(c62411811.thcost)
	e1:SetTarget(c62411811.thtg)
	e1:SetOperation(c62411811.thop)
	c:RegisterEffect(e1)
	-- ②：对方怪兽进行战斗的伤害步骤开始时，自己场上有「迷宫壁」卡存在的场合，把墓地的这张卡除外才能发动。那只对方怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,62411812)
	e2:SetCondition(c62411811.descon)
	-- 设置发动代价为把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c62411811.destg)
	e2:SetOperation(c62411811.desop)
	c:RegisterEffect(e2)
end
-- ①号效果的发动代价：把这张卡从手卡丢弃
function c62411811.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 作为发动代价将这张卡从手牌丢弃送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中「迷宫壁」卡片且能加入手牌的过滤条件
function c62411811.thfilter(c)
	return c:IsSetCard(0x193) and c:IsAbleToHand()
end
-- ①号效果的发动准备（检查卡组中是否存在「迷宫壁」卡片并设置操作信息）
function c62411811.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张可以加入手牌的「迷宫壁」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c62411811.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息为：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的效果处理（从卡组将1张「迷宫壁」卡加入手牌并给对方确认）
function c62411811.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「迷宫壁」卡片
	local tg=Duel.SelectMatchingCard(tp,c62411811.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 若成功选择卡片并将其加入手牌
	if #tg>0 and Duel.SendtoHand(tg,nil,REASON_EFFECT)>0 then
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tg)
	end
end
-- 过滤场上表侧表示的「迷宫壁」卡片的过滤条件
function c62411811.descfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x193)
end
-- ②号效果的发动条件（对方怪兽进行战斗的伤害步骤开始时，且自己场上有「迷宫壁」卡存在）
function c62411811.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方进行战斗的怪兽
	local tc=Duel.GetBattleMonster(1-tp)
	if not tc then return false end
	e:SetLabelObject(tc)
	-- 检查自己场上是否存在表侧表示的「迷宫壁」卡片
	return Duel.IsExistingMatchingCard(c62411811.descfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ②号效果的发动准备（设置破坏对方怪兽的操作信息）
function c62411811.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	if chk==0 then return true end
	-- 设置连锁处理的操作信息为：破坏该对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- ②号效果的效果处理（破坏进行战斗的对方怪兽）
function c62411811.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() then
		-- 破坏该对方怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
