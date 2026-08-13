--異星戦隊 ビッグ・バン
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：从额外卡组特殊召唤的怪兽在场上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己主要阶段才能发动。这张卡以外的场上的全部怪兽的等级下降1星。这张卡的等级上升所降的怪兽数量的数值。
-- ③：自己战斗阶段以及对方主要阶段，这张卡的等级是8星以上的场合才能发动。场上1张其他卡破坏，这张卡的等级变成5星。
local s,id,o=GetID()
-- 注册这张卡的①～③效果：①手卡起动特殊召唤；②场上起动降星/升星；③二速破坏并变星，每个效果均设定1回合1次。
function s.initial_effect(c)
	-- ①：从额外卡组特殊召唤的怪兽在场上存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。这张卡以外的场上的全部怪兽的等级下降1星。这张卡的等级上升所降的怪兽数量的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"等级上升"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	-- ③：自己战斗阶段以及对方主要阶段，这张卡的等级是8星以上的场合才能发动。场上1张其他卡破坏，这张卡的等级变成5星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"卡片破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(TIMING_SPSUMMON,TIMING_BATTLE_START)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断怪兽是否为从额外卡组特殊召唤（召唤位置为LOCATION_EXTRA），用于①效果的场上存在判定。
function s.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- ①效果的发动条件：双方场上主要怪兽区域存在至少1只从额外卡组特殊召唤的怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否存在至少1只满足s.cfilter的怪兽：以tp视角查看双方主要怪兽区域。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- ①效果的发动合法性检查：自己主要怪兽区有空位，且这张卡能够被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将本次连锁标记为特殊召唤这张卡，数量1，供效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则将其特殊召唤到己方主要怪兽区。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到其持有者的场上，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：表侧表示且等级在1星以上，用于②效果筛选可降星的怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- ②效果的发动检查：场上存在这张卡以外的满足s.filter的怪兽，且这张卡自身等级不低于1。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：确认存在其他可降星怪兽，且这张卡当前等级至少为1星（可上升）。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) and e:GetHandler():IsLevelAbove(1) end
end
-- ②效果处理：获取这张卡以外的所有表侧表示且等级≥1的怪兽，给每只注册降低1星的效果；统计实际降星的怪兽数量，然后为这张卡注册上升等量星数的效果。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得这张卡以外的场上所有满足filter的怪兽集合，用于后续逐个降星。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,c)
	local tc=g:GetFirst()
	local count=0
	while tc do
		local lvbf=tc:GetLevel()
		-- 这张卡以外的场上的全部怪兽的等级下降1星。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local lvaf=tc:GetLevel()
		if lvbf>lvaf then
			count=count+1
		end
		tc=g:GetNext()
	end
	if count>0 then
		-- 这张卡的等级上升所降的怪兽数量的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(count)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- ③效果的发动条件：这张卡等级在8星以上，且当前为对方主要阶段，或自己的战斗阶段开始到结束阶段。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsLevelAbove(8) then return false end
	-- 获取当前阶段，用于判断是否处于③效果允许发动的时点。
	local ph=Duel.GetCurrentPhase()
	-- 判断当前是否为对方回合：若是则只允许对方主要阶段发动，否则要求处于自己战斗阶段。
	if Duel.GetTurnPlayer()==1-tp then
		return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
	else
		return (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
	end
end
-- ③效果发动时：确认场上存在这张卡以外的卡；向对方提示发动了③效果；将场上其他所有卡作为破坏候选写入操作信息，预定破坏1张。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在这张卡以外的、可以成为破坏对象的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向对方玩家发送提示：已选择发动这张卡的③效果，显示其效果描述。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 获取这张卡以外的场上所有卡，作为不取对象的破坏候选集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置操作信息：本次效果包含‘破坏’，候选集合为g，预定破坏1张；用于连锁检测等。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ③效果处理：从场上选择这张卡以外的1张卡破坏；若破坏成功且这张卡未变5星、仍表侧表示，则将其等级变成5星。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 弹出‘请选择要破坏的卡’的选择提示，引导玩家进行破坏选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上选择这张卡以外的1张卡作为破坏对象（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	if g:GetCount()>0 then
		-- 以动画形式展示被选中的卡，并记录其为对象。
		Duel.HintSelection(g)
		-- 执行破坏；如果破坏成功且这张卡等级不是5且表侧表示，则继续执行变星处理。
		if Duel.Destroy(g,REASON_EFFECT)>0 and not c:IsLevel(5) and c:IsFaceup() then
			-- 这张卡的等级变成5星。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(5)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
		end
	end
end
