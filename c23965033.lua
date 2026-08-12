--アマゾネス女帝王
-- 效果：
-- 「亚马逊」融合怪兽＋「亚马逊」怪兽
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡融合召唤成功的场合才能发动。从卡组把1只「亚马逊」怪兽特殊召唤。
-- ②：只要这张卡在怪兽区域存在，这张卡以外的自己场上的「亚马逊」卡不会成为对方的效果的对象，不会被对方的效果破坏。
-- ③：「亚马逊女帝」或者「亚马逊女王」为素材作融合召唤的这张卡在同1次的战斗阶段中可以作2次攻击。
function c23965033.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，要求融合素材为1只融合类型的亚马逊怪兽和1只亚马逊融合怪兽
	aux.AddFusionProcFun2(c,c23965033.matfilter,aux.FilterBoolFunction(Card.IsFusionSetCard,0x4),true)
	-- ①：这张卡融合召唤成功的场合才能发动。从卡组把1只「亚马逊」怪兽特殊召唤。
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
	-- ②：只要这张卡在怪兽区域存在，这张卡以外的自己场上的「亚马逊」卡不会成为对方的效果的对象，不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(c23965033.indtg)
	-- 设置效果值为aux.indoval，用于过滤不会被对方效果破坏的卡
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，这张卡以外的自己场上的「亚马逊」卡不会成为对方的效果的对象，不会被对方的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetTarget(c23965033.indtg)
	-- 设置效果值为aux.tgoval，用于过滤不会成为对方效果对象的卡
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
	-- 记录融合素材中包含「亚马逊女帝」或「亚马逊女王」的个数
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_MATERIAL_CHECK)
	e5:SetValue(c23965033.valcheck)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
end
-- 融合素材过滤器，筛选融合类型为融合且种族为亚马逊的怪兽
function c23965033.matfilter(c)
	return c:IsFusionType(TYPE_FUSION) and c:IsFusionSetCard(0x4)
end
-- 效果发动条件，判断此卡是否为融合召唤
function c23965033.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 特殊召唤目标过滤器，筛选种族为亚马逊且可特殊召唤的怪兽
function c23965033.spfilter(c,e,tp)
	return c:IsSetCard(0x4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标设定函数，检查是否有满足条件的怪兽可特殊召唤
function c23965033.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位可特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c23965033.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，选择并特殊召唤符合条件的怪兽
function c23965033.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c23965033.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果目标过滤器，筛选种族为亚马逊且不是此卡的怪兽
function c23965033.indtg(e,c)
	return c:IsSetCard(0x4) and c~=e:GetHandler()
end
-- 检查融合素材中包含「亚马逊女帝」或「亚马逊女王」的个数并记录
function c23965033.valcheck(e,c)
	e:GetLabelObject():SetLabel(c:GetMaterial():FilterCount(Card.IsCode,nil,4591250,15951532))
end
-- 判断此卡是否为融合召唤
function c23965033.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 若融合素材中包含「亚马逊女帝」或「亚马逊女王」则赋予此卡额外一次攻击
function c23965033.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	if ct>=1 then
		-- ③：「亚马逊女帝」或者「亚马逊女王」为素材作融合召唤的这张卡在同1次的战斗阶段中可以作2次攻击。
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
