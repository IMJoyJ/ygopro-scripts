--アーマード・シャーク
-- 效果：
-- 这个卡名在规则上也当作「铠装超量」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：从额外卡组把1只水属性超量怪兽送去墓地，以持有和那个阶级数值相同等级的自己墓地1只鱼族怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：对方回合，这张卡在墓地存在的场合，以自己场上1只水属性超量怪兽为对象才能发动。这张卡当作攻击力上升500的装备魔法卡使用给那只怪兽装备。
local s,id,o=GetID()
-- 注册铠装鲨的两个效果：e1为①的起动效果（从额外卡组把水属性超量怪兽送墓，选墓地对应等级的鱼族怪兽特殊召唤），e2为②的诱发即时效果（对方回合在墓地，作为攻击力上升500的装备魔法卡给自己水属性超量怪兽装备）。
function s.initial_effect(c)
	-- 这个卡名在规则上也当作「铠装超量」卡使用。这个卡名的①的效果1回合各能使用1次。①：从额外卡组把1只水属性超量怪兽送去墓地，以持有和那个阶级数值相同等级的自己墓地1只鱼族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合各能使用1次。②：对方回合，这张卡在墓地存在的场合，以自己场上1只水属性超量怪兽为对象才能发动。这张卡当作攻击力上升500的装备魔法卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"装备效果"
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.eqcon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
-- 费用判定函数：通过e:SetLabel(100)设立标记，表明发动时已通过初步合法性检查；实际送墓cost在target步骤选择并执行，chk==0时直接允许发动。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 额外卡组送墓候选的过滤器：要求是水属性超量怪兽且可作为cost送墓，同时墓地存在一只可特殊召唤的鱼族怪兽，其等级等于这张超量怪兽的阶级。
function s.tgfilter(c,e,tp)
	-- 判定该额外怪兽可作cost送墓且是水属性超量怪兽，并调用Duel.IsExistingTarget确认墓地有等级等于这张卡阶级的鱼族特召对象。
	return c:IsAbleToGraveAsCost() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ) and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetRank())
end
-- 墓地对象的过滤器：要求对象为表侧表示（代码如此）、等级等于指定阶级数值rk、鱼族，且可被该效果特殊召唤。
function s.spfilter(c,e,tp,rk)
	return c:IsFaceup() and c:IsLevel(rk) and c:IsRace(RACE_FISH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动目标处理：确认已通过费用标记，检查额外卡组有无可送墓的超量怪兽；选择额外怪兽送墓并记录其阶级，再选择墓地对应等级的鱼族怪兽作为对象，设置特殊召唤操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp,e:GetLabel()) end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查从额外卡组是否存在至少1张满足tgfilter的水属性超量怪兽，作为效果可发动的条件。
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	-- 向操作者显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从额外卡组选择1张满足tgfilter的水属性超量怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	-- 将选择的额外卡组怪兽送去墓地，作为效果发动的代价（REASON_COST）。
	Duel.SendtoGrave(g,REASON_COST)
	local rk=g:GetFirst():GetRank()
	e:SetLabel(rk)
	-- 提示操作者选择要特殊召唤的墓地怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足spfilter（等级等于记录阶级rk、鱼族、可特召）的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,rk)
	-- 设置连锁处理信息为特殊召唤，目标为刚才选择的怪兽，用于连锁检测和后续处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：取得对象怪兽，确认其仍与效果关联且不受王家长眠之谷影响后，以表侧表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的墓地鱼族怪兽对象。
	local tc=Duel.GetFirstTarget()
	-- 判断该对象仍与效果关联（未中途离场等），并且通过王家长眠之谷的过滤，确保可以特殊召唤。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将目标鱼族怪兽以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：当前回合玩家不是自己，即只在对方回合可以发动。
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为对方的判断结果。
	return Duel.GetTurnPlayer()==1-tp
end
-- ②效果装备对象的过滤器：自己场上的表侧表示水属性超量怪兽。
function s.eqfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ)
end
-- ②效果的目标处理：检查魔陷区有可用空位且自己场上有可装备的水属性超量怪兽；选择1只作为装备对象。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	-- 判定自己魔陷区是否有空位，以确保这张卡能作为装备卡放置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且检查自己场上是否存在表侧表示的水属性超量怪兽可作为装备对象。
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示操作者选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从自己场上选择1只表侧表示的水属性超量怪兽作为装备对象。
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：该效果将自己这张卡作为装备卡装备（CATEGORY_EQUIP）。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置操作信息：这张卡将从墓地离开，以便王家长眠之谷等效果进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果处理：满足条件后，将这张卡装备给目标怪兽，并赋予装备限制和攻击力上升500的效果。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得②效果选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 综合判定：此卡仍与效果关联且不受王谷影响、对象怪兽仍表侧且与效果关联且是怪兽，才能继续装备。
	if aux.NecroValleyFilter()(c) and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		-- 执行装备操作，将这张卡作为装备魔法卡装备给目标怪兽；失败则终止处理。
		if not Duel.Equip(tp,c,tc) then return end
		-- 对应②效果原文中的“给那只怪兽装备”：设置EFFECT_EQUIP_LIMIT，使这张装备卡只能装备给那只对象怪兽。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 对应②效果原文中的“攻击力上升500”：设置EFFECT_UPDATE_ATTACK，上升500攻击力。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 装备限制函数：只有当前装备怪兽等于当初选择的对象时，装备条件才成立。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
