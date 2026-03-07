--N・As・H Knight
-- 效果：
-- 5星怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要场上有「No.」怪兽存在，这张卡不会被战斗破坏。
-- ②：自己·对方的主要阶段，把这张卡2个超量素材取除才能发动。从额外卡组选1只「No.101」～「No.107」其中任意种的「No.」超量怪兽在这张卡下面重叠作为超量素材。那之后，可以选这张卡以外的场上1只表侧表示怪兽在这张卡下面重叠作为超量素材。
function c34876719.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为5且数量为2的怪兽进行叠放
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- 只要场上有「No.」怪兽存在，这张卡不会被战斗破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(c34876719.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 自己·对方的主要阶段，把这张卡2个超量素材取除才能发动。从额外卡组选1只「No.101」～「No.107」其中任意种的「No.」超量怪兽在这张卡下面重叠作为超量素材。那之后，可以选这张卡以外的场上1只表侧表示怪兽在这张卡下面重叠作为超量素材。
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
-- 过滤函数，用于判断场上的「No.」怪兽是否表侧表示
function c34876719.indfilter(c)
	return c:IsSetCard(0x48) and c:IsFaceup()
end
-- 条件函数，判断场上有无「No.」怪兽表侧表示
function c34876719.indcon(e)
	-- 检查以自己来看的场上是否存在至少1张满足indfilter条件的卡
	return Duel.IsExistingMatchingCard(c34876719.indfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 条件函数，判断当前是否为主要阶段1或主要阶段2
function c34876719.ovcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 费用函数，检查是否能移除2个超量素材作为费用
function c34876719.ovcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 过滤函数，用于筛选额外卡组中满足条件的「No.」超量怪兽
function c34876719.ovfilter(c,sc)
	-- 获取输入卡片的No.编号
	local no=aux.GetXyzNumber(c)
	return no and no>=101 and no<=107 and c:IsSetCard(0x48) and c:IsType(TYPE_XYZ) and c:IsCanBeXyzMaterial(sc) and c:IsCanOverlay()
end
-- 目标函数，检查是否能在额外卡组中找到满足条件的怪兽
function c34876719.ovtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以自己来看的额外卡组是否存在至少1张满足ovfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c34876719.ovfilter,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
end
-- 过滤函数，用于筛选场上表侧表示且可作为超量素材的怪兽
function c34876719.ovfilter2(c)
	return c:IsFaceup() and c:IsCanOverlay()
end
-- 效果处理函数，执行超量素材的选取与叠放操作
function c34876719.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 向玩家提示选择超量素材的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 从额外卡组选择1只满足条件的怪兽作为超量素材
	local mg=Duel.SelectMatchingCard(tp,c34876719.ovfilter,tp,LOCATION_EXTRA,0,1,1,nil,c)
	if #mg==0 then return end
	-- 将选中的怪兽叠放至自身下方
	Duel.Overlay(c,mg)
	-- 获取场上满足条件的可作为超量素材的怪兽组
	local g=Duel.GetMatchingGroup(c34876719.ovfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,c)
	-- 判断是否选择再添加一只怪兽作为超量素材
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(34876719,1)) then  --"是否再选择1只怪兽作为超量素材？"
		-- 中断当前效果，使后续处理视为错时点
		Duel.BreakEffect()
		-- 再次向玩家提示选择超量素材的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		local tg=g:Select(tp,1,1,nil)
		-- 手动显示被选为对象的动画效果
		Duel.HintSelection(tg)
		local tc=tg:GetFirst()
		if not tc:IsImmuneToEffect(e) then
			local og=tc:GetOverlayGroup()
			if og:GetCount()>0 then
				-- 将目标怪兽的叠放卡送去墓地
				Duel.SendtoGrave(og,REASON_RULE)
			end
			-- 将选中的怪兽叠放至自身下方
			Duel.Overlay(c,tg)
		end
	end
end
