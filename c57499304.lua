--七皇転生
-- 效果：
-- ①：自己的「No.101」～「No.107」其中任意种的「No.」超量怪兽或者有那怪兽在作为超量素材中的超量怪兽进行战斗的伤害计算时才能发动。那只自己怪兽除外（把持有超量素材的怪兽除外的场合那些超量素材也全部除外）。这张卡发动的回合的结束阶段，除「No.」怪兽外的1只3阶以下的超量怪兽从额外卡组特殊召唤，给与对方那个原本攻击力数值的伤害。
function c57499304.initial_effect(c)
	-- ①：自己的「No.101」～「No.107」其中任意种的「No.」超量怪兽或者有那怪兽在作为超量素材中的超量怪兽进行战斗的伤害计算时才能发动。那只自己怪兽除外（把持有超量素材的怪兽除外的场合那些超量素材也全部除外）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c57499304.condition)
	e1:SetTarget(c57499304.target)
	e1:SetOperation(c57499304.activate)
	c:RegisterEffect(e1)
end
-- 过滤「No.101」～「No.107」的「No.」超量怪兽
function c57499304.filter(c)
	-- 获取该怪兽的「No.」编号
	local no=aux.GetXyzNumber(c)
	return no and no>=101 and no<=107 and c:IsSetCard(0x48) and c:IsType(TYPE_XYZ)
end
-- 检查进行战斗的自己怪兽是否为「No.101」～「No.107」超量怪兽，或者其超量素材中是否含有这些怪兽
function c57499304.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上进行战斗的怪兽
	local tc=Duel.GetBattleMonster(tp)
	if not tc then return false end
	if not tc:IsType(TYPE_XYZ) then return false end
	if c57499304.filter(tc) then return true end
	local g=tc:GetOverlayGroup()
	return g:IsExists(c57499304.filter,1,nil)
end
-- 确认进行战斗的怪兽及其超量素材是否可以被除外，并设置除外操作信息
function c57499304.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上进行战斗的怪兽
	local tc=Duel.GetBattleMonster(tp)
	local g=tc:GetOverlayGroup()
	if chk==0 then return tc:IsAbleToRemove() and #g==g:FilterCount(Card.IsAbleToRemove,nil) end
	-- 将进行战斗的自己怪兽设为效果处理对象
	Duel.SetTargetCard(tc)
	g:AddCard(tc)
	-- 设置除外操作信息，包含该怪兽及其所有的超量素材
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- 伤害计算时效果处理：除外进行战斗的自己怪兽及其超量素材，并注册回合结束阶段的延迟效果
function c57499304.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上进行战斗的怪兽
	local tc=Duel.GetBattleMonster(tp)
	if tc and tc:IsRelateToEffect(e) and tc:IsControler(tp) then
		local og=tc:GetOverlayGroup()
		-- 如果成功将该怪兽表侧表示除外，且该怪兽持有超量素材
		if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_REMOVED) and og:GetCount()>0 then
			-- 将该怪兽持有的超量素材也全部除外
			Duel.Remove(og,POS_FACEUP,REASON_EFFECT)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡发动的回合的结束阶段，除「No.」怪兽外的1只3阶以下的超量怪兽从额外卡组特殊召唤，给与对方那个原本攻击力数值的伤害。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetOperation(c57499304.spop)
		-- 注册在回合结束阶段触发的全局效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段效果处理：从额外卡组特殊召唤1只满足条件的超量怪兽，并给与对方其原本攻击力数值的伤害
function c57499304.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动卡片「七皇转生」
	Duel.Hint(HINT_CARD,0,57499304)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只除「No.」怪兽外的3阶以下的超量怪兽
	local tc=Duel.SelectMatchingCard(tp,c57499304.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	-- 如果成功将选择的怪兽表侧表示特殊召唤
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 给与对方该怪兽原本攻击力数值的伤害
		Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
-- 过滤额外卡组中除「No.」怪兽外的3阶以下的超量怪兽
function c57499304.spfilter(c,e,tp)
	return not c:IsSetCard(0x48) and c:IsRankBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外怪兽区域或有连接端指向的怪兽区域是否有空位可以特殊召唤该怪兽
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
