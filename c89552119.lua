--精霊冥騎－急還馬
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：战斗阶段以外，怪兽区域的这张卡送去墓地。
-- ②：这张卡在墓地存在的场合，自己·对方的战斗阶段开始时，从手卡以及自己场上的表侧表示怪兽之中把1只植物族怪兽送去墓地才能发动。这张卡特殊召唤。那之后，可以从自己或者对方的墓地选1只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽全部在战斗阶段结束时送去墓地。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果
function s.initial_effect(c)
	-- 开启全局标记以支持不入连锁的自我送墓效果检测
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	-- ①：战斗阶段以外，怪兽区域的这张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SELF_TOGRAVE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCondition(s.tgcon)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，自己·对方的战斗阶段开始时，从手卡以及自己场上的表侧表示怪兽之中把1只植物族怪兽送去墓地才能发动。这张卡特殊召唤。那之后，可以从自己或者对方的墓地选1只怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 判断是否处于战斗阶段以外的条件函数
function s.tgcon(e)
	-- 判断当前阶段是否不属于战斗阶段开始到战斗阶段结束之间
	return not (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 过滤手卡或场上表侧表示、可送去墓地且能腾出怪兽区域的植物族怪兽
function s.cfilter(c,tp)
	return c:IsRace(RACE_PLANT) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
		-- 检查将该怪兽送去墓地后，是否能腾出至少一个可用的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 墓地特召效果的发动代价处理函数
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上是否存在可作为发动代价送去墓地的植物族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1只满足条件的植物族怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil,tp)
	-- 将选中的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 墓地特召效果的目标确认与操作信息注册函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤可以被特殊召唤的怪兽
function s.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 墓地特召效果的效果处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于墓地，则将其在自己场上表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local fid=c:GetFieldID()
		local g=Group.FromCards(c)
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 检查自己场上是否有空余的怪兽区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查双方墓地是否存在可以特殊召唤的怪兽（受王家长眠之谷影响）
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp)
			-- 询问玩家是否选择进行后续的特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否选1只怪兽特殊召唤？"
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 玩家从双方墓地选择1只满足条件的怪兽
			local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp):GetFirst()
			-- 若成功选择怪兽，则将其在自己场上表侧表示特殊召唤
			if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
				tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
				g:AddCard(tc)
			end
		end
		g:KeepAlive()
		-- 这个效果特殊召唤的怪兽全部在战斗阶段结束时送去墓地。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(g)
		e1:SetCondition(s.descon)
		e1:SetOperation(s.desop)
		-- 注册在战斗阶段结束时将特召怪兽送去墓地的全局效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤带有特定标识（fid）的怪兽，用于识别由该效果特殊召唤的怪兽
function s.desfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
-- 检查由该效果特殊召唤的怪兽是否依然存在于场上的条件函数，若不存在则重置该效果
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 战斗阶段结束时，将由该效果特殊召唤且仍在场上的怪兽送去墓地的操作函数
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.desfilter,nil,e:GetLabel())
	-- 将这些特殊召唤的怪兽因效果送去墓地
	Duel.SendtoGrave(tg,REASON_EFFECT)
end
