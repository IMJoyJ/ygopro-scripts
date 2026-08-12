--Sin パラドクス・ドラゴン
-- 效果：
-- 「罪 平行齿轮」＋调整以外的「罪」怪兽1只
-- ①：「罪 矛盾龙」在场上只能有1只表侧表示存在。
-- ②：这张卡同调召唤成功时，以自己或者对方的墓地1只同调怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
-- ③：场上没有「罪 世界」存在的场合这张卡破坏。
function c8310162.initial_effect(c)
	-- 注册卡片效果中记载了「罪 世界」的卡片密码
	aux.AddCodeList(c,27564031)
	-- 注册同调素材中记载了「罪 平行齿轮」的卡片密码
	aux.AddMaterialCodeList(c,74509280)
	-- 添加同调召唤手续：以「罪 平行齿轮」为调整，调整以外的「罪」怪兽1只
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsCode,74509280),aux.NonTuner(Card.IsSetCard,0x23),1,1)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,1,8310162)
	-- ②：这张卡同调召唤成功时，以自己或者对方的墓地1只同调怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8310162,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c8310162.spcon)
	e1:SetTarget(c8310162.sptg)
	e1:SetOperation(c8310162.spop)
	c:RegisterEffect(e1)
	-- ③：场上没有「罪 世界」存在的场合这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c8310162.descon)
	c:RegisterEffect(e2)
end
-- 自身破坏效果的条件判断函数
function c8310162.descon(e)
	-- 检查场上是否存在「罪 世界」，若不存在则返回true（触发破坏）
	return not Duel.IsEnvironment(27564031)
end
-- 特殊召唤效果的发动条件：这张卡同调召唤成功且在怪兽区域表侧表示存在
function c8310162.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetHandler():IsLocation(LOCATION_MZONE)
end
-- 过滤墓地中可以特殊召唤的同调怪兽
function c8310162.spfilter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备与目标选择
function c8310162.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c8310162.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方墓地是否存在可以特殊召唤的同调怪兽
		and Duel.IsExistingTarget(c8310162.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择双方墓地1只符合条件的同调怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c8310162.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置效果处理信息：包含特殊召唤分类，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的具体处理函数
function c8310162.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
