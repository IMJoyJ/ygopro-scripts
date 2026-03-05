--ミミグル・フォーク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方场上1只里侧表示怪兽为对象才能发动。对方从以下效果选1个，自己让那个效果适用。
-- ●作为对象的怪兽变成表侧攻击表示或表侧守备表示。
-- ●作为对象的怪兽送去墓地。那之后，这个效果送去墓地的怪兽的持有者抽2张。
-- ②：把墓地的这张卡除外才能发动。从卡组把1张「迷拟宝箱鬼·岔路」加入手卡。
local s,id,o=GetID()
-- 注册两个效果，分别是发动时选择对方里侧表示怪兽的效果和从墓地除外并检索卡的效果
function s.initial_effect(c)
	-- 效果①：以对方场上1只里侧表示怪兽为对象才能发动。对方从以下效果选1个，自己让那个效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 效果②：把墓地的这张卡除外才能发动。从卡组把1张「迷拟宝箱鬼·岔路」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断目标怪兽是否为里侧守备表示，且可以改变表示形式或能送去墓地并让持有者抽2张卡
function s.filter(c)
	local p=c:GetOwner()
	-- 判断目标怪兽是否为里侧守备表示，且可以改变表示形式或能送去墓地并让持有者抽2张卡
	return c:IsPosition(POS_FACEDOWN_DEFENSE) and (c:IsCanChangePosition() or (c:IsAbleToGrave() and Duel.IsPlayerCanDraw(p,2)))
end
-- 设置效果①的目标选择函数，选择对方场上的里侧守备表示怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsPosition(POS_FACEDOWN_DEFENSE) and chkc:IsControler(1-tp) end
	-- 检查是否满足效果①的目标条件
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择里侧守备表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWNDEFENSE)  --"请选择里侧守备表示的怪兽"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果①的处理函数，根据选择决定是改变表示形式还是送去墓地并抽卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local p=tc:GetOwner()
	local a=tc:IsCanChangePosition()
	-- 判断目标怪兽是否能送去墓地并让持有者抽2张卡
	local b=tc:IsAbleToGrave() and Duel.IsPlayerCanDraw(p,2)
	local op=aux.SelectFromOptions(1-tp,{a,aux.Stringid(id,1)},{b,aux.Stringid(id,2)})  --"那只怪兽变成表侧攻击表示或者表侧守备表示/那只怪兽送去墓地，那之后，那持有者抽2张"
	if op==1 then
		local pos1=0
		if not tc:IsPosition(POS_FACEUP_ATTACK) then pos1=pos1+POS_FACEUP_ATTACK end
		if not tc:IsPosition(POS_FACEUP_DEFENSE) then pos1=pos1+POS_FACEUP_DEFENSE end
		-- 让玩家选择目标怪兽的表示形式
		local pos=Duel.SelectPosition(tp,tc,pos1)
		-- 改变目标怪兽的表示形式
		Duel.ChangePosition(tc,pos)
	else
		-- 将目标怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
		-- 中断当前效果，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 让目标怪兽的持有者抽2张卡
		Duel.Draw(p,2,REASON_EFFECT)
	end
end
-- 检索过滤函数，用于判断卡组中是否有此卡
function s.thfilter(c)
	return c:IsCode(id) and c:IsAbleToHand()
end
-- 设置效果②的目标函数，检查卡组中是否存在此卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在此卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果②的操作信息，表示要将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理函数，选择卡组中的此卡加入手牌并确认给对方
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择要加入手牌的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
