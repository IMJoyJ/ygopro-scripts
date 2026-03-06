--教導枢機テトラドラグマ
-- 效果：
-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
-- ①：以自己·对方的墓地的融合·同调·超量·连接怪兽合计4只为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽除外。
-- ②：特殊召唤的怪兽和这张卡进行战斗的伤害步骤开始时发动。对方场上的攻击表示怪兽全部破坏。那之后，给与对方这个效果破坏的融合·同调·超量·连接怪兽数量×800伤害。
function c22073844.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：以自己·对方的墓地的融合·同调·超量·连接怪兽合计4只为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽除外。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22073844,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(c22073844.sptg)
	e1:SetOperation(c22073844.spop)
	c:RegisterEffect(e1)
	-- 特殊召唤的怪兽和这张卡进行战斗的伤害步骤开始时发动。对方场上的攻击表示怪兽全部破坏。那之后，给与对方这个效果破坏的融合·同调·超量·连接怪兽数量×800伤害。
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
-- 过滤满足条件的融合·同调·超量·连接怪兽
function c22073844.cfilter(c)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) and c:IsAbleToRemove()
end
-- 判断是否满足特殊召唤条件
function c22073844.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false)
		-- 判断墓地是否存在4只符合条件的怪兽
		and Duel.IsExistingTarget(c22073844.cfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,4,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择4只符合条件的怪兽作为除外对象
	local g=Duel.SelectTarget(tp,c22073844.cfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,4,4,nil)
	-- 设置特殊召唤的卡为操作对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置除外的卡为操作对象
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,4,0,0)
end
-- 执行特殊召唤并处理除外效果
function c22073844.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断特殊召唤是否成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:CompleteProcedure()
		-- 获取连锁中被选择的目标卡组
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
		if g:GetCount()>0 then
			-- 将目标卡组除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 判断是否为特殊召唤的怪兽
function c22073844.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 过滤攻击表示的融合·同调·超量·连接怪兽
function c22073844.dfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- 设置破坏和伤害效果的操作信息
function c22073844.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上的攻击表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_ATTACK)
	local dg=g:Filter(c22073844.dfilter,nil)
	-- 设置破坏操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置伤害操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dg:GetCount()*800)
end
-- 过滤被破坏的融合·同调·超量·连接怪兽
function c22073844.damfilter(c)
	return c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousTypeOnField()&(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)~=0
end
-- 执行破坏和伤害效果
function c22073844.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的攻击表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_ATTACK)
	-- 判断是否成功破坏怪兽
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 获取实际被破坏的卡组
		local dg=Duel.GetOperatedGroup()
		local dam=dg:FilterCount(c22073844.damfilter,nil)*800
		if dam>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 给与对方相应数量的伤害
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
end
