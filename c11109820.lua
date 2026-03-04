--エクシーズ・ユニバース
-- 效果：
-- ①：以场上2只超量怪兽为对象才能发动。那2只怪兽送去墓地。那之后，把持有和那2只超量怪兽的阶级合计相同或低1阶的阶级的1只「No.」怪兽以外的超量怪兽从额外卡组特殊召唤，把这张卡在下面重叠作为超量素材。这张卡的发动后，直到回合结束时对方受到的全部伤害变成0。
function c11109820.initial_effect(c)
	-- 以场上2只超量怪兽为对象才能发动。那2只怪兽送去墓地。那之后，把持有和那2只超量怪兽的阶级合计相同或低1阶的阶级的1只「No.」怪兽以外的超量怪兽从额外卡组特殊召唤，把这张卡在下面重叠作为超量素材。这张卡的发动后，直到回合结束时对方受到的全部伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11109820,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c11109820.target)
	e1:SetOperation(c11109820.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的超量怪兽作为效果对象
function c11109820.filter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 检查是否存在满足条件的第二只超量怪兽
		and Duel.IsExistingTarget(c11109820.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,e,tp,c,c:GetRank())
end
-- 过滤函数，用于筛选满足条件的第二只超量怪兽
function c11109820.filter2(c,e,tp,mc,rk)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 检查是否存在满足条件的额外卡组超量怪兽
		and Duel.IsExistingMatchingCard(c11109820.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,rk+c:GetRank(),Group.FromCards(c,mc))
end
-- 过滤函数，用于筛选满足条件的额外卡组超量怪兽
function c11109820.spfilter(c,e,tp,rk,mg)
	return (c:IsRank(rk) or c:IsRank(rk-1)) and not c:IsSetCard(0x48) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查目标玩家场上是否有足够的位置特殊召唤该怪兽
		and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
-- 效果处理的处理函数
function c11109820.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE)
		and e:GetHandler():IsCanOverlay()
		-- 检查是否存在满足条件的超量怪兽作为效果对象
		and Duel.IsExistingTarget(c11109820.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择一只满足条件的超量怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c11109820.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	local tc=g1:GetFirst()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择第二只满足条件的超量怪兽作为效果对象
	local g2=Duel.SelectTarget(tp,c11109820.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc,e,tp,tc,tc:GetRank())
	g1:Merge(g2)
	-- 设置效果处理信息，将要送去墓地的卡加入操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,2,0,0)
	-- 设置效果处理信息，将要特殊召唤的卡加入操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理的处理函数
function c11109820.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 以场上2只超量怪兽为对象才能发动。那2只怪兽送去墓地。那之后，把持有和那2只超量怪兽的阶级合计相同或低1阶的阶级的1只「No.」怪兽以外的超量怪兽从额外卡组特殊召唤，把这张卡在下面重叠作为超量素材。这张卡的发动后，直到回合结束时对方受到的全部伤害变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetValue(0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册到玩家场上，使对方受到的伤害变为0
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册到玩家场上，使对方受到的效果伤害变为0
		Duel.RegisterEffect(e2,tp)
	end
	-- 获取当前连锁中被选择的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	if not tc1:IsRelateToEffect(e) or not tc2:IsRelateToEffect(e) then return end
	-- 将目标卡组送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
	-- 获取实际被操作的卡组
	local og=Duel.GetOperatedGroup()
	if og:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<2 then return end
	-- 获取满足条件的额外卡组超量怪兽
	local sg=Duel.GetMatchingGroup(c11109820.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,tc1:GetRank()+tc2:GetRank(),nil)
	if sg:GetCount()==0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local ssg=sg:Select(tp,1,1,nil)
	local sc=ssg:GetFirst()
	if sc then
		-- 将满足条件的超量怪兽特殊召唤
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		if c:IsRelateToEffect(e) then
			c:CancelToGrave()
			-- 将此卡叠放于特殊召唤的怪兽下方作为超量素材
			Duel.Overlay(sc,Group.FromCards(c))
		end
	end
end
