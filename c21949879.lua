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
-- 初始化卡片效果，注册灵摆效果和两个怪兽效果
function c21949879.initial_effect(c)
	-- 为卡片添加灵摆属性
	aux.EnablePendulumAttribute(c)
	-- ①：另一边的自己的灵摆区域有「娱乐伙伴 天使女士」存在，自己场上的怪兽不存在的场合或者只有灵摆怪兽的场合才能发动。从卡组把1张「异色眼」卡加入手卡。
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
	-- ①：这张卡被破坏的场合才能发动。从卡组选「娱乐伙伴 粗鲁先生」以外的1只「娱乐伙伴」灵摆怪兽在自己的灵摆区域放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21949879,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,21949879+o)
	e2:SetTarget(c21949879.pentg)
	e2:SetOperation(c21949879.penop)
	c:RegisterEffect(e2)
	-- ②：这张卡在额外卡组表侧表示存在的场合，从手卡丢弃1只灵摆怪兽才能发动。这张卡加入手卡。那之后，可以选自己的灵摆区域1张「娱乐伙伴」卡或者「异色眼」卡回到持有者手卡。
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
-- 过滤函数：检查灵摆区域是否存在「娱乐伙伴 天使女士」
function c21949879.cfilter(c)
	return c:IsCode(58938528)
end
-- 过滤函数：检查场上是否存在灵摆怪兽
function c21949879.gfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 灵摆效果发动条件：检查灵摆区域是否存在「娱乐伙伴 天使女士」且场上无怪兽或只有灵摆怪兽
function c21949879.scon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上怪兽组
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 检查灵摆区域是否存在「娱乐伙伴 天使女士」
	return Duel.IsExistingMatchingCard(c21949879.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
		and (g:GetCount()==0 or g:FilterCount(c21949879.gfilter,nil)==g:GetCount())
end
-- 过滤函数：检查卡组中是否存在「异色眼」卡
function c21949879.sfilter(c)
	return c:IsSetCard(0x99) and c:IsAbleToHand()
end
-- 设置灵摆效果目标：检索满足条件的「异色眼」卡
function c21949879.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足灵摆效果发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(c21949879.sfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将检索的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 灵摆效果处理：选择并加入手牌
function c21949879.sop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「异色眼」卡
	local g=Duel.SelectMatchingCard(tp,c21949879.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认玩家看到加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：检查卡组中是否存在「娱乐伙伴」灵摆怪兽
function c21949879.penfilter(c)
	return c:IsSetCard(0x9f) and c:IsType(TYPE_PENDULUM) and not c:IsCode(21949879) and not c:IsForbidden()
end
-- 设置怪兽效果①目标：检查灵摆区域是否有空位且卡组存在满足条件的卡
function c21949879.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查灵摆区域是否有空位
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 检查卡组是否存在满足条件的「娱乐伙伴」灵摆怪兽
		and Duel.IsExistingMatchingCard(c21949879.penfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 怪兽效果①处理：选择并放置灵摆怪兽
function c21949879.penop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查灵摆区域是否有空位
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择满足条件的「娱乐伙伴」灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c21949879.penfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡放置到灵摆区域
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 怪兽效果②发动条件：确认此卡在额外卡组表侧表示
function c21949879.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup()
end
-- 过滤函数：检查手牌中是否存在灵摆怪兽
function c21949879.costfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsDiscardable()
end
-- 设置怪兽效果②费用：丢弃手牌中的灵摆怪兽
function c21949879.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足怪兽效果②费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(c21949879.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃手牌中的灵摆怪兽
	Duel.DiscardHand(tp,c21949879.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 设置怪兽效果②目标：将此卡加入手牌
function c21949879.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将此卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 过滤函数：检查灵摆区域中是否存在「娱乐伙伴」或「异色眼」卡
function c21949879.thfilter(c)
	return c:IsSetCard(0x9f,0x99) and c:IsAbleToHand()
end
-- 怪兽效果②处理：将此卡加入手牌并可选择返回灵摆区域的卡
function c21949879.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 获取灵摆区域中满足条件的卡组
		local g=Duel.GetMatchingGroup(c21949879.thfilter,tp,LOCATION_PZONE,0,nil)
		-- 判断是否满足怪兽效果②后续处理条件
		if c:IsLocation(LOCATION_HAND) and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(21949879,3)) then  --"是否选自己的灵摆区域1张卡回到手卡？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提示玩家选择要返回手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 显示选中的卡被选为对象
			Duel.HintSelection(sg)
			-- 将选中的卡返回手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
	end
end
