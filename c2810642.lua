--PSYフレームギア・β
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
-- ①：自己场上没有怪兽存在，对方怪兽的攻击宣言时才能发动。选手卡的这张卡和自己的手卡·卡组·墓地1只「PSY骨架驱动者」特殊召唤，那只攻击怪兽破坏。那之后，战斗阶段结束。这个效果特殊召唤的怪兽全部在结束阶段除外。
function c2810642.initial_effect(c)
	-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c2810642.splimit)
	c:RegisterEffect(e1)
	-- ①：自己场上没有怪兽存在，对方怪兽的攻击宣言时才能发动。选手卡的这张卡和自己的手卡·卡组·墓地1只「PSY骨架驱动者」特殊召唤，那只攻击怪兽破坏。那之后，战斗阶段结束。这个效果特殊召唤的怪兽全部在结束阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2810642,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCondition(c2810642.condition)
	e2:SetTarget(c2810642.target)
	e2:SetOperation(c2810642.operation)
	c:RegisterEffect(e2)
end
-- 特殊召唤条件判定：只有发动者使用带有EFFECT_TYPE_ACTIONS（行动效果）的卡的效果时，这张卡才能被特殊召唤，即不能用通常召唤或其他无效果方式出场。
function c2810642.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 发动条件判定：自己场上没有怪兽，或自己受到「PSY骨架王·Λ」效果影响时允许自己场上存在怪兽；并且攻击宣言的怪兽必须为对方怪兽。
function c2810642.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检测「PSY骨架王·Λ」(8802510)的效果是否生效中。只要这张卡在怪兽区域存在，自己在自己场上有怪兽存在的场合也能把手卡的「PSY骨架装备」怪兽的效果发动。
	return (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or Duel.IsPlayerAffectedByEffect(tp,8802510))
		-- 并且当前攻击宣言的怪兽不是自己控制的怪兽，即攻击者是对方怪兽。
		and Duel.GetAttacker():GetControler()~=tp
end
-- 选择特殊召唤对象的过滤条件：目标卡必须是「PSY骨架驱动者」（卡号49036338），且该目标可以被当前效果特殊召唤。
function c2810642.spfilter(c,e,tp)
	return c:IsCode(49036338) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时点检查：确认青眼精灵龙的“不能同时特殊召唤2只以上”效果未生效、自己可用怪兽区至少2个、攻击怪兽仍与战斗相关、手牌中的这张卡本身可被特殊召唤，并且自己手牌·卡组·墓地存在至少1只符合条件的「PSY骨架驱动者」。
function c2810642.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 自己场上至少要有2个可用的怪兽区域，才能同时特殊召唤这张卡和「PSY骨架驱动者」。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 攻击宣言的怪兽仍然存在于场上并与此战斗行为相关（没有被离场或失去战斗关联）。
		and Duel.GetAttacker():IsRelateToBattle()
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己手牌·卡组·墓地是否存在至少1只满足特殊召唤条件的「PSY骨架驱动者」。
		and Duel.IsExistingMatchingCard(c2810642.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 将攻击宣言的怪兽设置为当前效果的对象，作为后续破坏处理的目标。
	Duel.SetTargetCard(Duel.GetAttacker())
	-- 设置操作信息：预计从手牌·卡组·墓地特殊召唤合计2张卡（这张卡和「PSY骨架驱动者」）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
	-- 设置操作信息：预计破坏的对象为攻击宣言的怪兽，破坏数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttacker(),1,0,0)
end
-- 效果处理：若被青眼精灵龙效果限制或自己可用怪兽区不足2个则处理失败；否则选择1只「PSY骨架驱动者」，与这张卡一起特殊召唤，登记结束阶段除外的标记，并设置结束阶段除外效果；随后处理攻击怪兽的破坏及跳过对方战斗阶段。
function c2810642.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	-- 给玩家显示提示信息，要求选择要特殊召唤的卡片（提示类型为特殊召唤选择）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己手牌·卡组·墓地中选择1只满足过滤条件的「PSY骨架驱动者」，过滤时额外排除受王家长眠之谷效果影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c2810642.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()==0 then return end
	local tc=g:GetFirst()
	local fid=c:GetFieldID()
	-- 以特殊召唤过程的一步，将选中的「PSY骨架驱动者」以表侧表示特殊召唤到己方场上。
	Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
	-- 以特殊召唤过程的一步，将这张手牌中的「PSY骨架装备·β」自身以表侧表示特殊召唤到己方场上。
	Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
	tc:RegisterFlagEffect(2810642,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	c:RegisterFlagEffect(2810642,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	-- 完成特殊召唤处理，正式将上述两张怪兽特殊召唤到场上。
	Duel.SpecialSummonComplete()
	g:AddCard(c)
	g:KeepAlive()
	-- 那只攻击怪兽破坏。那之后，战斗阶段结束。这个效果特殊召唤的怪兽全部在结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(g)
	e1:SetCondition(c2810642.rmcon)
	e1:SetOperation(c2810642.rmop)
	-- 将结束阶段除外怪兽的效果注册到当前回合的场上，使其在结束阶段时自动执行。
	Duel.RegisterEffect(e1,tp)
	-- 获取当前连锁中之前被设置为对象的攻击怪兽。
	local dc=Duel.GetFirstTarget()
	-- 若攻击怪兽仍与当前效果存在关联，则将其以效果破坏；破坏成功时才继续执行跳过战斗阶段。
	if dc:IsRelateToEffect(e) and Duel.Destroy(dc,REASON_EFFECT)~=0 then
		-- 中断当前效果处理，使后续的跳过战斗阶段视为不同时处理，避免造成错误的时点。
		Duel.BreakEffect()
		-- 跳过对方本回合的战斗阶段（直接结束战斗阶段），即强制进入结束步骤。
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
-- 筛选条件：判断卡片是否带有之前记录的同一fid标记，用于识别本效果特殊召唤出场的怪兽。
function c2810642.rmfilter(c,fid)
	return c:GetFlagEffectLabel(2810642)==fid
end
-- 结束阶段时检查：若标记组中已经不存在带有该fid的怪兽，则回收该效果并停止处理；否则继续执行除外操作。
function c2810642.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c2810642.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段除外处理：从标记组中取出带有该fid的怪兽，准备依次除外。
function c2810642.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c2810642.rmfilter,nil,e:GetLabel())
	-- 将筛选出的怪兽以表侧表示除外，这是结束阶段处理“这个效果特殊召唤的怪兽全部在结束阶段除外”的执行步骤。
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end
