--EMウィム・ウィッチ
-- 效果：
-- ←4 【灵摆】 4→
-- 「娱乐伙伴 妙想魔女」的灵摆效果1回合只能使用1次。
-- ①：从额外卡组特殊召唤的怪兽只有对方场上才存在的场合才能发动。灵摆区域的这张卡特殊召唤。
-- 【怪兽效果】
-- ①：灵摆怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
function c64450427.initial_effect(c)
	-- 注册灵摆怪兽的灵摆召唤和灵摆卡发动等基本属性
	aux.EnablePendulumAttribute(c)
	-- 「娱乐伙伴 妙想魔女」的灵摆效果1回合只能使用1次。①：从额外卡组特殊召唤的怪兽只有对方场上才存在的场合才能发动。灵摆区域的这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64450427,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,64450427)
	e1:SetCondition(c64450427.spcon)
	e1:SetTarget(c64450427.sptg)
	e1:SetOperation(c64450427.spop)
	c:RegisterEffect(e1)
	-- ①：灵摆怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e2:SetValue(c64450427.dtcon)
	c:RegisterEffect(e2)
end
-- 过滤条件：从额外卡组特殊召唤的怪兽
function c64450427.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 灵摆效果的发动条件：从额外卡组特殊召唤的怪兽只有对方场上才存在
function c64450427.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上不存在从额外卡组特殊召唤的怪兽
	return not Duel.IsExistingMatchingCard(c64450427.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上存在从额外卡组特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c64450427.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 灵摆效果的发动准备与合法性检查
function c64450427.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 灵摆效果的处理：将自身特殊召唤
function c64450427.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 限制双祭品效果仅在灵摆怪兽上级召唤时适用
function c64450427.dtcon(e,c)
	return c:IsType(TYPE_PENDULUM)
end
