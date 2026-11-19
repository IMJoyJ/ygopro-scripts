--アマゾネス女帝王
-- 效果：
-- 「亚马逊」融合怪兽＋「亚马逊」怪兽
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡融合召唤成功的场合才能发动。从卡组把1只「亚马逊」怪兽特殊召唤。
-- ②：只要这张卡在怪兽区域存在，这张卡以外的自己场上的「亚马逊」卡不会成为对方的效果的对象，不会被对方的效果破坏。
-- ③：「亚马逊女帝」或者「亚马逊女王」为素材作融合召唤的这张卡在同1次的战斗阶段中可以作2次攻击。
function c23965033.initial_effect(c)
	-- 记录这张卡文本中记述了「亚马逊女帝」(4591250)和「亚马逊女王」(15951532)卡名的事实
	aux.AddCodeList(c,4591250,15951532)
	c:EnableReviveLimit()
	-- 为这张卡注册融合召唤手续：以1只满足matfilter的怪兽和1只「亚马逊」怪兽共2只作为融合素材（允许使用替代素材）
	aux.AddFusionProcFun2(c,c23965033.matfilter,aux.FilterBoolFunction(Card.IsFusionSetCard,0x4),true)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡融合召唤成功的场合才能发动。从卡组把1只「亚马逊」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23965033,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,23965033)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c23965033.spcon)
	e1:SetTarget(c23965033.sptg)
	e1:SetOperation(c23965033.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，这张卡以外的自己场上的「亚马逊」卡不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(c23965033.indtg)
	-- 设置效果抗性的值函数为aux.indoval，限定仅不会被对方发动的效果破坏
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，这张卡以外的自己场上的「亚马逊」卡不会成为对方的效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetTarget(c23965033.indtg)
	-- 设置对象抗性的值函数为aux.tgoval，限定仅不会成为对方效果的对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ③：「亚马逊女帝」或者「亚马逊女王」为素材作融合召唤的这张卡在同1次的战斗阶段中可以作2次攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c23965033.condition)
	e4:SetOperation(c23965033.operation)
	c:RegisterEffect(e4)
	-- ③：「亚马逊女帝」或者「亚马逊女王」为素材作融合召唤的这张卡
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_MATERIAL_CHECK)
	e5:SetValue(c23965033.valcheck)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
end
-- 融合素材过滤函数，筛选「亚马逊」字段的融合怪兽
function c23965033.matfilter(c)
	return c:IsFusionType(TYPE_FUSION) and c:IsFusionSetCard(0x4)
end
-- ①效果的Condition函数，检查这张卡是否是通过融合召唤成功登场的
function c23965033.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤函数，筛选「亚马逊」字段且可以被正常特殊召唤的怪兽
function c23965033.spfilter(c,e,tp)
	return c:IsSetCard(0x4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的Target函数，检测怪兽区空格及卡组存在可特招的「亚马逊」怪兽，并设置特殊召唤操作信息
function c23965033.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测时，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组是否存在至少1只满足spfilter条件可特殊召唤的「亚马逊」怪兽
		and Duel.IsExistingMatchingCard(c23965033.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，声明将从自己卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的Operation函数，从自己卡组选择1只「亚马逊」怪兽以表侧表示特殊召唤
function c23965033.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己怪兽区没有可用空格则终止效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向自己发送选择提示信息：“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己在自己卡组中选择1只满足spfilter条件的「亚马逊」怪兽
	local g=Duel.SelectMatchingCard(tp,c23965033.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的Target过滤函数，判断场上受保护的卡是否为这张卡以外的「亚马逊」卡
function c23965033.indtg(e,c)
	return c:IsSetCard(0x4) and c~=e:GetHandler()
end
-- 素材检查值函数，统计融合素材中「亚马逊女帝」或「亚马逊女王」的数量并保存到e4的Label中
function c23965033.valcheck(e,c)
	e:GetLabelObject():SetLabel(c:GetMaterial():FilterCount(Card.IsCode,nil,4591250,15951532))
end
-- ③效果付与判断的Condition函数，检查这张卡是否是通过融合召唤出场的
function c23965033.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- ③效果的诱发处理函数，若融合素材检查记录的数量大于等于1，则为这张卡付与可追加1次攻击（即作2次攻击）的效果
function c23965033.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	if ct>=1 then
		-- 在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(23965033,1))  --"可以作2次攻击"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
