--No.77 ザ・セブン・シンズ
-- 效果：
-- 12星怪兽×2
-- 这张卡也能在自己场上的10·11阶的暗属性超量怪兽上面重叠来超量召唤。这个方法特殊召唤的回合，这张卡的①的效果不能发动。
-- ①：1回合1次，把这张卡2个超量素材取除才能发动。对方场上的特殊召唤的怪兽全部除外，那之后，从所除外的怪兽之中选1只在这张卡下面重叠作为超量素材。
-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
function c62541668.initial_effect(c)
	aux.AddXyzProcedure(c,nil,12,2,c62541668.ovfilter,aux.Stringid(62541668,0),2,c62541668.xyzop)  --"请选择10·11阶的暗属性超量怪兽"
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡2个超量素材取除才能发动。对方场上的特殊召唤的怪兽全部除外，那之后，从所除外的怪兽之中选1只在这张卡下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62541668,1))  --"对方场上的特殊召唤的怪兽全部除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c62541668.rmcost)
	e1:SetTarget(c62541668.rmtg)
	e1:SetOperation(c62541668.rmop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c62541668.reptg)
	c:RegisterEffect(e2)
end
-- 设置该怪兽的“No.”编号为77
aux.xyz_number[62541668]=77
-- 过滤用于重叠超量召唤的怪兽：自己场上表侧表示的10阶或11阶的暗属性超量怪兽
function c62541668.ovfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_XYZ) and c:IsRank(10,11)
end
-- 在重叠超量召唤成功时，给自身注册一个在回合结束前有效的Flag，用于限制①效果的发动
function c62541668.xyzop(e,tp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(62541668,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
end
-- ①效果的发动代价：取除这张卡的2个超量素材
function c62541668.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 过滤满足除外条件的怪兽：对方场上特殊召唤且可以被除外的怪兽
function c62541668.rmfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsAbleToRemove()
end
-- ①效果的发动准备与合法性检查：确认本回合未使用重叠超量召唤，且对方场上存在至少1只特殊召唤的怪兽
function c62541668.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(62541668)==0
		-- 检查对方场上是否存在至少1只满足除外条件的特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c62541668.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有满足除外条件的特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(c62541668.rmfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁的操作信息：除外对方场上所有满足条件的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 过滤可以作为超量素材的卡：处于除外区且可以重叠作为超量素材的卡
function c62541668.matfilter(c)
	return c:IsLocation(LOCATION_REMOVED) and c:IsCanOverlay()
end
-- ①效果的处理：除外对方场上所有特殊召唤的怪兽，之后选择其中1只重叠作为这张卡的超量素材
function c62541668.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在效果处理时，重新获取对方场上所有满足除外条件的特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(c62541668.rmfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将这些怪兽以表侧表示除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		-- 获取刚才因效果实际被除外、且可以作为超量素材的卡片组
		local og=Duel.GetOperatedGroup():Filter(c62541668.matfilter,nil)
		if og:GetCount()>0 and c:IsRelateToEffect(e) then
			-- 中断当前效果处理，使后续的重叠素材处理与除外处理不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要作为超量素材的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
			local sg=og:Select(tp,1,1,nil)
			-- 将选中的卡重叠在这张卡下面作为超量素材
			Duel.Overlay(c,sg)
		end
	end
end
-- ②效果的代替破坏检查：确认自身因战斗或效果将被破坏，且自身拥有至少1个超量素材
function c62541668.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 询问玩家是否使用代替破坏效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		return true
	else return false end
end
