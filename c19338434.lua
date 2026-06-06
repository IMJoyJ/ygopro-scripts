--ミミグル・フォーク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方场上1只里侧表示怪兽为对象才能发动。对方从以下效果选1个，自己让那个效果适用。
-- ●作为对象的怪兽变成表侧攻击表示或表侧守备表示。
-- ●作为对象的怪兽送去墓地。那之后，这个效果送去墓地的怪兽的持有者抽2张。
-- ②：把墓地的这张卡除外才能发动。从卡组把1张「迷拟宝箱鬼·岔路」加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的入口函数，初始化卡片效果（注册魔法卡发动的效果e1，以及墓地除外自身检索同名卡的起动效果e2）。
function s.initial_effect(c)
	-- ①：以对方场上1只里侧表示怪兽为对象才能发动。对方从以下效果选1个，自己让那个效果适用。
●作为对象的怪兽变成表侧攻击表示或表侧守备表示。
●作为对象的怪兽送去墓地。那之后，这个效果送去墓地的怪兽的持有者抽2张。
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
	-- ②：把墓地的这张卡除外才能发动。从卡组把1张「迷拟宝箱鬼·岔路」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置墓地检索效果的发动代价为将墓地的此卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 筛选合法的效果对象的过滤函数（限定为对方场上里侧守备表示、且可以改变表示形式，或者可以送去墓地且其持有者可以抽2张卡的怪兽）。
function s.filter(c)
	local p=c:GetOwner()
	-- 检查怪兽是否处于里侧守备表示，并且可以改变表示形式，或者可以被送去墓地且其持有者可以抽卡。
	return c:IsPosition(POS_FACEDOWN_DEFENSE) and (c:IsCanChangePosition() or (c:IsAbleToGrave() and Duel.IsPlayerCanDraw(p,2)))
end
-- 发动阶段的判定及对象选择函数（在发动时确认是否存在可作为效果对象的里侧怪兽，并进行取对象和设置连锁操作信息处理）。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsPosition(POS_FACEDOWN_DEFENSE) and chkc:IsControler(1-tp) end
	-- 确认对方场上是否存在至少1张满足过滤条件的里侧守备表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 发送系统提示，要求玩家选择对方场上的里侧守备表示怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWNDEFENSE)  --"请选择里侧守备表示的怪兽"
	-- 让玩家选择对方场上的1只里侧守备表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理函数，获取对象怪兽，根据其状态计算可行的选项，然后让对方玩家选择适用哪个效果，并最终由自己来适用该效果的处理。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在此连锁中被选择的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local p=tc:GetOwner()
	local a=tc:IsCanChangePosition()
	-- 判断作为对象的怪兽是否能够被送去墓地，并且其持有者是否可以执行效果抽2张卡的操作。
	local b=tc:IsAbleToGrave() and Duel.IsPlayerCanDraw(p,2)
	local op=aux.SelectFromOptions(1-tp,{a,aux.Stringid(id,1)},{b,aux.Stringid(id,2)})  --"那只怪兽变成表侧攻击表示或者表侧守备表示/那只怪兽送去墓地，那之后，那持有者抽2张"
	if op==1 then
		local pos1=0
		if not tc:IsPosition(POS_FACEUP_ATTACK) then pos1=pos1+POS_FACEUP_ATTACK end
		if not tc:IsPosition(POS_FACEUP_DEFENSE) then pos1=pos1+POS_FACEUP_DEFENSE end
		-- 由发动效果的玩家选择对象怪兽将要变成的表侧表示形式。
		local pos=Duel.SelectPosition(tp,tc,pos1)
		-- 将作为对象的怪兽改变为选择的表示形式。
		Duel.ChangePosition(tc,pos)
	else
		-- 通过效果将作为对象的怪兽送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
		if tc:IsLocation(LOCATION_GRAVE) then
			-- 中断当前效果处理，使后续的抽卡处理与送去墓地处理不视为同时进行。
			Duel.BreakEffect()
			-- 让送去墓地的怪兽的持有者从卡组抽2张卡。
			Duel.Draw(p,2,REASON_EFFECT)
		end
	end
end
-- 用于筛选卡组中「迷拟宝箱鬼·岔路」同名卡的过滤函数。
function s.thfilter(c)
	return c:IsCode(id) and c:IsAbleToHand()
end
-- 检索效果的发动阶段目标确认函数（检查卡组是否存在此卡，并设置加入手牌的操作信息）。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认己方卡组中是否存在至少1张可以加入手牌的同名卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，声明当前效果包含将卡组中的1张卡加入手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的实际处理函数，从卡组中选择1张同名卡加入手牌，并向对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送系统提示，要求玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张同名卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将所选择 of 卡加入玩家的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
