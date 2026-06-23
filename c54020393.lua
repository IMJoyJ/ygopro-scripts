--糾罪巧－始導
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只「纠罪巧」灵摆怪兽在自己的灵摆区域放置。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外才能发动。从自己的额外卡组（表侧）把1只「纠罪巧」怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（卡片发动时的放置效果）和②效果（墓地起动的回收效果）
function s.initial_effect(c)
	-- ①：从卡组把1只「纠罪巧」灵摆怪兽在自己的灵摆区域放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"放置"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetValue(s.zones)
	c:RegisterEffect(e1)
	-- ②：把这个回合没有送去墓地的这张卡从墓地除外才能发动。从自己的额外卡组（表侧）把1只「纠罪巧」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置发动条件：这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 设置发动代价：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 计算并返回允许发动此卡时放置的魔法与陷阱区域（限制只能在灵摆区域有空位时发动）
function s.zones(e,tp,eg,ep,ev,re,r,rp)
	local zone=0xff
	-- 检查左侧灵摆区域是否为空
	local p0=Duel.CheckLocation(tp,LOCATION_PZONE,0)
	-- 检查右侧灵摆区域是否为空
	local p1=Duel.CheckLocation(tp,LOCATION_PZONE,1)
	if not p0 or not p1 then zone=zone-0x11 end
	return zone
end
-- 过滤函数：检索卡组中可以放置且不被禁止的「纠罪巧」灵摆怪兽
function s.psfilter(c)
	return c:IsSetCard(0x1d4) and c:IsAllTypes(TYPE_PENDULUM+TYPE_MONSTER) and not c:IsForbidden()
end
-- ①效果的发动准备与合法性检测函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身场上是否至少有一个空置的灵摆区域
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 并且检查卡组中是否存在至少1只满足条件的「纠罪巧」灵摆怪兽
		and Duel.IsExistingMatchingCard(s.psfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ①效果的处理函数：从卡组选择1只「纠罪巧」灵摆怪兽放置到自身的灵摆区域
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若两个灵摆区域都已满，则不处理
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	-- 提示玩家选择要放置到场上的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选择1只满足条件的「纠罪巧」灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,s.psfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示移动到自身的灵摆区域
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 过滤函数：检索额外卡组中表侧表示、可以加入手牌的「纠罪巧」怪兽
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1d4) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- ②效果的发动准备、合法性检测及设置操作信息函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身额外卡组（表侧）是否存在至少1只满足条件的「纠罪巧」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置效果分类为加入手牌，目标为额外卡组的1张卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的处理函数：从额外卡组（表侧）将1只「纠罪巧」怪兽加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从额外卡组（表侧）选择1只满足条件的「纠罪巧」怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
