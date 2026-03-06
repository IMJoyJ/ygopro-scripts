--D・キャメラン
-- 效果：
-- 这张卡得到这张卡的表示形式的以下效果。
-- ●攻击表示：这张卡被战斗破坏时，可以把自己的手卡·墓地存在的「变形斗士·照相机」以外的1只名字带有「变形斗士」的4星以下的怪兽在自己场上特殊召唤。
-- ●守备表示：只要这张卡在场上表侧表示存在，名字带有「变形斗士」的怪兽不能成为魔法·陷阱·效果怪兽的效果的对象。
function c28124263.initial_effect(c)
	-- 攻击表示：这张卡被战斗破坏时，可以把自己的手卡·墓地存在的「变形斗士·照相机」以外的1只名字带有「变形斗士」的4星以下的怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_LEAVE_FIELD_P)
	e1:SetOperation(c28124263.check)
	c:RegisterEffect(e1)
	-- 守备表示：只要这张卡在场上表侧表示存在，名字带有「变形斗士」的怪兽不能成为魔法·陷阱·效果怪兽的效果的对象。
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
	-- 效果作用
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCondition(c28124263.cond)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果目标为名字带有「变形斗士」的怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x26))
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 记录该卡是否处于攻击表示状态
function c28124263.check(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsDisabled() and c:IsAttackPos() then e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 判断该卡是否处于攻击表示状态以触发效果
function c28124263.cona(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()==1
end
-- 过滤满足条件的怪兽：等级4以下、名字带有「变形斗士」、不是此卡本身、可特殊召唤
function c28124263.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x26) and not c:IsCode(28124263)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 判断是否满足特殊召唤条件：场上存在空位且手卡或墓地存在符合条件的怪兽
function c28124263.tga(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c28124263.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：准备特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 执行特殊召唤操作：选择符合条件的怪兽并特殊召唤
function c28124263.opa(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c28124263.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将选中的怪兽特殊召唤到场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
-- 判断该卡是否处于守备表示状态
function c28124263.cond(e)
	return e:GetHandler():IsDefensePos()
end
