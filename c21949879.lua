--EMジェントルード
-- 效果：
-- ←8 【灵摆】 8→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域有「娱乐伙伴 天使女士」存在，自己场上的怪兽不存在的场合或者只有灵摆怪兽的场合才能发动。从卡组把1张「异色眼」卡加入手卡。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合只能有1次使用其中任意1个。
-- ①：这张卡被破坏的场合才能发动。从卡组选「娱乐伙伴 粗鲁先生」以外的1只「娱乐伙伴」灵摆怪兽在自己的灵摆区域放置。
-- ②：这张卡在额外卡组表侧表示存在的场合，从手卡丢弃1只灵摆怪兽才能发动。这张卡加入手卡。那之后，可以选自己的灵摆区域1张「娱乐伙伴」卡或者「异色眼」卡回到持有者手卡。
local s,id,o=GetID()
-- 注册该卡的全部效果：通过aux.EnablePendulumAttribute使其获得灵摆召唤与灵摆卡发动能力；随后依次注册灵摆效果（从卡组检索异色眼）、怪兽效果①（被破坏时从卡组将娱乐伙伴灵摆怪兽放置到灵摆区）、怪兽效果②（额外卡组表侧表示时丢弃灵摆怪兽回收自身并可选回手灵摆区卡片），并分别设置限制次数。
function c21949879.initial_effect(c)
	-- 为这张灵摆怪兽添加灵摆召唤、灵摆卡发动等灵摆属性，使其可在灵摆区域放置并发动灵摆刻度。
	aux.EnablePendulumAttribute(c)
	-- 对应灵摆效果①：“这个卡名的灵摆效果1回合只能使用1次。①：另一边的自己的灵摆区域有「娱乐伙伴 天使女士」存在，自己场上的怪兽不存在的场合或者只有灵摆怪兽的场合才能发动。从卡组把1张「异色眼」卡加入手卡。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21949879,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,21949879)
	e1:SetCondition(c21949879.scon)
	e1:SetTarget(c21949879.stg)
	e1:SetOperation(c21949879.sop)
	c:RegisterEffect(e1)
	-- 对应怪兽效果①：“①：这张卡被破坏的场合才能发动。从卡组选「娱乐伙伴 粗鲁先生」以外的1只「娱乐伙伴」灵摆怪兽在自己的灵摆区域放置。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21949879,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,21949879+o)
	e2:SetTarget(c21949879.pentg)
	e2:SetOperation(c21949879.penop)
	c:RegisterEffect(e2)
	-- 对应怪兽效果②：“②：这张卡在额外卡组表侧表示存在的场合，从手卡丢弃1只灵摆怪兽才能发动。这张卡加入手卡。那之后，可以选自己的灵摆区域1张「娱乐伙伴」卡或者「异色眼」卡回到持有者手卡。”
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21949879,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCountLimit(1,21949879+o)
	e3:SetCondition(c21949879.thcon)
	e3:SetCost(c21949879.thcost)
	e3:SetTarget(c21949879.thtg)
	e3:SetOperation(c21949879.thop)
	c:RegisterEffect(e3)
end
-- 筛选条件：判断卡是否为「娱乐伙伴 天使女士」（卡号58938528）。
function c21949879.cfilter(c)
	return c:IsCode(58938528)
end
-- 筛选条件：判断卡是否为表侧表示且为灵摆怪兽。
function c21949879.gfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 灵摆效果的发动条件：自己的灵摆区域另一侧存在「娱乐伙伴 天使女士」，且自己场上没有怪兽或所有怪兽都是表侧灵摆怪兽。
function c21949879.scon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己主要怪兽区域的全部卡（用于检查场上怪兽情况）。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 检查自己灵摆区域是否存在至少1张「娱乐伙伴 天使女士」，并且排除效果持有者自身。
	return Duel.IsExistingMatchingCard(c21949879.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
		and (g:GetCount()==0 or g:FilterCount(c21949879.gfilter,nil)==g:GetCount())
end
-- 筛选条件：卡具有「异色眼」字段且可以被加入手卡。
function c21949879.sfilter(c)
	return c:IsSetCard(0x99) and c:IsAbleToHand()
end
-- 灵摆效果的发动目标判定：确认卡组中存在符合条件的「异色眼」卡，并设置本次操作的信息为从卡组检索卡片加入手卡。
function c21949879.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）检查卡组中是否存在至少1张符合筛选条件的「异色眼」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c21949879.sfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理将从卡组把1张卡加入手卡（用于连锁判定和后续检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 灵摆效果的实际处理：从卡组选择1张「异色眼」卡加入手卡，并向对方展示确认。
function c21949879.sop(e,tp,eg,ep,ev,re,r,rp)
	-- 给出选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「异色眼」卡。
	local g=Duel.SelectMatchingCard(tp,c21949879.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡，原因为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片，防止隐藏手牌信息。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 筛选条件：卡是「娱乐伙伴」灵摆怪兽，且不是这张卡自身（21949879），且不在禁止卡表中。
function c21949879.penfilter(c)
	return c:IsSetCard(0x9f) and c:IsType(TYPE_PENDULUM) and not c:IsCode(21949879) and not c:IsForbidden()
end
-- 怪兽效果①的发动目标判定：自己的灵摆区域有空位，且卡组中存在符合条件的「娱乐伙伴」灵摆怪兽。
function c21949879.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己灵摆区域的两个格子中至少有一个可用空格。
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 检查卡组中是否存在至少1张满足penfilter条件的「娱乐伙伴」灵摆怪兽。
		and Duel.IsExistingMatchingCard(c21949879.penfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 怪兽效果①的实际处理：从卡组选择1只「娱乐伙伴」灵摆怪兽放置到自己的灵摆区域。
function c21949879.penop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时再次确认灵摆区域至少有一个空格，如果没有空格则直接终止处理。
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	-- 给出选择提示：请选择要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组选择1张符合条件的「娱乐伙伴」灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c21949879.penfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的卡移动到自己的灵摆区域，以表侧表示放置，并使其灵摆效果立即适用。
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 怪兽效果②的发动条件：这张卡必须在额外卡组表侧表示存在。
function c21949879.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup()
end
-- 代价筛选条件：手卡中的卡是灵摆怪兽且可以被丢弃。
function c21949879.costfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsDiscardable()
end
-- 怪兽效果②的发动代价：从手卡丢弃1只灵摆怪兽。
function c21949879.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张可作为代价丢弃的灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c21949879.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家从手卡选择并丢弃1只灵摆怪兽，作为发动效果的代价。
	Duel.DiscardHand(tp,c21949879.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 怪兽效果②的目标判定：这张卡自身可以加入手卡，并设置操作信息。
function c21949879.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：本次效果处理将这张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 筛选条件：卡属于「娱乐伙伴」或「异色眼」字段，且可以加入手卡。
function c21949879.thfilter(c)
	return c:IsSetCard(0x9f,0x99) and c:IsAbleToHand()
end
-- 怪兽效果②的实际处理：先把自身加入手卡；如果加入成功后，且自己灵摆区域存在符合条件的卡，则由玩家选择是否将其中1张回到手卡。
function c21949879.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡加入其持有者的手卡，原因为效果处理。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 获取自己灵摆区域中所有符合thfilter条件的「娱乐伙伴」或「异色眼」卡。
		local g=Duel.GetMatchingGroup(c21949879.thfilter,tp,LOCATION_PZONE,0,nil)
		-- 确认这张卡确实回到手卡、灵摆区域存在可选卡片且玩家选择“是”时，才执行后续的回手处理。
		if c:IsLocation(LOCATION_HAND) and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(21949879,3)) then  --"是否选自己的灵摆区域1张卡回到手卡？"
			-- 中断当前效果链，让后续“选择灵摆区卡片回手”的处理被视为一个独立效果处理，避免错过时点。
			Duel.BreakEffect()
			-- 给出选择提示：请选择要返回手牌的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 为选中的卡显示被选为对象的动画，并记录其被选择为对象。
			Duel.HintSelection(sg)
			-- 将选中的灵摆区域卡片加入其持有者的手卡，原因为效果处理。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
	end
end
