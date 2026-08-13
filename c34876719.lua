--N・As・H Knight
-- 效果：
-- 5星怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要场上有「No.」怪兽存在，这张卡不会被战斗破坏。
-- ②：自己·对方的主要阶段，把这张卡2个超量素材取除才能发动。从额外卡组选1只「No.101」～「No.107」其中任意种的「No.」超量怪兽在这张卡下面重叠作为超量素材。那之后，可以选这张卡以外的场上1只表侧表示怪兽在这张卡下面重叠作为超量素材。
function c34876719.initial_effect(c)
	-- 为这张卡添加超量召唤手续：用等级5的2只怪兽作为超量素材进行超量召唤。
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ①：只要场上有「No.」怪兽存在，这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(c34876719.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段，把这张卡2个超量素材取除才能发动。从额外卡组选1只「No.101」～「No.107」其中任意种的「No.」超量怪兽在这张卡下面重叠作为超量素材。那之后，可以选这张卡以外的场上1只表侧表示怪兽在这张卡下面重叠作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34876719,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,34876719)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCondition(c34876719.ovcon)
	e2:SetCost(c34876719.ovcost)
	e2:SetTarget(c34876719.ovtg)
	e2:SetOperation(c34876719.ovop)
	c:RegisterEffect(e2)
end
-- 过滤条件：判定怪兽是否为表侧表示且卡名含有「No.」（字段0x48）的怪兽。
function c34876719.indfilter(c)
	return c:IsSetCard(0x48) and c:IsFaceup()
end
-- 战斗破坏免疫的条件：检查双方怪兽区是否存在至少1只满足indfilter条件的「No.」怪兽。
function c34876719.indcon(e)
	-- 检索场上（双方怪兽区）是否存在至少1张表侧表示的「No.」怪兽，存在时返回真。
	return Duel.IsExistingMatchingCard(c34876719.indfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- ②效果的发动条件：当前阶段必须为主要阶段1或主要阶段2（即自己·对方的主要阶段）。
function c34876719.ovcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否是主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- ②效果的发动代价：取除这张卡的2个超量素材。chk==0时检查是否有2个素材可取除，实际发动时移除2张超量素材作为代价。
function c34876719.ovcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 过滤可以从额外卡组选为超量素材的怪兽：必须是「No.」超量怪兽，其No.编号在101～107之间，且能够作为这张卡的超量素材并可以叠放。
function c34876719.ovfilter(c,sc)
	-- 获取这张卡的No.编号（如果是「No.」卡则返回对应数字，否则返回nil）。
	local no=aux.GetXyzNumber(c)
	return no and no>=101 and no<=107 and c:IsSetCard(0x48) and c:IsType(TYPE_XYZ) and c:IsCanBeXyzMaterial(sc) and c:IsCanOverlay()
end
-- ②效果发动前检查：我方额外卡组中是否存在至少1只可选的「No.101」～「No.107」超量怪兽。
function c34876719.ovtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断额外卡组中是否有满足ovfilter条件（No.101～107的超量怪兽且可作为素材）的卡片存在。
	if chk==0 then return Duel.IsExistingMatchingCard(c34876719.ovfilter,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
end
-- 过滤可以作为追加超量素材的场上怪兽：必须是表侧表示且能够作为超量素材叠放。
function c34876719.ovfilter2(c)
	return c:IsFaceup() and c:IsCanOverlay()
end
-- ②效果处理：先从额外卡组选1只No.101～107超量怪兽叠放为素材，之后可选将场上其他表侧表示怪兽叠放为素材；若所选怪兽免疫此效果则不能叠放，其原有超量素材按规则送入墓地。
function c34876719.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 弹出选择提示：请选择要作为超量素材的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 由玩家从额外卡组选择1张符合条件的「No.101」～「No.107」超量怪兽作为素材候选。
	local mg=Duel.SelectMatchingCard(tp,c34876719.ovfilter,tp,LOCATION_EXTRA,0,1,1,nil,c)
	if #mg==0 then return end
	-- 将选择的No.超量怪兽作为这张卡的超量素材叠放在这张卡下面。
	Duel.Overlay(c,mg)
	-- 获取场上除这张卡以外的、表侧表示且可作为超量素材的怪兽集合。
	local g=Duel.GetMatchingGroup(c34876719.ovfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,c)
	-- 如果存在可选怪兽且玩家选择“是”，则继续追加超量素材的选择；否则结束处理。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(34876719,1)) then  --"是否再选择1只怪兽作为超量素材？"
		-- 中断当前效果，使后续追加素材的处理视为不同的处理时点（避免时点被占用）。
		Duel.BreakEffect()
		-- 再次弹出选择提示：请选择要作为超量素材的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		local tg=g:Select(tp,1,1,nil)
		-- 显示选中的卡片作为对象，并记录其成为广义上的对象。
		Duel.HintSelection(tg)
		local tc=tg:GetFirst()
		if not tc:IsImmuneToEffect(e) then
			local og=tc:GetOverlayGroup()
			if og:GetCount()>0 then
				-- 将所选怪兽原有的超量素材按规则送去墓地。
				Duel.SendtoGrave(og,REASON_RULE)
			end
			-- 将选择的场上怪兽作为素材叠放在这张卡下面。
			Duel.Overlay(c,tg)
		end
	end
end
