--垂氷の魔妖－雪女
-- 效果：
-- 不死族怪兽2只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：「垂冰之魔妖-雪女」在自己场上只能有1只表侧表示存在。
-- ②：这张卡特殊召唤成功的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果无效。
-- ③：把墓地的这张卡除外才能发动。从自己墓地的怪兽以及除外的自己怪兽之中选1只不死族同调怪兽特殊召唤。这个效果在对方回合也能发动。
function c36114945.initial_effect(c)
	c:SetUniqueOnField(1,0,36114945)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用2只以上满足种族为不死族的卡片作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_ZOMBIE),2)
	-- ②：这张卡特殊召唤成功的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,36114945)
	e1:SetTarget(c36114945.distg)
	e1:SetOperation(c36114945.disop)
	c:RegisterEffect(e1)
	-- ③：把墓地的这张卡除外才能发动。从自己墓地的怪兽以及除外的自己怪兽之中选1只不死族同调怪兽特殊召唤。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,36114946)
	-- 设置效果发动时的费用为将此卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c36114945.sptg)
	e2:SetOperation(c36114945.spop)
	c:RegisterEffect(e2)
end
-- 设置效果的目标选择函数，用于选择对方场上的效果怪兽
function c36114945.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断当前是否为选择目标阶段，若是则返回是否满足条件的卡片
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and aux.NegateEffectMonsterFilter(chkc) end
	-- 判断是否满足发动条件，即对方场上是否存在满足条件的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择满足条件的对方场上的一只怪兽作为目标
	local g=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，表示将使目标怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 设置效果的处理函数，用于使目标怪兽效果无效
function c36114945.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 创建一个使目标怪兽效果无效的永续效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 创建一个使目标怪兽效果无效化的永续效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- 定义特殊召唤的过滤条件，要求是不死族同调怪兽且可特殊召唤
function c36114945.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_SYNCHRO) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的目标选择函数，用于选择满足条件的不死族同调怪兽
function c36114945.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即玩家场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件，即玩家墓地或除外区是否存在满足条件的不死族同调怪兽
		and Duel.IsExistingMatchingCard(c36114945.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将特殊召唤满足条件的不死族同调怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 设置效果的处理函数，用于特殊召唤满足条件的不死族同调怪兽
function c36114945.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足发动条件，即玩家场上是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的不死族同调怪兽作为特殊召唤对象
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c36114945.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
