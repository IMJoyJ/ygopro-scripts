--EMウィム・ウィッチ
-- 效果：
-- ←4 【灵摆】 4→
-- 「娱乐伙伴 妙想魔女」的灵摆效果1回合只能使用1次。
-- ①：从额外卡组特殊召唤的怪兽只有对方场上才存在的场合才能发动。灵摆区域的这张卡特殊召唤。
-- 【怪兽效果】
-- ①：灵摆怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
function c64450427.initial_effect(c)
	-- 启用灵摆怪兽属性（注册灵摆召唤与灵摆卡的发动效果）
	aux.EnablePendulumAttribute(c)
	-- ①：从额外卡组特殊召唤的怪兽只有对方场上才存在的场合才能发动。灵摆区域的这张卡特殊召唤。
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
-- 过滤从额外卡组特殊召唤的怪兽
function c64450427.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 灵摆效果的发动条件：从额外卡组特殊召唤的怪兽仅在对方场上存在
function c64450427.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自己场上不存在从额外卡组特殊召唤的怪兽
	return not Duel.IsExistingMatchingCard(c64450427.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 确认对方场上存在从额外卡组特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c64450427.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 灵摆效果的发动目标确认与操作信息设置
function c64450427.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认主要怪兽区域有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置将灵摆区域的自身特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 灵摆效果的效果处理（将灵摆区域的自身特殊召唤）
function c64450427.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将灵摆区域的自身表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 判定作为2只解放的条件（上级召唤的怪兽为灵摆怪兽）
function c64450427.dtcon(e,c)
	local ec=e:GetHandler()
	return c:IsType(TYPE_PENDULUM) and (ec:IsFaceup() or c:GetControler()==ec:GetControler())
end
