--マジカルシルクハット
-- 效果：
-- ①：对方战斗阶段才能发动。从卡组选2张魔法·陷阱卡，那2张卡当作通常怪兽卡（攻/守0）使用，和自己的主要怪兽区域1只怪兽混合洗切并里侧守备表示盖放。这个效果从卡组特殊召唤的卡不在战斗阶段内不能存在，战斗阶段结束时破坏。
function c81210420.initial_effect(c)
	-- ①：对方战斗阶段才能发动。从卡组选2张魔法·陷阱卡，那2张卡当作通常怪兽卡（攻/守0）使用，和自己的主要怪兽区域1只怪兽混合洗切并里侧守备表示盖放。这个效果从卡组特殊召唤的卡不在战斗阶段内不能存在，战斗阶段结束时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e1:SetCondition(c81210420.condition)
	e1:SetTarget(c81210420.target)
	e1:SetOperation(c81210420.activate)
	c:RegisterEffect(e1)
end
-- 判定发动条件：当前回合不是自己的回合（即对方回合），且处于战斗阶段。
function c81210420.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否为对方回合的战斗阶段。
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 过滤条件：自己主要怪兽区域中，处于里侧守备表示或可以变成里侧表示的怪兽。
function c81210420.filter(c)
	return c:GetSequence()<5 and (c:IsPosition(POS_FACEDOWN_DEFENSE) or c:IsCanTurnSet())
end
-- 过滤条件：卡组中可以作为通常怪兽（攻/守0）里侧守备表示特殊召唤的魔法·陷阱卡。
function c81210420.spfilter(c,e,tp)
	-- 检查卡片是否为魔法或陷阱卡，且玩家是否能将其作为通常怪兽特殊召唤。
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),nil,TYPE_MONSTER+TYPE_NORMAL,0,0,0,0,0,POS_FACEDOWN_DEFENSE)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,true,POS_FACEDOWN_DEFENSE)
end
-- 效果发动时的目标选择与合法性检测。
function c81210420.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c81210420.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上是否有2个以上的空余怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查卡组中是否存在至少2张满足特殊召唤条件的魔法·陷阱卡。
		and Duel.IsExistingMatchingCard(c81210420.spfilter,tp,LOCATION_DECK,0,2,nil,e,tp)
	end
	-- 设置特殊召唤的操作信息，表示将特殊召唤2张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
-- 效果处理的核心逻辑。
function c81210420.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时，若自己场上的空余怪兽区域不足2个，则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取卡组中所有满足特殊召唤条件的魔法·陷阱卡。
	local g=Duel.GetMatchingGroup(c81210420.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()<2 then return end
	-- 提示玩家选择作为效果对象的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只满足条件的怪兽。
	local g2=Duel.SelectMatchingCard(tp,c81210420.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g2:GetFirst()
	if not tc or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:Select(tp,2,2,nil)
	if tc:IsFaceup() then
		-- 将选中的自己场上的怪兽变为里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		tc:ClearEffectRelation()
	end
	local tg=sg:GetFirst()
	local fid=e:GetHandler():GetFieldID()
	while tg do
		-- 那2张卡当作通常怪兽卡（攻/守0）使用，和自己的主要怪兽区域1只怪兽混合洗切并里侧守备表示盖放。
		local e1=Effect.CreateEffect(tg)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_NORMAL+TYPE_MONSTER)
		e1:SetReset(RESET_EVENT+0x47c0000)
		tg:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_REMOVE_RACE)
		e2:SetValue(RACE_ALL)
		tg:RegisterEffect(e2,true)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_REMOVE_ATTRIBUTE)
		e3:SetValue(0xff)
		tg:RegisterEffect(e3,true)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_SET_BASE_ATTACK)
		e4:SetValue(0)
		tg:RegisterEffect(e4,true)
		local e5=e1:Clone()
		e5:SetCode(EFFECT_SET_BASE_DEFENSE)
		e5:SetValue(0)
		tg:RegisterEffect(e5,true)
		tg:RegisterFlagEffect(81210420,RESET_EVENT+0x47c0000+RESET_PHASE+PHASE_BATTLE,0,1,fid)
		tg:SetStatus(STATUS_NO_LEVEL,true)
		tg=sg:GetNext()
	end
	-- 将选中的2张魔法·陷阱卡以里侧守备表示特殊召唤到场上。
	Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEDOWN_DEFENSE)
	-- 让对方玩家确认特殊召唤的这2张卡。
	Duel.ConfirmCards(1-tp,sg)
	sg:AddCard(tc)
	-- 将这2张特殊召唤的卡与选中的自己怪兽混合洗切并里侧守备表示盖放。
	Duel.ShuffleSetCard(sg)
	sg:RemoveCard(tc)
	sg:KeepAlive()
	-- 战斗阶段结束时破坏。
	local de=Effect.CreateEffect(e:GetHandler())
	de:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	de:SetCode(EVENT_PHASE+PHASE_BATTLE)
	de:SetReset(RESET_PHASE+PHASE_BATTLE)
	de:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	de:SetCountLimit(1)
	de:SetLabel(fid)
	de:SetLabelObject(sg)
	de:SetOperation(c81210420.desop)
	-- 注册在战斗阶段结束时触发的延迟破坏效果。
	Duel.RegisterEffect(de,tp)
end
-- 过滤出带有本效果标记且对应FieldID的卡片。
function c81210420.desfilter(c,fid)
	return c:GetFlagEffectLabel(81210420)==fid
end
-- 战斗阶段结束时，执行破坏这些特殊召唤卡片的操作。
function c81210420.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local fid=e:GetLabel()
	local tg=g:Filter(c81210420.desfilter,nil,fid)
	g:DeleteGroup()
	-- 因效果破坏这些特殊召唤的卡。
	Duel.Destroy(tg,REASON_EFFECT)
	local tg2=tg:Filter(c81210420.desfilter,nil,fid)
	-- 若因代替破坏等原因未被破坏，则将剩余的卡送去墓地。
	Duel.SendtoGrave(tg2,REASON_EFFECT)
end
