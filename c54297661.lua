--ディメンション・リフレクター
-- 效果：
-- ①：把自己场上2只怪兽除外，以对方场上1只表侧表示怪兽为对象才能把这张卡发动。这张卡发动后变成持有和作为对象的怪兽的攻击力相同数值的攻击力·守备力的效果怪兽（魔法师族·暗·4星·攻/守?）在怪兽区域攻击表示特殊召唤。这张卡也当作陷阱卡使用。
-- ②：这张卡的效果让这张卡特殊召唤成功的场合发动。给与对方这张卡的攻击力数值的伤害。
function c54297661.initial_effect(c)
	-- ①：把自己场上2只怪兽除外，以对方场上1只表侧表示怪兽为对象才能把这张卡发动。这张卡发动后变成持有和作为对象的怪兽的攻击力相同数值的攻击力·守备力的效果怪兽（魔法师族·暗·4星·攻/守?）在怪兽区域攻击表示特殊召唤。这张卡也当作陷阱卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c54297661.cost)
	e1:SetTarget(c54297661.target)
	e1:SetOperation(c54297661.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡的效果让这张卡特殊召唤成功的场合发动。给与对方这张卡的攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54297661,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c54297661.damcon)
	e2:SetTarget(c54297661.damtg)
	e2:SetOperation(c54297661.damop)
	c:RegisterEffect(e2)
end
-- 过滤函数：过滤自己主要怪兽区域的怪兽（不含额外怪兽区域）。
function c54297661.mzfilter(c,tp)
	return c:GetSequence()<5
end
-- 发动代价：检查并从自己场上选择2只怪兽除外（需考虑特殊召唤所需的怪兽区域空格）。
function c54297661.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上可以作为代价除外的怪兽组。
	local rg=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_MZONE,0,nil)
	-- 获取自己场上主要怪兽区域的可用空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=-ft+1
	if chk==0 then return ft>-2 and rg:GetCount()>1 and (ft>0 or rg:IsExists(c54297661.mzfilter,ct,nil,tp)) end
	local g=nil
	if ft>0 then
		-- 提示玩家选择要除外的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		g=rg:Select(tp,2,2,nil)
	elseif ft==0 then
		-- 提示玩家选择要除外的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		g=rg:FilterSelect(tp,c54297661.mzfilter,1,1,nil,tp)
		-- 提示玩家选择要除外的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local g2=rg:Select(tp,1,1,g:GetFirst())
		g:Merge(g2)
	else
		-- 提示玩家选择要除外的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		g=rg:FilterSelect(tp,c54297661.mzfilter,2,2,nil,tp)
	end
	-- 将选中的怪兽表侧表示除外作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数：过滤对方场上表侧表示，且其攻击力·守备力等数值能让这张卡作为陷阱怪兽特殊召唤的怪兽。
function c54297661.filter(c,tp)
	return c:IsFaceup()
		-- 判定玩家是否能将这张卡作为对应攻守、等级、种族、属性的陷阱怪兽在自己场上攻击表示特殊召唤。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,54297661,0,TYPES_EFFECT_TRAP_MONSTER,c:GetAttack(),c:GetDefense(),4,RACE_SPELLCASTER,ATTRIBUTE_DARK,POS_FACEUP_ATTACK)
end
-- 效果发动时的目标选择与合法性检查。
function c54297661.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c54297661.filter(chkc,tp) end
	if chk==0 then return e:IsCostChecked()
		-- 判定自己场上的怪兽区域空格数是否满足特殊召唤条件（由于cost会除外2只怪兽，因此在cost检查前，场上空格数大于-2即可）。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>-2
		-- 判定对方场上是否存在可以作为对象的表侧表示怪兽。
		and Duel.IsExistingTarget(c54297661.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只表侧表示怪兽作为对象并将其设为效果对象。
	Duel.SelectTarget(tp,c54297661.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置连锁信息，表明此效果包含将这张卡特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡作为陷阱怪兽，以和对象怪兽相同的攻击力·守备力在自己场上攻击表示特殊召唤。
function c54297661.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if not (c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	local atk=tc:GetAttack()
	local def=tc:GetDefense()
	-- 再次检查玩家当前是否仍能将这张卡作为陷阱怪兽特殊召唤。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,54297661,0,TYPES_EFFECT_TRAP_MONSTER,atk,def,4,RACE_SPELLCASTER,ATTRIBUTE_DARK,POS_FACEUP_ATTACK) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 尝试将这张卡以自身效果特殊召唤到自己场上（攻击表示，不检查召唤条件，不限制特殊召唤）。
	if Duel.SpecialSummonStep(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP_ATTACK) then
		-- 变成持有和作为对象的怪兽的攻击力相同数值的攻击力·守备力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		e2:SetValue(def)
		c:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程。
	Duel.SpecialSummonComplete()
end
-- 触发条件：这张卡通过自身效果特殊召唤成功。
function c54297661.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 效果目标：确定给与对方伤害的数值并设置连锁信息。
function c54297661.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=e:GetHandler():GetAttack()
	-- 设置伤害的对象玩家为对方。
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害的数值为这张卡的攻击力。
	Duel.SetTargetParam(dam)
	-- 设置连锁信息，表明此效果包含给与对方伤害的操作。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理：给与对方这张卡攻击力数值的效果伤害。
function c54297661.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取要给与伤害的目标玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 给与目标玩家这张卡当前攻击力数值的效果伤害。
	Duel.Damage(p,e:GetHandler():GetAttack(),REASON_EFFECT)
end
