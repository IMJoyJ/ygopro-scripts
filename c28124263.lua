--D・キャメラン
-- 效果：
-- 这张卡得到这张卡的表示形式的以下效果。
-- ●攻击表示：这张卡被战斗破坏时，可以把自己的手卡·墓地存在的「变形斗士·照相机」以外的1只名字带有「变形斗士」的4星以下的怪兽在自己场上特殊召唤。
-- ●守备表示：只要这张卡在场上表侧表示存在，名字带有「变形斗士」的怪兽不能成为魔法·陷阱·效果怪兽的效果的对象。
function c28124263.initial_effect(c)
	-- 这张卡得到这张卡的表示形式的以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_LEAVE_FIELD_P)
	e1:SetOperation(c28124263.check)
	c:RegisterEffect(e1)
	-- ●攻击表示：这张卡被战斗破坏时，可以把自己的手卡·墓地存在的「变形斗士·照相机」以外的1只名字带有「变形斗士」的4星以下的怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28124263,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c28124263.cona)
	e2:SetTarget(c28124263.tga)
	e2:SetOperation(c28124263.opa)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ●守备表示：只要这张卡在场上表侧表示存在，名字带有「变形斗士」的怪兽不能成为魔法·陷阱·效果怪兽的效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCondition(c28124263.cond)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置该效果的适用对象为场上所有名字带有「变形斗士」（0x26）的怪兽，使它们成为“不能成为效果对象”的保护目标。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x26))
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 该连续效果在卡片离场前触发，记录这张卡当前是否为表侧攻击表示且未被无效：若是则Label置1，否则置0，供攻击表示诱发效果判断发动条件。
function c28124263.check(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsDisabled() and c:IsAttackPos() then e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 攻击表示诱发效果的发动条件：判定e1记录的Label为1，即这张卡在被战斗破坏离场时处于攻击表示，满足“这张卡被战斗破坏时”且为攻击表示形态。
function c28124263.cona(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()==1
end
-- 筛选可特殊召唤的怪兽：必须是4星以下、卡名带有「变形斗士」（0x26）、不是「变形斗士·照相机」自身、且能被玩家tp特殊召唤（不检查召唤条件，但检查苏生限制）。
function c28124263.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x26) and not c:IsCode(28124263)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果发动的合法性检查：自己的主要怪兽区有空位，并且手卡·墓地中存在满足filter条件的「变形斗士」怪兽，满足才可发动攻击表示效果。
function c28124263.tga(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用的空格，这是能否特殊召唤的前提条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡·墓地是否存在至少1张满足filter条件的「变形斗士」4星以下怪兽（且不是「变形斗士·照相机」），作为特殊召唤的候选对象。
		and Duel.IsExistingMatchingCard(c28124263.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 登记本次操作信息：效果类别为特殊召唤，预计从手卡·墓地特殊召唤1只怪兽（具体对象处理时确定），供其他卡的效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理：若场上无空位则直接终止；否则提示玩家选择1只符合条件的怪兽，从手卡·墓地特殊召唤到己方场上表侧攻击表示（不取对象）。
function c28124263.opa(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己主要怪兽区是否有空位，避免因处理时场地变化导致特殊召唤无法进行；无空位则处理失败。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向发动玩家显示“请选择要特殊召唤的卡”的提示信息，引导玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡·墓地中选择1张满足filter条件且不受「王家长眠之谷」影响的「变形斗士」怪兽（处理时选择，不取对象）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c28124263.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将选中的怪兽以表侧攻击表示特殊召唤到己方场上，无视召唤条件但遵守苏生限制；若没有选到则不会特殊召唤。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
-- 守备表示效果的适用条件：仅当这张卡在场上处于表侧守备表示时，才发动“名字带有「变形斗士」的怪兽不能成为效果对象”的永续效果。
function c28124263.cond(e)
	return e:GetHandler():IsDefensePos()
end
