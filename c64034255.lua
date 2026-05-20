--A・ジェネクス・バードマン
-- 效果：
-- ①：让自己场上1只表侧表示怪兽回到手卡才能发动。这张卡从手卡特殊召唤。为这个效果发动而让风属性怪兽回到手卡的场合，这张卡的攻击力上升500。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c64034255.initial_effect(c)
	-- ①：让自己场上1只表侧表示怪兽回到手卡才能发动。这张卡从手卡特殊召唤。为这个效果发动而让风属性怪兽回到手卡的场合，这张卡的攻击力上升500。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64034255,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c64034255.spcost)
	e1:SetTarget(c64034255.sptg)
	e1:SetOperation(c64034255.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示、可以回到手卡，且能保证特殊召唤位置的怪兽
function c64034255.cfilter(c,ft)
	return c:IsFaceup() and c:IsAbleToHandAsCost() and (ft>0 or c:GetSequence()<5)
end
-- 发动代价：选择自己场上1只表侧表示怪兽回到手卡，并记录是否为风属性
function c64034255.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 在chk==0时，检查怪兽区域数量是否足够，以及是否存在可作为代价回到手卡的怪兽
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(c64034255.cfilter,tp,LOCATION_MZONE,0,1,nil,ft) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1张满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c64034255.cfilter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	if g:GetFirst():IsAttribute(ATTRIBUTE_WIND) then e:SetLabel(1) else e:SetLabel(0) end
	-- 将选中的怪兽作为发动代价送回手卡
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- 效果的目标：检查自身是否可以特殊召唤，并设置特殊召唤的操作信息
function c64034255.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果的处理：将这张卡特殊召唤，若因风属性怪兽回手卡而发动则攻击力上升500，且该卡离场时除外
function c64034255.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将这张卡以表侧表示特殊召唤
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		if e:GetLabel()==1 then
			-- 为这个效果发动而让风属性怪兽回到手卡的场合，这张卡的攻击力上升500。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2,true)
	end
	-- 完成特殊召唤的处理
	Duel.SpecialSummonComplete()
end
