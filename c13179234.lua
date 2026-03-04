--VV～始まりの地～
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1张「群豪」场地魔法卡加入手卡。那之后，以下效果可以适用。
-- ●选自己场上1张灵摆怪兽卡破坏，从卡组把1张「位置移动」加入手卡。
-- ②：把墓地的这张卡除外才能发动。从自己的额外卡组选1只表侧表示的「群豪」灵摆怪兽在自己的灵摆区域放置。这个效果在这张卡送去墓地的回合不能发动。
function c13179234.initial_effect(c)
	-- ①：从卡组把1张「群豪」场地魔法卡加入手卡。那之后，以下效果可以适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13179234,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,13179234)
	e1:SetTarget(c13179234.thtg)
	e1:SetOperation(c13179234.thop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从自己的额外卡组选1只表侧表示的「群豪」灵摆怪兽在自己的灵摆区域放置。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13179234,1))  --"放置灵摆卡"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,13179235)
	-- 设置效果条件为：这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 设置效果费用为：把这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c13179234.pstg)
	e2:SetOperation(c13179234.psop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的「群豪」场地魔法卡的过滤函数
function c13179234.thfilter(c)
	return c:IsSetCard(0x17d) and c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 效果发动时的处理函数，用于判断是否可以发动效果
function c13179234.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：卡组中存在满足条件的「群豪」场地魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c13179234.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 破坏满足条件的灵摆怪兽的过滤函数
function c13179234.desfilter(c)
	return c:IsFaceup() and c:GetOriginalType()&TYPE_PENDULUM~=0
end
-- 检索「位置移动」的过滤函数
function c13179234.sfilter(c)
	return c:IsCode(63394872) and c:IsAbleToHand()
end
-- 效果发动时的处理函数，用于执行效果
function c13179234.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择满足条件的「群豪」场地魔法卡
	local g=Duel.SelectMatchingCard(tp,c13179234.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断是否成功将卡加入手牌并确认其位置
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 向对方确认所选卡
		Duel.ConfirmCards(1-tp,g)
		-- 获取场上满足条件的灵摆怪兽
		local dg=Duel.GetMatchingGroup(c13179234.desfilter,tp,LOCATION_ONFIELD,0,nil)
		-- 获取卡组中满足条件的「位置移动」
		local sg=Duel.GetMatchingGroup(c13179234.sfilter,tp,LOCATION_DECK,0,nil)
		-- 判断是否满足附加效果发动条件：场上存在灵摆怪兽且卡组存在「位置移动」
		if dg:GetCount()>0 and sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(13179234,2)) then  --"是否破坏灵摆卡并检索「位置移动」？"
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dc=dg:Select(tp,1,1,nil)
			-- 显示被选为对象的卡
			Duel.HintSelection(dc)
			-- 破坏选中的灵摆怪兽
			if Duel.Destroy(dc,REASON_EFFECT)>0 then
				-- 提示玩家选择要加入手牌的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local sc=sg:Select(tp,1,1,nil)
				-- 将选中的「位置移动」加入手牌
				Duel.SendtoHand(sc,nil,REASON_EFFECT)
				-- 向对方确认所选卡
				Duel.ConfirmCards(1-tp,sc)
			end
		end
	end
end
-- 选择可放置的灵摆怪兽的过滤函数
function c13179234.psfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x17d) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
-- 效果发动时的处理函数，用于判断是否可以发动效果
function c13179234.pstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：灵摆区域有空位且额外卡组存在满足条件的灵摆怪兽
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 检查是否满足发动条件：额外卡组存在满足条件的灵摆怪兽
		and Duel.IsExistingMatchingCard(c13179234.psfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
-- 效果发动时的处理函数，用于执行效果
function c13179234.psop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足放置条件：灵摆区域有空位
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	-- 提示玩家选择要放置的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	-- 从额外卡组中选择满足条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c13179234.psfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的灵摆怪兽放置到灵摆区域
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
