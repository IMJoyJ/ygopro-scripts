--真竜凰騎マリアムネP
-- 效果：
-- 这张卡表侧表示上级召唤的场合，可以作为怪兽的代替而把自己场上的永续魔法·永续陷阱卡解放。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合才能发动。这张卡以外的自己的手卡·场上（表侧表示）1张「真龙」卡破坏，这张卡在自己或对方的场上特殊召唤。
-- ②：这张卡从手卡召唤·特殊召唤的场合发动。从自己卡组上面把4张卡除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含上级召唤代替解放效果、①效果（手卡起动特殊召唤）和②效果（召唤·特殊召唤成功时除外卡组卡片）。
function s.initial_effect(c)
	-- 这张卡表侧表示上级召唤的场合，可以作为怪兽的代替而把自己场上的永续魔法·永续陷阱卡解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	-- 过滤可以作为代替解放的卡片类型为永续魔法或永续陷阱。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_CONTINUOUS))
	e1:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e1)
	-- ①：这张卡在手卡存在的场合才能发动。这张卡以外的自己的手卡·场上（表侧表示）1张「真龙」卡破坏，这张卡在自己或对方的场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.spstg)
	e2:SetOperation(s.spsop)
	c:RegisterEffect(e2)
	-- ②：这张卡从手卡召唤·特殊召唤的场合发动。从自己卡组上面把4张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.rmcon)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 过滤手卡或场上可破坏的「真龙」卡，并检查破坏后是否能将自身特殊召唤到自己或对方场上。
function s.desfilter(c,tp,sc,e,chk)
	return c:IsFaceupEx() and c:IsSetCard(0xf9) and
		(not chk
			-- 检查破坏该卡后，自己场上是否有空余怪兽区域可以特殊召唤自身。
			or Duel.GetMZoneCount(tp,c)>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 检查对方场上是否有空余怪兽区域可以特殊召唤自身。
			or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp))
end
-- ①效果的发动准备阶段，检查是否存在可破坏的卡且自身能否特殊召唤，并设置破坏与特殊召唤的操作信息。
function s.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取手卡或场上满足破坏且能完成特殊召唤条件的「真龙」卡组。
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,c,tp,c,e,true)
	if chk==0 then return #g>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息：破坏1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁处理中的操作信息：特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的实际处理：选择并破坏1张「真龙」卡，然后选择将自身特殊召唤到自己或对方场上。
function s.spsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local dg=nil
	-- 检查是否存在破坏后仍能满足特殊召唤条件的卡。
	if Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,aux.ExceptThisCard(e),tp,c,e,true) then
		-- 若存在，则获取破坏后能满足特殊召唤条件的卡片组。
		dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,aux.ExceptThisCard(e),tp,c,e,true)
	else
		-- 若不存在（可能由于连锁中场地变化），则获取仅满足破坏条件的卡片组。
		dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,aux.ExceptThisCard(e),tp,c,e,false)
	end
	-- 玩家选择1张要破坏的卡。
	local g=dg:Select(tp,1,1,aux.ExceptThisCard(e))
	if g:FilterCount(Card.IsLocation,nil,LOCATION_ONFIELD)>0 then
		-- 选中场上的卡片时，向双方玩家展示被选中的卡。
		Duel.HintSelection(g)
	end
	-- 尝试破坏选中的卡，若成功破坏则继续处理。
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		-- 立即刷新场地信息，以准确计算怪兽区域数量。
		Duel.AdjustAll()
		if not c:IsRelateToChain() or (not c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)) then return end
		-- 检查自己场上是否有空位且自身能否在自己场上特殊召唤。
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查对方场上是否有空位且自身能否在对方场上特殊召唤。
		local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
		-- 让玩家选择将自身特殊召唤到自己场上还是对方场上。
		local toplayer=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),tp},  --"在自己场上特殊召唤"
			{b2,aux.Stringid(id,3),1-tp})  --"在对方场上特殊召唤"
		if toplayer~=nil then
			-- 将自身以表侧表示特殊召唤到所选玩家的场上。
			Duel.SpecialSummon(c,0,tp,toplayer,false,false,POS_FACEUP)
		else
			-- 若双方场上都没有空余怪兽区域。
			if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then
				-- 根据规则将无法特殊召唤的自身送去墓地。
				Duel.SendtoGrave(c,REASON_RULE)
			end
		end
	end
end
-- ②效果的发动条件：检查此卡是否是从手卡召唤·特殊召唤。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_HAND)
end
-- ②效果的发动准备阶段，获取卡组最上方的4张卡并设置除外的操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己卡组最上方的4张卡。
	local rg=Duel.GetDecktopGroup(tp,4)
	-- 设置连锁处理中的操作信息：除外这4张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,4,0,0)
end
-- ②效果的实际处理：将自己卡组最上方的4张卡除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己卡组最上方的4张卡。
	local rg=Duel.GetDecktopGroup(tp,4)
	-- 禁用接下来的洗牌检测，防止因从卡组取出卡片而自动洗牌。
	Duel.DisableShuffleCheck()
	-- 以表侧表示除外这4张卡。
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
end
