--竜剣士ウィンドユニコーンP
-- 效果：
-- ←2 【灵摆】 2→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域有卡存在的场合，可以从以下效果选择1个发动。
-- ●这张卡特殊召唤。
-- ●这张卡破坏，自己的灵摆区域1张5星以下的灵摆怪兽卡特殊召唤。
-- 【怪兽效果】
-- 这个卡名的②的怪兽效果1回合只能使用1次。
-- ①：只要灵摆召唤的这张卡在怪兽区域存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
-- ②：自己·对方回合，以自己场上1张灵摆怪兽卡和对方场上1张卡为对象才能发动。那些卡回到手卡。
local s,id,o=GetID()
-- 初始化卡片效果：为这张卡注册灵摆属性，并注册灵摆效果（①的两种选项）、抗性效果（不被取对象/不被效果破坏）和②的双方回合回手效果。
function s.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其可以作为灵摆卡发动并适用灵摆召唤规则。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：另一边的自己的灵摆区域有卡存在的场合，可以从以下效果选择1个发动。●这张卡特殊召唤。●这张卡破坏，自己的灵摆区域1张5星以下的灵摆怪兽卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"灵摆效果发动"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.pencon)
	e1:SetTarget(s.pentg)
	e1:SetOperation(s.penop)
	c:RegisterEffect(e1)
	-- 只要灵摆召唤的这张卡在怪兽区域存在，对方不能把这张卡作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.protcon)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置该抗性效果的判定函数：仅对方发动的卡的效果不能以这张卡为对象。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置该抗性效果的判定函数：仅对方的效果不能将这张卡破坏。
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	-- 这个卡名的②的怪兽效果1回合只能使用1次。②：自己·对方回合，以自己场上1张灵摆怪兽卡和对方场上1张卡为对象才能发动。那些卡回到手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
-- 灵摆效果的发动条件函数：检查自己两个灵摆区域是否都有卡。
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回自己灵摆区域0号位和1号位都有卡（即另一边的灵摆区域有卡）作为条件是否成立。
	return Duel.GetFieldCard(tp,LOCATION_PZONE,0) and Duel.GetFieldCard(tp,LOCATION_PZONE,1)
end
-- 定义特殊召唤候选过滤：满足5星以下、灵摆怪兽、且在当前玩家空位可被特殊召唤。
function s.penspfilter(c,e,tp)
	return c:IsLevelBelow(5) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 灵摆效果发动前的目标设定：根据两个可选分支是否可行，让玩家选择分支，并设置对应的效果分类与操作信息。
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判定选项1可行：这张卡自身可被特殊召唤，且自己主要怪兽区有空位。
	local b1=c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 判定选项2可行：自己灵摆区域存在除自身以外满足s.penspfilter条件的灵摆怪兽。
	local b2=Duel.IsExistingMatchingCard(s.penspfilter,tp,LOCATION_PZONE,0,1,c,e,tp)
		-- 同时要求自己主要怪兽区有空位，供后续特殊召唤使用。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then return b1 or b2 end
	-- 调用辅助函数让玩家从可用的选项中选择要执行的分支，返回选项编号。
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"这张卡特殊召唤"
			{b2,aux.Stringid(id,3),2})  --"这张卡破坏"
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 登记操作信息：选项1为将这张卡自身特殊召唤（数量1）。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
		-- 登记操作信息：选项2为将这张卡破坏（数量1）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
		-- 登记操作信息：选项2为从自己的灵摆区域特殊召唤1张卡（具体卡在处理时选取）。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_PZONE)
	end
end
-- 灵摆效果的处理函数：根据选项执行——选项1直接特殊召唤自身；选项2先破坏自身，成功后从自己灵摆区域选1只5星以下灵摆怪兽特殊召唤。
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==1 then
		-- 将这张卡以表侧表示特殊召唤到自己场上（无视召唤条件与苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	elseif op==2 then
		-- 若这张卡被效果成功破坏，并且自己主要怪兽区仍有空位，才继续从灵摆区域特召。
		if Duel.Destroy(c,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 取得自己灵摆区域中满足特殊召唤条件的灵摆怪兽群（同一连锁中这些卡均可被选择）。
			local sg=Duel.GetMatchingGroup(s.penspfilter,tp,LOCATION_PZONE,0,nil,e,tp)
			if #sg==0 then return end
			if #sg==1 then
				-- 若满足条件的怪兽只有1只，则直接将其表侧表示特殊召唤。
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
				return
			end
			if #sg>1 then
				-- 显示“请选择要特殊召唤的卡”的选择提示。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local g=sg:Select(tp,1,1,nil)
				-- 将玩家选择的1张灵摆怪兽表侧表示特殊召唤。
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 抗性效果的条件：这张卡是以灵摆召唤方式出场的（且当前在怪兽区域）。
function s.protcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 定义②效果对象过滤：选择自己场上表侧表示、原本种类同时为灵摆和怪兽的卡（即灵摆怪兽卡）。
function s.thfilter(c,tp)
	return (c:GetOriginalType()&(TYPE_PENDULUM|TYPE_MONSTER)==TYPE_PENDULUM|TYPE_MONSTER) and c:IsFaceup() and c:IsControler(tp)
end
-- ②效果发动前的目标设定：从双方场上所有可被效果对象且可加入手卡的卡中选出2张（自己1张灵摆怪兽、对方1张卡），设置为对象并登记回手操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 取得双方场上所有能够成为效果对象且可以加入手卡的卡，作为选择池。
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsCanBeEffectTarget,Card.IsAbleToHand),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	if chk==0 then return g:CheckSubGroup(s.thcheck,2,2,tp) end
	-- 显示“请选择要返回手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local sg=g:SelectSubGroup(tp,s.thcheck,false,2,2,tp)
	-- 将选出的2张卡设置为当前连锁的效果对象。
	Duel.SetTargetCard(sg)
	-- 登记操作信息：将这2张对象卡返回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,2,0,0)
end
-- 检查所选2张卡是否满足：至少1张是自己场上的灵摆怪兽，且至少1张是对方场上的卡（可回手）。
function s.thcheck(g,tp)
	return g:IsExists(s.thfilter,1,nil,tp)
		-- 并且所选2张中存在至少1张对方控制且能够加入手卡的卡。
		and g:IsExists(aux.AND(Card.IsControler,Card.IsAbleToHand),1,nil,1-tp)
end
-- ②效果处理函数：取得仍与效果关联的2张对象卡，将它们返回持有者手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得仍然与当前连锁有关的对象卡（若对象已离场或不受影响则不在其中）。
	local g=Duel.GetTargetsRelateToChain()
	if #g>0 then
		-- 以效果原因将这些卡返回其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
