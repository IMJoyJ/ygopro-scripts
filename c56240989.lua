--エヴォルド・カシネリア
-- 效果：
-- 这张卡战斗破坏对方怪兽的战斗阶段结束时，把这张卡解放才能发动。从卡组把2只恐龙族·炎属性·6星以下的同名怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段时从游戏中除外。
function c56240989.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽的
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c56240989.regop)
	c:RegisterEffect(e1)
	-- 战斗阶段结束时，把这张卡解放才能发动。从卡组把2只恐龙族·炎属性·6星以下的同名怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段时从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56240989,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c56240989.spcon)
	e2:SetCost(c56240989.spcost)
	e2:SetTarget(c56240989.sptg)
	e2:SetOperation(c56240989.spop)
	c:RegisterEffect(e2)
end
-- 在自身战斗破坏对方怪兽时，为其注册一个在回合结束前有效的Flag，作为战斗阶段结束时发动效果的判定依据
function c56240989.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(56240989,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查自身是否注册了战斗破坏怪兽的Flag，作为效果发动的条件
function c56240989.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(56240989)~=0
end
-- 效果发动代价：检查自身是否可以解放，并在发动时将自身解放
function c56240989.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为效果发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤卡组中等级6以下、恐龙族、炎属性且可以特殊召唤的怪兽
function c56240989.filter(c,e,tp)
	return c:IsLevelBelow(6) and c:IsRace(RACE_DINOSAUR) and c:IsAttribute(ATTRIBUTE_FIRE)
		and c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_EVOLTILE,tp,false,false)
end
-- 过滤卡组中存在同名卡的怪兽
function c56240989.filter2(c,g)
	return g:IsExists(Card.IsCode,1,c,c:GetCode())
end
-- 效果发动时的目标选择与合法性检测，并设置特殊召唤的操作信息
function c56240989.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取卡组中所有满足条件的怪兽组
		local g=Duel.GetMatchingGroup(c56240989.filter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检查怪兽区域是否有空位，且卡组中是否存在至少一对同名怪兽
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:IsExists(c56240989.filter2,1,nil,g)
	end
	-- 设置特殊召唤2只卡组怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：从卡组特殊召唤2只同名怪兽，将其效果无效化，并注册结束阶段除外的效果
function c56240989.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查怪兽区域空位是否小于2个，若是则无法特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local c=e:GetHandler()
	-- 重新获取卡组中满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c56240989.filter,tp,LOCATION_DECK,0,nil,e,tp)
	local dg=g:Filter(c56240989.filter2,nil,g)
	if dg:GetCount()>=1 then
		local fid=c:GetFieldID()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=dg:Select(tp,1,1,nil)
		local tc1=sg:GetFirst()
		local tc2=dg:Filter(Card.IsCode,tc1,tc1:GetCode()):GetFirst()
		-- 放入特殊召唤第一只怪兽的步骤（表侧表示）
		Duel.SpecialSummonStep(tc1,SUMMON_VALUE_EVOLTILE,tp,tp,false,false,POS_FACEUP)
		-- 放入特殊召唤第二只怪兽的步骤（表侧表示）
		Duel.SpecialSummonStep(tc2,SUMMON_VALUE_EVOLTILE,tp,tp,false,false,POS_FACEUP)
		tc1:RegisterFlagEffect(56240989,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		tc2:RegisterFlagEffect(56240989,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e1,true)
		local e2=e1:Clone()
		tc2:RegisterEffect(e2,true)
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e3,true)
		local e4=e3:Clone()
		tc2:RegisterEffect(e4,true)
		-- 完成特殊召唤的流程
		Duel.SpecialSummonComplete()
		sg:AddCard(tc2)
		sg:KeepAlive()
		-- 结束阶段时从游戏中除外。
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_PHASE+PHASE_END)
		e5:SetCountLimit(1)
		e5:SetLabel(fid)
		e5:SetLabelObject(sg)
		e5:SetCondition(c56240989.rmcon)
		e5:SetOperation(c56240989.rmop)
		-- 注册在结束阶段将特殊召唤的怪兽除外的全局效果
		Duel.RegisterEffect(e5,tp)
	end
end
-- 过滤出带有对应Flag标记的怪兽（即本次效果特殊召唤的怪兽）
function c56240989.rmfilter(c,fid)
	return c:GetFlagEffectLabel(56240989)==fid
end
-- 检查特殊召唤的怪兽是否还存在于场上，若不存在则清理怪兽组并重置除外效果
function c56240989.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c56240989.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段除外效果的具体处理：筛选出场上对应的怪兽并除外
function c56240989.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c56240989.rmfilter,nil,e:GetLabel())
	-- 将目标怪兽表侧表示除外
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end
