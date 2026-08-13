--覚星輝士－セフィラビュート
-- 效果：
-- ←7 【灵摆】 7→
-- ①：自己不是「星骑士」怪兽以及「神数」怪兽不能灵摆召唤。这个效果不会被无效化。
-- 【怪兽效果】
-- 「觉星辉士-神数蝇王」的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·灵摆召唤成功的场合，以这张卡以外的自己的怪兽区域·灵摆区域1张「星骑士」卡或者「神数」卡和对方场上盖放的1张卡为对象才能发动。那些卡破坏。
function c22617205.initial_effect(c)
	-- 为这张卡注册灵摆怪兽基本属性，使其可以作为灵摆卡发动并拥有灵摆召唤的资格。
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「星骑士」怪兽以及「神数」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c22617205.splimit)
	c:RegisterEffect(e2)
	-- 「觉星辉士-神数蝇王」的怪兽效果1回合只能使用1次。①：这张卡召唤·反转召唤·灵摆召唤成功的场合，以这张卡以外的自己的怪兽区域·灵摆区域1张「星骑士」卡或者「神数」卡和对方场上盖放的1张卡为对象才能发动。那些卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,22617205)
	e3:SetTarget(c22617205.target)
	e3:SetOperation(c22617205.operation)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(c22617205.condition)
	c:RegisterEffect(e5)
	c22617205.star_knight_summon_effect=e3
end
-- 灵摆召唤限制的判定条件：若被召唤的怪兽属于「星骑士」或「神数」系列则允许召唤；否则若该次召唤是灵摆召唤则该召唤被禁止。
function c22617205.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0x9c,0xc4) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 特殊召唤成功时的追加条件：只有以灵摆召唤方式特殊召唤成功时才满足，用于限定诱发效果的发动时机。
function c22617205.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 对象筛选条件之一：卡片必须是表侧表示，且属于「星骑士」或「神数」系列。
function c22617205.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x9c,0xc4)
end
-- 对象筛选条件之二：卡片必须是里侧表示（即对方场上盖放的卡）。
function c22617205.filter2(c)
	return c:IsFacedown()
end
-- 效果目标判定：如果系统传入候选对象chkc则直接返回false（不在该路径下选对象）；在发动判定时（chk==0）检查是否同时存在符合条件的己方卡和对方里侧卡。
function c22617205.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己的怪兽区域/灵摆区域是否存在至少1张表侧表示的「星骑士」/「神数」卡，且不能选择发动效果的本体。
	if chk==0 then return Duel.IsExistingTarget(c22617205.filter1,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,e:GetHandler())
		-- 检查对方场上是否存在至少1张里侧表示的可选卡片。
		and Duel.IsExistingTarget(c22617205.filter2,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示选择提示，让玩家在“选择要破坏的卡”状态下进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家从自己的怪兽区域/灵摆区域选择1张表侧「星骑士」/「神数」卡（不包含本卡）作为第一个破坏对象，并将其登记为连锁对象。
	local g1=Duel.SelectTarget(tp,c22617205.filter1,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,1,e:GetHandler())
	-- 再次显示选择提示，用于选择第二个破坏对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家从对方场上选择1张里侧表示的卡作为第二个破坏对象，并登记为连锁对象。
	local g2=Duel.SelectTarget(tp,c22617205.filter2,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 将两次选择结果合并后登记操作信息：本连锁将以效果破坏这2张卡，供其他效果和时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 效果处理函数：在效果结算时取得连锁对象并执行破坏处理。
function c22617205.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象卡组，并过滤出仍与该效果存在联系的卡（已离场或失去联系的对象不会被处理）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 以效果破坏原因将过滤后的对象卡全部破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
