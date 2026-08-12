--オッドアイズ・アドバンス・ドラゴン
-- 效果：
-- 这张卡可以把1只5星以上的怪兽解放作上级召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡上级召唤的场合才能发动。对方场上1只怪兽破坏，给与对方那只怪兽的原本攻击力数值的伤害。
-- ②：这张卡战斗破坏怪兽时才能发动。除「异色眼上级龙」外的1只5星以上的怪兽从自己的手卡·墓地守备表示特殊召唤。
function c61391302.initial_effect(c)
	-- 这张卡可以把1只5星以上的怪兽解放作上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61391302,0))  --"把1只5星以上的怪兽解放上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c61391302.otcon)
	e1:SetOperation(c61391302.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- ①：这张卡上级召唤的场合才能发动。对方场上1只怪兽破坏，给与对方那只怪兽的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c61391302.descon)
	e2:SetTarget(c61391302.destg)
	e2:SetOperation(c61391302.desop)
	c:RegisterEffect(e2)
	-- ②：这张卡战斗破坏怪兽时才能发动。除「异色眼上级龙」外的1只5星以上的怪兽从自己的手卡·墓地守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCountLimit(1,61391302)
	-- 设置战斗破坏怪兽时的发动条件（自身在场且与对方怪兽战斗）
	e3:SetCondition(aux.bdocon)
	e3:SetTarget(c61391302.sptg)
	e3:SetOperation(c61391302.spop)
	c:RegisterEffect(e3)
end
-- 过滤自己场上或对方场上表侧表示的5星以上怪兽（作为解放祭品）
function c61391302.cfilter(c,tp)
	return c:IsLevelAbove(5) and (c:IsControler(tp) or c:IsFaceup())
end
-- 上级召唤规则效果的Condition函数，判断是否满足用1只5星以上怪兽解放进行上级召唤的条件
function c61391302.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上所有满足解放条件的5星以上怪兽组
	local mg=Duel.GetMatchingGroup(c61391302.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 检查自身是否为7星以上怪兽，且场上是否存在至少1只满足条件的解放祭品
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤规则效果的Operation函数，执行选择祭品并解放的操作
function c61391302.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上所有满足解放条件的5星以上怪兽组
	local mg=Duel.GetMatchingGroup(c61391302.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 玩家选择1只满足条件的怪兽作为解放祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放选中的怪兽作为上级召唤的祭品
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 检查这张卡是否是通过上级召唤的方式召唤成功
function c61391302.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 破坏与伤害效果的Target函数，检查对方场上是否有怪兽，并设置破坏与伤害的操作信息
function c61391302.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的所有怪兽
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if chk==0 then return #g>0 end
	-- 设置连锁信息，表示该效果会破坏对方场上的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁信息，表示该效果会给与对方玩家伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 破坏与伤害效果的Operation函数，执行破坏对方场上1只怪兽并给与对方其原本攻击力数值伤害的处理
function c61391302.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上的1只怪兽
	local tc=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	-- 如果成功选择怪兽且将其破坏成功
	if tc and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 给与对方被破坏怪兽原本攻击力数值的伤害
		Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
-- 过滤手卡·墓地中除「异色眼上级龙」以外的5星以上、且可以守备表示特殊召唤的怪兽
function c61391302.spfilter(c,e,tp)
	return c:IsLevelAbove(5) and not c:IsCode(61391302) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤效果的Target函数，检查自身怪兽区域是否有空位，以及手卡·墓地中是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息
function c61391302.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地中是否存在至少1只满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c61391302.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁信息，表示该效果会从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 特殊召唤效果的Operation函数，执行从手卡·墓地守备表示特殊召唤1只5星以上怪兽的处理
function c61391302.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡或墓地选择1只满足条件的怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c61391302.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽在自己场上表侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
