--セグメンタル・ドラゴン
-- 效果：
-- ①：这张卡可以不用解放作通常召唤。
-- ②：这张卡的①的方法通常召唤的这张卡的原本的攻击力·守备力变成一半。
-- ③：1回合1次，这张卡是已通常召唤的场合才能发动。表侧表示的这张卡破坏，持有那个攻击力以下的攻击力的主要怪兽区域的怪兽全部破坏。这个效果在对方回合也能发动。
function c15066114.initial_effect(c)
	-- ①：这张卡可以不用解放作通常召唤。②：这张卡的①的方法通常召唤的这张卡的原本的攻击力·守备力变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15066114,0))  --"不用解放召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c15066114.ntcon)
	e1:SetOperation(c15066114.ntop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- ③：1回合1次，这张卡是已通常召唤的场合才能发动。表侧表示的这张卡破坏，持有那个攻击力以下的攻击力的主要怪兽区域的怪兽全部破坏。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15066114,1))  --"怪兽破坏"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCondition(c15066114.descon)
	e3:SetTarget(c15066114.destg)
	e3:SetOperation(c15066114.desop)
	c:RegisterEffect(e3)
end
-- 该函数作为无解放召唤规则的条件判定：c为nil时表示规则询问是否可用，返回true；否则要求本次通常召唤无需解放（minc==0）、该卡等级不低于5，且控制者场上存在空余的主要怪兽区域才能适用。
function c15066114.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断能否不解放召唤：minc为0（不需要解放）、这张卡等级在5以上，并且其控制者场上仍有主要怪兽区域的空格。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 无解放召唤成功时的处理：给这张卡注册持续效果，使在自己场上表侧表示期间原本攻击力变为1300、原本守备力变为1200，直到这张卡离场等重置时失效。
function c15066114.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- ②：这张卡的①的方法通常召唤的这张卡的原本的攻击力·守备力变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1300)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	e2:SetValue(1200)
	c:RegisterEffect(e2)
end
-- ③效果的发动条件：这张卡的召唤类型为通常召唤（包括通过①不解放的通常召唤）时才能发动。
function c15066114.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 破坏对象的筛选条件：表侧表示、攻击力不高于给定数值atk，且位于主要怪兽区域（额外怪兽区除外，即格子序号小于5）。
function c15066114.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk) and c:GetSequence()<5
end
-- ③效果的发动时点：检查是否存在自身以外满足条件的怪兽；若存在，则取得所有满足条件的怪兽并连同自身一起作为将被破坏的卡组，同时设置本次操作包含破坏。
function c15066114.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动时检查：场上是否存在至少1只除自身以外、满足desfilter条件（表侧表示且攻击力不高于自身当前攻击力且位于主要怪兽区域）的怪兽，以决定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c15066114.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetAttack()) end
	-- 获取除自身以外，双方主要怪兽区域中所有表侧表示、攻击力不高于这张卡当前攻击力的怪兽，作为将被破坏的候选集合。
	local g=Duel.GetMatchingGroup(c15066114.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,c,c:GetAttack())
	g:AddCard(c)
	-- 设置操作信息：将候选怪兽组和这张卡自身作为一个整体登记为本次效果要破坏的卡片，数量为组内卡片总数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时：若这张卡仍与效果关联且表侧表示，则先记录其当前攻击力，并破坏这张卡；若破坏成功，再以记录的数值为阈值，破坏场上所有满足条件的其他怪兽。
function c15066114.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=c:GetAttack()
		-- 以效果理由破坏这张卡自身；只有当破坏成功（返回破坏数不为0）时才继续处理后续破坏效果。
		if Duel.Destroy(c,REASON_EFFECT)~=0 then
			-- 在自身被破坏成功后，以之前记录的攻击力为阈值，重新取得场上所有表侧表示、攻击力不超过该值且位于主要怪兽区域的怪兽。
			local g=Duel.GetMatchingGroup(c15066114.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,atk)
			-- 以效果理由将符合条件的所有怪兽全部破坏。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
