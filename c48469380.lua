--デス・エンペラー・デーモン
-- 效果：
-- ←0 【灵摆】 0→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：以场上1张其他的表侧表示的魔法·陷阱卡为对象才能发动。那张卡和这张卡破坏。
-- 【怪兽效果】
-- 「恶魔们的玉座」降临
-- 这张卡不用仪式召唤不能特殊召唤。这个卡名的①③的怪兽效果1回合各能使用1次。
-- ①：这张卡从额外卡组仪式召唤的场合才能发动。额外怪兽区域以外的场上的怪兽全部除外。
-- ②：额外怪兽区域的这张卡不受其他怪兽的效果影响。
-- ③：这张卡在额外怪兽区域存在的场合才能发动。自己的手卡·卡组·墓地·除外状态的1只恶魔族怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册灵摆属性、仪式召唤限制和四个效果
function s.initial_effect(c)
	-- 记录该卡与「恶魔们的玉座」的关联
	aux.AddCodeList(c,63679166)
	c:EnableReviveLimit()
	-- 为该卡添加灵摆属性，使其可以灵摆召唤
	aux.EnablePendulumAttribute(c)
	-- 设置该卡必须通过仪式召唤才能特殊召唤
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡只能通过仪式召唤方式特殊召唤
	e0:SetValue(aux.ritlimit)
	c:RegisterEffect(e0)
	-- 注册灵摆效果：以场上1张其他表侧表示的魔法·陷阱卡为对象破坏
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏效果"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- 注册怪兽效果①：从额外卡组仪式召唤成功时除外场上的怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外效果"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	-- 注册怪兽效果②：在额外怪兽区域时不受其他怪兽效果影响
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.econ)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	-- 注册怪兽效果③：在额外怪兽区域存在时特殊召唤1只恶魔族怪兽
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.econ)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 过滤函数，判断是否为表侧表示的魔法·陷阱卡
function s.filter1(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 灵摆效果的目标选择函数，检查是否有符合条件的魔法·陷阱卡
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter1(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return e:GetHandler():IsDestructable()
		-- 检查是否存在符合条件的魔法·陷阱卡作为目标
		and Duel.IsExistingTarget(s.filter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标魔法·陷阱卡
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 设置连锁操作信息为破坏效果，涉及2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 灵摆效果的处理函数，将目标卡和自身一起破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 执行破坏操作，将目标卡和自身一起破坏
		Duel.Destroy(Group.FromCards(tc,e:GetHandler()),REASON_EFFECT)
	end
end
-- 怪兽效果①的发动条件，判断是否为从额外卡组仪式召唤成功
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
		and e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤函数，判断是否为场上的怪兽且可以除外
function s.rmfilter(c)
	return c:GetSequence()<5 and c:IsAbleToRemove()
end
-- 怪兽效果①的目标选择函数，检查是否有符合条件的怪兽
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在符合条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取符合条件的怪兽组
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁操作信息为除外效果，涉及多个怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 怪兽效果①的处理函数，将符合条件的怪兽除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取符合条件的怪兽组
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 执行除外操作，将怪兽除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判断该卡是否在额外怪兽区域（序列大于4）
function s.econ(e)
	return e:GetHandler():GetSequence()>4
end
-- 过滤函数，判断是否为对方怪兽效果且对自身生效
function s.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetOwner()
end
-- 过滤函数，判断是否为表侧表示的恶魔族怪兽且可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsRace(RACE_FIEND)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 怪兽效果③的目标选择函数，检查是否有符合条件的恶魔族怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在符合条件的恶魔族怪兽作为目标
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置连锁操作信息为特殊召唤效果，涉及1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 怪兽效果③的处理函数，选择并特殊召唤恶魔族怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否还有召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的恶魔族怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
