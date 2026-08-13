--銀河暴竜
-- 效果：
-- 自己场上的名字带有「银河」的怪兽被选择作为攻击对象时才能发动。这张卡从手卡表侧守备表示特殊召唤。这个效果特殊召唤成功时，可以只用自己场上的名字带有「银河」的怪兽为素材，把1只名字带有「银河」的超量怪兽超量召唤。
function c24658418.initial_effect(c)
	-- 自己场上的名字带有「银河」的怪兽被选择作为攻击对象时才能发动。这张卡从手卡表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24658418,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c24658418.condition)
	e1:SetTarget(c24658418.target)
	e1:SetOperation(c24658418.operation)
	c:RegisterEffect(e1)
	-- 这个效果特殊召唤成功时，可以只用自己场上的名字带有「银河」的怪兽为素材，把1只名字带有「银河」的超量怪兽超量召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24658418,1))  --"超量召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c24658418.spcon)
	e2:SetTarget(c24658418.sptg)
	e2:SetOperation(c24658418.spop)
	c:RegisterEffect(e2)
end
-- 判断攻击对象是否为表侧表示且由我方控制的、名字带有「银河」的怪兽。
function c24658418.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前被选择为攻击对象的卡。
	local at=Duel.GetAttackTarget()
	return at:IsFaceup() and at:IsControler(tp) and at:IsSetCard(0x7b)
end
-- 发动前检查：我方怪兽区是否有空位，且这张卡能否表侧守备表示特殊召唤。
function c24658418.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息，将这张卡标记为本次特殊召唤的对象。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤：若这张卡仍与效果关联，则将其以表侧守备表示特殊召唤。
function c24658418.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧守备表示特殊召唤，SUMMON_VALUE_SELF 表示由自身效果进行的特殊召唤。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 判定本次特殊召唤是否是由这张卡自身效果（第一个效果）成功发动的特殊召唤。
function c24658418.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 超量素材筛选：表侧表示且名字带有「银河」的怪兽，且不能是衍生物。
function c24658418.mfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7b) and not c:IsType(TYPE_TOKEN)
end
-- 额外超量怪兽筛选：名字带有「银河」，且能用给定素材进行超量召唤。
function c24658418.xyzfilter(c,mg)
	return c:IsSetCard(0x7b) and c:IsXyzSummonable(mg)
end
-- 超量召唤效果发动条件：场上有符合条件的素材，且额外卡组存在能用其超量召唤的「银河」超量怪兽。
function c24658418.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取我方场上可作为超量素材的名字带有「银河」的怪兽。
		local g=Duel.GetMatchingGroup(c24658418.mfilter,tp,LOCATION_MZONE,0,nil)
		-- 检查额外卡组是否存在能用上述素材进行超量召唤的名字带有「银河」的超量怪兽。
		return Duel.IsExistingMatchingCard(c24658418.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,g)
	end
	-- 设置操作信息：本次效果涉及从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 超量召唤处理：选择额外卡组中的「银河」超量怪兽，用场上的「银河」怪兽作为素材进行超量召唤。
function c24658418.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上可作为超量素材的名字带有「银河」的怪兽群。
	local g=Duel.GetMatchingGroup(c24658418.mfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取额外卡组中所有能用这些素材进行超量召唤的名字带有「银河」的超量怪兽。
	local xyzg=Duel.GetMatchingGroup(c24658418.xyzfilter,tp,LOCATION_EXTRA,0,nil,g)
	if xyzg:GetCount()>0 then
		-- 弹出选择提示，要求玩家选择要超量召唤的额外怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		-- 用场上的「银河」怪兽作为素材（1至5只），将选择的超量怪兽进行超量召唤。
		Duel.XyzSummon(tp,xyz,g,1,5)
	end
end
