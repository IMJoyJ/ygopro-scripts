--調弦の魔術師
-- 效果：
-- ←8 【灵摆】 8→
-- ①：只要这张卡在灵摆区域存在，自己场上的怪兽的攻击力·守备力上升自己的额外卡组的表侧的「魔术师」灵摆怪兽种类×100。
-- 【怪兽效果】
-- 这张卡不能从额外卡组特殊召唤，把这张卡作为融合·同调·超量召唤的素材的场合，其他素材必须全部是「魔术师」灵摆怪兽。这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡从手卡灵摆召唤时才能发动。从卡组把「调弦之魔术师」以外的1只「魔术师」灵摆怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化，从场上离开的场合除外。
function c73941492.initial_effect(c)
	-- 开启全局标记以支持“调弦之魔术师”的素材限制检测
	Duel.EnableGlobalFlag(GLOBALFLAG_TUNE_MAGICIAN)
	-- 注册灵摆怪兽的灵摆召唤和灵摆卡发动等基本属性
	aux.EnablePendulumAttribute(c)
	-- ①：只要这张卡在灵摆区域存在，自己场上的怪兽的攻击力·守备力上升自己的额外卡组的表侧的「魔术师」灵摆怪兽种类×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(c73941492.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- 这张卡不能从额外卡组特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为始终不可行（即不能特殊召唤）
	e3:SetValue(aux.FALSE)
	c:RegisterEffect(e3)
	-- 把这张卡作为融合·同调·超量召唤的素材的场合，其他素材必须全部是「魔术师」灵摆怪兽。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_TUNER_MATERIAL_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetTarget(c73941492.synlimit)
	c:RegisterEffect(e4)
	-- 把这张卡作为融合·同调·超量召唤的素材的场合，其他素材必须全部是「魔术师」灵摆怪兽。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_TUNE_MAGICIAN_F)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetValue(c73941492.fuslimit)
	c:RegisterEffect(e5)
	-- 把这张卡作为融合·同调·超量召唤的素材的场合，其他素材必须全部是「魔术师」灵摆怪兽。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_TUNE_MAGICIAN_X)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e6:SetValue(c73941492.xyzlimit)
	c:RegisterEffect(e6)
	-- ①：这张卡从手卡灵摆召唤时才能发动。从卡组把「调弦之魔术师」以外的1只「魔术师」灵摆怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化，从场上离开的场合除外。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(73941492,0))
	e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	e7:SetCountLimit(1,73941492)
	e7:SetCondition(c73941492.spcon)
	e7:SetTarget(c73941492.sptg)
	e7:SetOperation(c73941492.spop)
	c:RegisterEffect(e7)
end
-- 限制同调素材：其他的同调素材必须是「魔术师」灵摆怪兽
function c73941492.synlimit(e,c)
	return c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM)
end
-- 限制融合素材：其他的融合素材必须是「魔术师」灵摆怪兽
function c73941492.fuslimit(e,c)
	return not (c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM))
end
-- 限制超量素材：其他的超量素材必须是「魔术师」灵摆怪兽
function c73941492.xyzlimit(e,c)
	return not (c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM))
end
-- 过滤额外卡组表侧表示的「魔术师」灵摆怪兽
function c73941492.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM)
end
-- 计算额外卡组表侧表示的「魔术师」灵摆怪兽的种类数量，并乘以100作为攻击力/守备力上升值
function c73941492.atkval(e,c)
	-- 获取自己额外卡组中所有表侧表示的「魔术师」灵摆怪兽
	local g=Duel.GetMatchingGroup(c73941492.atkfilter,c:GetControler(),LOCATION_EXTRA,0,nil)
	return g:GetClassCount(Card.GetCode)*100
end
-- 检查发动条件：这张卡是否从手卡灵摆召唤成功
function c73941492.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsPreviousLocation(LOCATION_HAND)
end
-- 过滤卡组中除「调弦之魔术师」以外、可以守备表示特殊召唤的「魔术师」灵摆怪兽
function c73941492.spfilter(c,e,tp)
	return c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM) and not c:IsCode(73941492)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的目标检查与操作信息注册
function c73941492.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足特殊召唤条件的「魔术师」灵摆怪兽
		and Duel.IsExistingMatchingCard(c73941492.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 注册特殊召唤的操作信息，表示将从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组将1只「魔术师」灵摆怪兽守备表示特殊召唤，并适用效果无效化和离场除外的限制
function c73941492.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域空位，若无可用空位则不进行特殊召唤处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足条件的「魔术师」灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c73941492.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功选择卡片，则尝试将其以表侧守备表示特殊召唤（分步处理）
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		local c=e:GetHandler()
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		-- 从场上离开的场合除外。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e3:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e3,true)
	end
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
