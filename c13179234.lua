--VV～始まりの地～
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1张「群豪」场地魔法卡加入手卡。那之后，以下效果可以适用。
-- ●选自己场上1张灵摆怪兽卡破坏，从卡组把1张「位置移动」加入手卡。
-- ②：把墓地的这张卡除外才能发动。从自己的额外卡组选1只表侧表示的「群豪」灵摆怪兽在自己的灵摆区域放置。这个效果在这张卡送去墓地的回合不能发动。
function c13179234.initial_effect(c)
	-- ①：从卡组把1张「群豪」场地魔法卡加入手卡。那之后，以下效果可以适用。●选自己场上1张灵摆怪兽卡破坏，从卡组把1张「位置移动」加入手卡。
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
	-- 设置②效果发动条件：这张卡送去墓地的回合不能发动（使用aux.exccon判定）。
	e2:SetCondition(aux.exccon)
	-- 设置②效果发动COST：把墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c13179234.pstg)
	e2:SetOperation(c13179234.psop)
	c:RegisterEffect(e2)
end
-- 定义①效果的检索过滤条件：卡名属于「群豪」、类型为场地魔法、且能被加入手卡的卡。
function c13179234.thfilter(c)
	return c:IsSetCard(0x17d) and c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 定义①效果的发动目标函数：检查卡组是否存在符合条件的「群豪」场地魔法卡，并声明操作是将1张卡从卡组加入手卡。
function c13179234.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查中，确认卡组里至少存在1张满足thfilter的「群豪」场地魔法卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c13179234.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本效果处理时会将1张卡从卡组加入手卡（供手卡加入相关效果联动检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义可选破坏的筛选条件：自己场上表侧表示且原始类型包含灵摆怪兽的卡。
function c13179234.desfilter(c)
	return c:IsFaceup() and c:GetOriginalType()&TYPE_PENDULUM~=0
end
-- 定义检索「位置移动」的筛选条件：卡号63394872且可以加入手卡的卡。
function c13179234.sfilter(c)
	return c:IsCode(63394872) and c:IsAbleToHand()
end
-- 执行①效果：从卡组选择1张「群豪」场地魔法卡加入手卡并展示给对方；若我方场上有表侧灵摆怪兽且卡组有「位置移动」，可由玩家选择是否破坏其中1只灵摆怪兽并检索「位置移动」加入手卡。
function c13179234.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示信息，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足thfilter的「群豪」场地魔法卡（效果处理时选择，不取对象）。
	local g=Duel.SelectMatchingCard(tp,c13179234.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 确认选择成功、加入手卡成功且该卡确实在手卡中，才继续处理后续可选效果（防止检索失败或卡片离手导致无法继续）。
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 将检索到的「群豪」场地魔法卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 取得自己场上所有满足desfilter的表侧灵摆怪兽，作为可选破坏的候选集合。
		local dg=Duel.GetMatchingGroup(c13179234.desfilter,tp,LOCATION_ONFIELD,0,nil)
		-- 取得卡组中所有满足sfilter的「位置移动」，作为后续可选检索的候选集合。
		local sg=Duel.GetMatchingGroup(c13179234.sfilter,tp,LOCATION_DECK,0,nil)
		-- 当场上存在可破坏的灵摆怪兽、卡组存在「位置移动」，且玩家选择“是”时，才发动可选部分；显示询问是否破坏并检索。
		if dg:GetCount()>0 and sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(13179234,2)) then  --"是否破坏灵摆卡并检索「位置移动」？"
			-- 中断当前效果的处理流程，使之后的“破坏并检索”部分成为独立的处理时点（体现“那之后”），避免产生错误的连续时点。
			Duel.BreakEffect()
			-- 显示选择提示信息，提示玩家选择要破坏的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local dc=dg:Select(tp,1,1,nil)
			-- 手动显示被选择为对象的卡的选中动画，并记录这些卡被选为对象（广义的对象标记）。
			Duel.HintSelection(dc)
			-- 以效果破坏所选的灵摆怪兽；只有破坏成功时，才继续执行检索「位置移动」。
			if Duel.Destroy(dc,REASON_EFFECT)>0 then
				-- 显示选择提示信息，提示玩家选择要加入手牌的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				local sc=sg:Select(tp,1,1,nil)
				-- 将选择的「位置移动」加入手卡。
				Duel.SendtoHand(sc,nil,REASON_EFFECT)
				-- 将加入手卡的「位置移动」展示给对方玩家确认。
				Duel.ConfirmCards(1-tp,sc)
			end
		end
	end
end
-- 定义②效果的选择过滤条件：额外卡组表侧表示、属于「群豪」且为灵摆怪兽、不存在灵摆区域放置限制的卡。
function c13179234.psfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x17d) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
-- 定义②效果的发动目标函数：检查自己的灵摆区域是否有空位，以及额外卡组是否存在满足psfilter的「群豪」灵摆怪兽。
function c13179234.pstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己灵摆区域0号位或1号位是否有空位。
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 并且确认额外卡组存在至少1只满足psfilter的表侧「群豪」灵摆怪兽。
		and Duel.IsExistingMatchingCard(c13179234.psfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
-- 执行②效果：在灵摆区域仍有空位的前提下，从额外卡组选择1只表侧「群豪」灵摆怪兽，正面表示放置到自己的灵摆区域。
function c13179234.psop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己灵摆区域左右两侧至少一个空位仍可用；若两格都已被占用则直接终止处理。
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	-- 显示选择提示信息，提示玩家选择要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从额外卡组选择1张满足psfilter的表侧「群豪」灵摆怪兽（效果处理时选择，不取对象）。
	local g=Duel.SelectMatchingCard(tp,c13179234.psfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡移动到自己灵摆区域，以表侧表示放置，并立即适用其效果（enable=true）。
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
