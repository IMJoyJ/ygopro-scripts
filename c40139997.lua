--ブラッド・ローズ・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡同调召唤的场合才能发动。双方墓地的卡全部除外。这张卡用「黑蔷薇龙」或植物族同调怪兽为素材作同调召唤的场合，可以再把场上的其他卡全部破坏。
-- ②：要让卡破坏的效果由对方发动时，把这张卡解放才能发动。那个发动无效。那之后，可以从自己的额外卡组·墓地把1只「黑蔷薇龙」特殊召唤。
function c40139997.initial_effect(c)
	-- 注册此卡具有「黑蔷薇龙」的卡名信息
	aux.AddCodeList(c,73580471)
	-- 设置此卡的同调召唤手续为：1只调整+1只调整以外的怪兽
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
	-- 当此卡特殊召唤成功时，记录其为同调召唤且满足特定条件
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(c40139997.matcon)
	e0:SetOperation(c40139997.matop)
	c:RegisterEffect(e0)
	-- 当此卡特殊召唤成功时，检查其同调素材是否包含「黑蔷薇龙」或植物族同调怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(c40139997.valcheck)
	e3:SetLabelObject(e0)
	c:RegisterEffect(e3)
end
-- 判断此卡是否为同调召唤且满足特定条件
function c40139997.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()==1
end
-- 为该卡注册一个标记，表示其已成功同调召唤
function c40139997.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(40139997,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 判断素材是否包含「黑蔷薇龙」或植物族同调怪兽
function c40139997.valfilter(c)
	return c:IsCode(73580471) or c:IsRace(RACE_PLANT) and c:IsSynchroType(TYPE_SYNCHRO)
end
-- 检查此卡的同调素材是否满足条件，并设置标记
function c40139997.valcheck(e,c)
	local mg=c:GetMaterial()
	if mg:IsExists(c40139997.valfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判断此卡是否为同调召唤
function c40139997.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 设置效果目标为双方墓地的卡
function c40139997.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 获取满足条件的卡组
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	-- 设置操作信息为除外满足条件的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 执行效果：除外双方墓地的卡，并在满足条件时破坏场上其他卡
function c40139997.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的卡组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	-- 执行除外操作并判断是否成功
	if g:GetCount()>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 获取场上满足条件的卡组
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
		-- 判断是否满足破坏条件
		if e:GetHandler():GetFlagEffect(40139997)>0 and dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(40139997,2)) then  --"是否把这张卡以外的双方场上的卡全部破坏？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 破坏场上满足条件的卡
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
-- 判断是否满足无效效果的条件
function c40139997.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断此卡是否处于战斗破坏状态或无法无效化连锁
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) or ep==tp then return false end
	-- 获取连锁效果的破坏信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and (tg~=nil or tc>0)
end
-- 设置效果成本为解放此卡
function c40139997.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 执行解放操作
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 设置效果目标为无效化连锁
function c40139997.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为无效化连锁
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 判断是否满足特殊召唤条件
function c40139997.spfilter(c,e,tp)
	if not (c:IsCode(73580471) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		-- 判断额外卡组是否有足够位置
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	else
		-- 判断场上是否有足够位置
		return Duel.GetMZoneCount(tp)>0
	end
end
-- 执行效果：无效连锁并特殊召唤「黑蔷薇龙」
function c40139997.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行无效连锁操作
	if Duel.NegateActivation(ev)
		-- 检查是否存在满足条件的「黑蔷薇龙」
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c40139997.spfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 询问玩家是否特殊召唤「黑蔷薇龙」
		and Duel.SelectYesNo(tp,aux.Stringid(40139997,3)) then  --"是否把「黑蔷薇龙」特殊召唤？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的卡
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c40139997.spfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 执行特殊召唤操作
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
