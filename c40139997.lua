--ブラッド・ローズ・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡同调召唤的场合才能发动。双方墓地的卡全部除外。这张卡用「黑蔷薇龙」或植物族同调怪兽为素材作同调召唤的场合，可以再把场上的其他卡全部破坏。
-- ②：要让卡破坏的效果由对方发动时，把这张卡解放才能发动。那个发动无效。那之后，可以从自己的额外卡组·墓地把1只「黑蔷薇龙」特殊召唤。
function c40139997.initial_effect(c)
	-- 记录这张卡上记载着「黑蔷薇龙」（卡号73580471），用于相关检索与参照。
	aux.AddCodeList(c,73580471)
	-- 添加同调召唤手续：调整（无额外限制）＋调整以外的怪兽1只以上，对应效果原文的‘调整＋调整以外的怪兽1只以上’。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。双方墓地的卡全部除外。这张卡用「黑蔷薇龙」或植物族同调怪兽为素材作同调召唤的场合，可以再把场上的其他卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40139997,0))  --"双方墓地的卡全部除外"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c40139997.rmcon)
	e1:SetTarget(c40139997.rmtg)
	e1:SetOperation(c40139997.rmop)
	c:RegisterEffect(e1)
	-- ②：要让卡破坏的效果由对方发动时，把这张卡解放才能发动。那个发动无效。那之后，可以从自己的额外卡组·墓地把1只「黑蔷薇龙」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40139997,1))  --"发动无效"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c40139997.discon)
	e2:SetCost(c40139997.discost)
	e2:SetTarget(c40139997.distg)
	e2:SetOperation(c40139997.disop)
	c:RegisterEffect(e2)
	-- 这张卡用「黑蔷薇龙」或植物族同调怪兽为素材作同调召唤的场合
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(c40139997.matcon)
	e0:SetOperation(c40139997.matop)
	c:RegisterEffect(e0)
	-- 这张卡用「黑蔷薇龙」或植物族同调怪兽为素材作同调召唤的场合
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(c40139997.valcheck)
	e3:SetLabelObject(e0)
	c:RegisterEffect(e3)
end
-- 辅助效果条件：这张卡同调召唤成功，且素材检查标记为1（即素材中含有「黑蔷薇龙」或植物族同调怪兽）。
function c40139997.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()==1
end
-- 满足素材条件时，为这张卡登记一个标志（40139997），用于后续效果判断是否使用过特殊素材。
function c40139997.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(40139997,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 素材过滤器：判定素材是否为「黑蔷薇龙」（卡号73580471），或是植物族同调怪兽。
function c40139997.valfilter(c)
	return c:IsCode(73580471) or c:IsRace(RACE_PLANT) and c:IsSynchroType(TYPE_SYNCHRO)
end
-- 素材检查：获取实际同调召唤使用的素材，若存在满足条件的素材则将标记设为1，否则设为0，供后续效果使用。
function c40139997.valcheck(e,c)
	local mg=c:GetMaterial()
	if mg:IsExists(c40139997.valfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 效果①的发动条件：这张卡以同调召唤方式成功召唤。
function c40139997.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果①发动时的目标处理：确认双方墓地存在可除外的卡，并获取双方墓地所有可除外的卡，设置除外操作信息。
function c40139997.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：双方墓地存在至少1张可以除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 获取双方墓地所有可以除外的卡，作为操作信息中记录的目标组。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	-- 设置连锁的操作信息：本效果将执行除外，目标为双方墓地所有可除外的卡，数量为其总数。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果①处理：除外双方墓地可除外的卡；若除外成功且这张卡拥有特殊素材标记，则询问玩家是否将双方场上其他卡全部破坏，确认后执行破坏。
function c40139997.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时重新获取双方墓地可除外的卡（过滤王家长眠之谷等影响），用于实际除外。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	-- 若存在可除外的卡且除外操作成功，则继续进行后续判断。
	if g:GetCount()>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 获取这张卡以外的双方场上所有卡，作为可能被破坏的目标组。
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
		-- 确认这张卡确实是用「黑蔷薇龙」或植物族同调怪兽为素材作同调召唤（有对应标记），且场上有其他卡，且玩家选择‘是’，才执行破坏。
		if e:GetHandler():GetFlagEffect(40139997)>0 and dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(40139997,2)) then  --"是否把这张卡以外的双方场上的卡全部破坏？"
			-- 中断当前效果处理，使除外与后续破坏视为不同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 将双方场上这张卡以外的所有卡以效果破坏。
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
-- 效果②的发动条件：对方发动了包含破坏卡的效果，该连锁可以被无效，且这张卡未被战斗破坏。
function c40139997.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 若这张卡处于被战斗破坏状态，或该连锁不能被无效，或发动者是自己，则不能发动此效果。
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) or ep==tp then return false end
	-- 获取对方连锁中关于‘破坏’的操作信息，取出是否存在破坏效果、目标组及数量等数据。
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and (tg~=nil or tc>0)
end
-- 效果②的代价处理：检查这张卡是否可解放，若可则解放作为发动代价。
function c40139997.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡解放作为效果的发动代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果②发动时的目标处理：本效果不取对象，设置操作信息为无效正在发动的效果。
function c40139997.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将无效对象设为正在发动的连锁中的效果（eg），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 筛选可特殊召唤的「黑蔷薇龙」：必须是卡号73580471且满足特殊召唤条件；在额外卡组时需有额外怪兽区空格，在墓地时需有主要怪兽区空格。
function c40139997.spfilter(c,e,tp)
	if not (c:IsCode(73580471) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		-- 检查从额外卡组特殊召唤「黑蔷薇龙」时是否有可用的额外怪兽区空格。
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	else
		-- 检查从墓地特殊召唤「黑蔷薇龙」时是否有可用的主要怪兽区空格。
		return Duel.GetMZoneCount(tp)>0
	end
end
-- 效果②处理：无效对方的发动；成功后若自己的额外卡组或墓地存在可特殊召唤的「黑蔷薇龙」且玩家选择是，则选1只特殊召唤。
function c40139997.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效对方发动的那个效果，若无效成功则继续后续处理。
	if Duel.NegateActivation(ev)
		-- 检查自己的额外卡组或墓地是否存在满足特殊召唤条件的「黑蔷薇龙」。
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c40139997.spfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 询问玩家是否从额外卡组或墓地特殊召唤「黑蔷薇龙」。
		and Duel.SelectYesNo(tp,aux.Stringid(40139997,3)) then  --"是否把「黑蔷薇龙」特殊召唤？"
		-- 中断当前效果处理，使发动无效与后续特殊召唤视为不同时处理。
		Duel.BreakEffect()
		-- 向玩家显示选择提示，要求选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从自己的额外卡组或墓地选择1只满足条件的「黑蔷薇龙」用于特殊召唤。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c40139997.spfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 将选择的「黑蔷薇龙」以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
