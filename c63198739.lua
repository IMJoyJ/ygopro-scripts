--原石竜アナザー・ベリル
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡召唤的场合才能发动。从卡组把1张「原石」魔法·陷阱卡在自己场上盖放。
-- ②：把这张卡解放才能发动。从卡组把1只通常怪兽送去墓地。
-- ③：自己准备阶段，这张卡在墓地存在，自己的场上或墓地有通常怪兽存在的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 初始化函数，注册卡片的效果
function s.initial_effect(c)
	-- ①：这张卡召唤的场合才能发动。从卡组把1张「原石」魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放才能发动。从卡组把1只通常怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.tgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	-- ③：自己准备阶段，这张卡在墓地存在，自己的场上或墓地有通常怪兽存在的场合才能发动。这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡组中属于「原石」系列、是魔法或陷阱卡且可以盖放的卡
function s.setfilter(c)
	return c:IsSetCard(0x1b9) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果①的发动条件与靶向检查函数
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：检查自己卡组是否存在满足过滤条件的「原石」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果①的处理函数：从卡组选择1张「原石」魔法·陷阱卡在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选择1张满足过滤条件的「原石」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的卡片在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
-- 效果②的发动代价函数：解放自身
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：通常怪兽且能送去墓地
function s.tgfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToGrave()
end
-- 效果②的发动条件与靶向检查函数，并设置操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：检查自己卡组是否存在满足过滤条件的通常怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理函数：从卡组选择1只通常怪兽送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1只满足过滤条件的通常怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤条件：场上表侧表示或墓地存在的通常怪兽
function s.rccfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_NORMAL)
end
-- 效果③的发动条件函数：必须是自己的准备阶段，且自己场上或墓地存在通常怪兽
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
		-- 检查自己的场上（表侧表示）或墓地是否存在通常怪兽
		and Duel.IsExistingMatchingCard(s.rccfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
-- 效果③的发动条件与靶向检查函数，并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将墓地的这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果③的处理函数：将墓地的这张卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍与效果相关，且不受王家长眠之谷的影响
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将此卡加入持有者的手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
