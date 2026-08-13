--教導枢機テトラドラグマ
-- 效果：
-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
-- ①：以自己·对方的墓地的融合·同调·超量·连接怪兽合计4只为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽除外。
-- ②：特殊召唤的怪兽和这张卡进行战斗的伤害步骤开始时发动。对方场上的攻击表示怪兽全部破坏。那之后，给与对方这个效果破坏的融合·同调·超量·连接怪兽数量×800伤害。
function c22073844.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- ①：以自己·对方的墓地的融合·同调·超量·连接怪兽合计4只为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22073844,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(c22073844.sptg)
	e1:SetOperation(c22073844.spop)
	c:RegisterEffect(e1)
	-- ②：特殊召唤的怪兽和这张卡进行战斗的伤害步骤开始时发动。对方场上的攻击表示怪兽全部破坏。那之后，给与对方这个效果破坏的融合·同调·超量·连接怪兽数量×800伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22073844,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCondition(c22073844.descon)
	e2:SetTarget(c22073844.destg)
	e2:SetOperation(c22073844.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡片是否为融合·同调·超量·连接怪兽，且可以被除外；用于从墓地筛选①效果的对象。
function c22073844.cfilter(c)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) and c:IsAbleToRemove()
end
-- ①效果的发动判定：该效果为取对象效果，先排除连锁中对不合法对象的指定；在效果发动时检查自己怪兽区是否有空格、这张卡能否被特殊召唤、以及墓地是否存在4只符合条件的对象。
function c22073844.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己主要怪兽区域是否有可用空格，确保这张卡可以从手卡特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false)
		-- 检查双方墓地是否存在至少4只满足 cfilter 条件的融合·同调·超量·连接怪兽，且这些卡能成为效果对象。
		and Duel.IsExistingTarget(c22073844.cfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,4,nil) end
	-- 显示“请选择要除外的卡”的选择提示，引导操作者选择要除外的墓地对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从双方墓地选择4张符合条件的融合·同调·超量·连接怪兽作为效果对象，并记录为连锁对象。
	local g=Duel.SelectTarget(tp,c22073844.cfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,4,4,nil)
	-- 设置操作信息：本次连锁包含特殊召唤，对象为这张卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息：本次连锁包含除外，对象为刚选择的4张墓地怪兽。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,4,0,0)
end
-- ①效果处理的实现：先将这张卡从手卡特殊召唤；若召唤成功，再取出连锁对象中仍与效果关联的卡并除外。
function c22073844.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡在效果处理时仍与效果关联，并尝试以表侧表示特殊召唤；若特殊召唤成功（返回值非0）才继续后续除外。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:CompleteProcedure()
		-- 获取本次连锁的记录对象，并过滤出仍然与效果关联的卡（已经离场或不受影响的对象不会被除外）。
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
		if g:GetCount()>0 then
			-- 将过滤后的对象卡以表侧表示除外，原因为效果除外。
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件：这张卡与特殊召唤的怪兽进行战斗的伤害步骤开始时，战斗对象存在且为特殊召唤怪兽。
function c22073844.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 过滤函数：判断怪兽是否为表侧表示且为融合·同调·超量·连接怪兽，用于统计伤害数量。
function c22073844.dfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- ②效果的发动判定：满足发动条件即可发动；随后获取对方场上所有攻击表示怪兽，并按其中融合·同调·超量·连接怪兽数量设置破坏与伤害的操作信息。
function c22073844.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上全部攻击表示怪兽的集合，作为将要被破坏的候选。
	local g=Duel.GetMatchingGroup(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_ATTACK)
	local dg=g:Filter(c22073844.dfilter,nil)
	-- 设置操作信息：本次效果将破坏上述全部攻击表示怪兽，破坏数量为 g 中的卡数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息：本次效果将给对方造成 dg 中融合·同调·超量·连接怪兽数量×800 的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dg:GetCount()*800)
end
-- 过滤函数：判断被破坏的怪兽在破坏前是否为表侧表示，且其在场上的原始类型为融合·同调·超量·连接怪兽，用于统计实际造成伤害的怪兽数量。
function c22073844.damfilter(c)
	return c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousTypeOnField()&(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)~=0
end
-- ②效果处理的实现：破坏对方场上全部攻击表示怪兽；然后根据实际被破坏的融合·同调·超量·连接怪兽数量计算伤害，并给予对方伤害。
function c22073844.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际处理时，再次获取对方场上全部攻击表示怪兽，作为本次要破坏的对象。
	local g=Duel.GetMatchingGroup(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_ATTACK)
	-- 若存在攻击表示怪兽，则将其全部破坏；确认破坏实际生效后才继续处理伤害。
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 获取刚刚被效果实际破坏的怪兽组，用于计算伤害。
		local dg=Duel.GetOperatedGroup()
		local dam=dg:FilterCount(c22073844.damfilter,nil)*800
		if dam>0 then
			-- 中断当前效果处理，使后续伤害处理与之前的破坏分步进行，避免错过时点。
			Duel.BreakEffect()
			-- 给与对方玩家（1-tp）相当于 dam 点的效果伤害。
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
end
