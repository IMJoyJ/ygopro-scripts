--ヴァレルロード・X・ドラゴン
-- 效果：
-- 龙族·暗属性4星怪兽×2
-- ①：超量召唤的这张卡不会成为其他怪兽的效果的对象。
-- ②：1回合1次，把这张卡1个超量素材取除，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力下降600。那之后，可以从自己墓地选1只「枪管」怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段除外。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤，不能直接攻击。
function c6247535.initial_effect(c)
	-- 设置超量召唤手续：需要2只4星的满足mfilter过滤条件的怪兽作为素材。
	aux.AddXyzProcedure(c,c6247535.mfilter,4,2)
	c:EnableReviveLimit()
	-- ①：超量召唤的这张卡不会成为其他怪兽的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c6247535.econ)
	e1:SetValue(c6247535.efilter)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力下降600。那之后，可以从自己墓地选1只「枪管」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(6247535,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCost(c6247535.cost)
	e2:SetTarget(c6247535.target)
	e2:SetOperation(c6247535.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：龙族且暗属性的怪兽。
function c6247535.mfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 效果1的启用条件：自身必须是超量召唤的状态。
function c6247535.econ(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果1的对象免疫过滤：不受自身以外的怪兽效果影响。
function c6247535.efilter(e,re,rp)
	return re:GetHandler()~=e:GetHandler() and re:IsActiveType(TYPE_MONSTER)
end
-- 效果2的发动代价：取除这张卡的1个超量素材。
function c6247535.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果2的发动准备：选择场上1只表侧表示怪兽作为效果对象。
function c6247535.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以作为对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择1只表侧表示怪兽作为效果对象并进行锁定。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 过滤条件：墓地中可以特殊召唤的「枪管」怪兽。
function c6247535.spfilter(c,e,tp)
	return c:IsSetCard(0x10f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果2的效果处理：使对象怪兽攻击力·守备力下降600，之后可选择墓地1只「枪管」怪兽特殊召唤（该怪兽结束阶段除外），并适用特殊召唤与直接攻击限制。
function c6247535.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取之前锁定的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and not tc:IsImmuneToEffect(e) then
		-- 那只怪兽的攻击力·守备力下降600。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		-- 获取自己墓地中满足特殊召唤条件的「枪管」怪兽（受王家之谷影响）。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c6247535.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 检查墓地中是否有符合条件的怪兽且自己场上有空余的怪兽区域。
		if g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 询问玩家是否选择进行特殊召唤。
			and Duel.SelectYesNo(tp,aux.Stringid(6247535,1)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤处理不与降攻守同时进行（用于“那之后”的时点处理）。
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tc=g:Select(tp,1,1,nil):GetFirst()
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			local fid=c:GetFieldID()
			tc:RegisterFlagEffect(6247535,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			-- 这个效果特殊召唤的怪兽在结束阶段除外。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e3:SetCode(EVENT_PHASE+PHASE_END)
			e3:SetCountLimit(1)
			e3:SetLabel(fid)
			e3:SetLabelObject(tc)
			e3:SetCondition(c6247535.rmcon)
			e3:SetOperation(c6247535.rmop)
			-- 注册在结束阶段将该怪兽除外的延迟效果。
			Duel.RegisterEffect(e3,tp)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 注册玩家直到回合结束前不能特殊召唤怪兽的限制效果。
	Duel.RegisterEffect(e1,tp)
	-- 不能直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e2:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册玩家场上怪兽直到回合结束前不能直接攻击的限制效果。
	Duel.RegisterEffect(e2,tp)
end
-- 结束阶段除外效果的触发条件：检查被特殊召唤的怪兽是否仍带有对应的标记（若离场则重置效果）。
function c6247535.rmcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetFlagEffectLabel(6247535)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段除外效果的处理：将该怪兽除外。
function c6247535.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 因效果将目标怪兽表侧表示除外。
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
