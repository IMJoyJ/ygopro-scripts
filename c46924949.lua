--縄張恐竜
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在主要怪兽区域存在，额外怪兽区域的怪兽的效果无效化。
-- ②：这张卡被战斗破坏时才能发动。从卡组把1只「领地恐龙」特殊召唤。
function c46924949.initial_effect(c)
	-- ①：只要这张卡在主要怪兽区域存在，额外怪兽区域的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCondition(c46924949.discon)
	e1:SetTarget(c46924949.distg)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡被战斗破坏时才能发动。从卡组把1只「领地恐龙」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCountLimit(1,46924949)
	e2:SetTarget(c46924949.sptg)
	e2:SetOperation(c46924949.spop)
	c:RegisterEffect(e2)
end
-- 永续效果条件：效果持有者（领地恐龙）自己所在的怪兽区域序号小于5，即处于主要怪兽区域；若在额外怪兽区域则效果不适用。
function c46924949.discon(e)
	return e:GetHandler():GetSequence()<5
end
-- 无效化对象判定：对象怪兽的怪兽区域序号大于4，即位于额外怪兽区域（5-6），满足条件则此卡效果将其无效化。
function c46924949.distg(e,c)
	return c:GetSequence()>4
end
-- 特殊召唤的筛选条件：卡名必须为「领地恐龙」（卡号46924949），且可以被玩家tp用该效果特殊召唤（不检查召唤条件、不检查苏生限制）。
function c46924949.spfilter(c,e,tp)
	return c:IsCode(46924949) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动条件判定：自己主要怪兽区域有空位且卡组存在1只符合条件的「领地恐龙」时，效果可以发动。
function c46924949.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查（chk==0）：确认自己主要怪兽区域存在可用的空格（数量大于0）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认卡组中存在至少1张满足spfilter条件的「领地恐龙」；两者均满足时效果才能发动。
		and Duel.IsExistingMatchingCard(c46924949.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：此连锁涉及从卡组特殊召唤1只怪兽，类别为CATEGORY_SPECIAL_SUMMON，处理时从卡组选卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：先再次确认主要怪兽区域有空位，然后提示玩家选择卡，从卡组选择1张符合条件的「领地恐龙」，以表侧表示特殊召唤到自己的主要怪兽区域。
function c46924949.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时安全确认：若此时主要怪兽区域没有空位，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择卡片提示，提示类型为选择卡组中的怪兽，用于后续SelectMatchingCard的选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己的卡组中筛选并选择1张满足spfilter的「领地恐龙」（效果处理时选择，不取对象）。
	local g=Duel.SelectMatchingCard(tp,c46924949.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择成功的那张「领地恐龙」以表侧表示由tp特殊召唤到tp场上（不检查召唤条件、不检查苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
