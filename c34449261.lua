--融合死円舞曲
-- 效果：
-- ①：以自己场上1只「魔玩具」融合怪兽和对方场上1只融合怪兽为对象才能发动。作为对象的怪兽以外的场上的特殊召唤的怪兽全部破坏。那之后，被这个效果把怪兽破坏的玩家受到作为对象的怪兽的攻击力合计数值的伤害。
function c34449261.initial_effect(c)
	-- ①：以自己场上1只「魔玩具」融合怪兽和对方场上1只融合怪兽为对象才能发动。作为对象的怪兽以外的场上的特殊召唤的怪兽全部破坏。那之后，被这个效果把怪兽破坏的玩家受到作为对象的怪兽的攻击力合计数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c34449261.target)
	e1:SetOperation(c34449261.activate)
	c:RegisterEffect(e1)
end
-- 筛选可作为第1个对象的自己场上的表侧表示「魔玩具」融合怪兽，且场上存在能作为第2个对象的对方融合怪兽。
function c34449261.filter1(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsSetCard(0xad)
		-- 检查对方场上是否存在至少1只满足filter2条件的融合怪兽，以当前候选的「魔玩具」怪兽作为参照对象。
		and Duel.IsExistingTarget(c34449261.filter2,tp,0,LOCATION_MZONE,1,nil,tp,c)
end
-- 筛选可作为第2个对象的对方场上的表侧融合怪兽，并要求场上存在可被破坏的其他特殊召唤怪兽（排除这两只对象）。
function c34449261.filter2(c,tp,tc)
	local tg=Group.FromCards(c,tc)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
		-- 检查场上是否存在至少1只除对象以外、特殊召唤的怪兽可供破坏。
		and Duel.IsExistingMatchingCard(c34449261.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tg)
end
-- 判定怪兽是否不属于对象集合且为特殊召唤怪兽（用于选出应被破坏的怪兽）。
function c34449261.desfilter(c,tg)
	return not tg:IsContains(c) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 发动时的对象选择与效果信息设定：选择自己场上1只「魔玩具」融合怪兽和对方场上1只融合怪兽，计算应破坏的怪兽组及可能造成的伤害，并写入连锁操作信息。
function c34449261.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动合法性检查：确认自己场上是否存在至少1只可作为对象的「魔玩具」融合怪兽。
	if chk==0 then return Duel.IsExistingTarget(c34449261.filter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 选择自己场上1只表侧表示的「魔玩具」融合怪兽作为第1个对象。
	local g1=Duel.SelectTarget(tp,c34449261.filter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 选择对方场上1只表侧表示的融合怪兽作为第2个对象，该怪兽需与第1个对象共同满足场上另有其他特殊召唤怪兽的条件。
	local g2=Duel.SelectTarget(tp,c34449261.filter2,tp,0,LOCATION_MZONE,1,1,nil,tp,g1:GetFirst())
	g1:Merge(g2)
	-- 获取场上除两只对象以外的所有特殊召唤怪兽，作为将被破坏的卡片组。
	local g=Duel.GetMatchingGroup(c34449261.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,g1)
	-- 设定本次连锁将被破坏的卡片组及数量（用于影响其他卡片的发动判定）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	local dam=g1:GetSum(Card.GetAttack)
	if g:FilterCount(Card.IsControler,nil,1-tp)==0 then
		-- 设定伤害操作信息：若被破坏的怪兽全部属于自己，则伤害对象为发动玩家自己。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,dam)
	elseif g:FilterCount(Card.IsControler,nil,tp)==0 then
		-- 设定伤害操作信息：若被破坏的怪兽全部属于对方，则伤害对象为对方玩家。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
	else
		-- 设定伤害操作信息：若被破坏的怪兽双方都有，则伤害对象为双方玩家。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,dam)
	end
end
-- 效果处理：取出对象怪兽并计算攻击力合计，破坏场上其他特殊召唤怪兽，若破坏成功则根据被破坏怪兽的原控制者对相应玩家造成伤害。
function c34449261.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡组，并筛选仍然与该效果相关的对象卡。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local dam=tg:Filter(Card.IsFaceup,nil):GetSum(Card.GetAttack)
	-- 获取场上除对象以外、当前仍存在的特殊召唤怪兽，作为实际要破坏的候选组。
	local g=Duel.GetMatchingGroup(c34449261.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tg)
	-- 若存在应破坏的怪兽、成功破坏且对象怪兽的攻击力合计大于0，则继续处理伤害。
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 and dam>0 then
		-- 获取本次破坏操作实际被破坏的怪兽组。
		local dg=Duel.GetOperatedGroup()
		-- 中断效果处理，使破坏与后续伤害结算视为不同时点，避免错过时点。
		Duel.BreakEffect()
		-- 若被破坏的怪兽中有原本由自己控制的怪兽，则对自己造成对应伤害。
		if dg:IsExists(Card.IsPreviousControler,1,nil,tp) then Duel.Damage(tp,dam,REASON_EFFECT,true) end
		-- 若被破坏的怪兽中有原本由对方控制的怪兽，则对对方造成对应伤害。
		if dg:IsExists(Card.IsPreviousControler,1,nil,1-tp) then Duel.Damage(1-tp,dam,REASON_EFFECT,true) end
		-- 完成伤害处理，触发伤害相关时点。
		Duel.RDComplete()
	end
end
