--絢嵐たるメガラ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己墓地有「旋风」存在的场合或者对方场上没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。
-- ②：「绚岚」速攻魔法卡或「旋风」发动的场合才能发动。同名怪兽不在自己场上存在的1只「绚岚」怪兽从卡组特殊召唤。这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册两个效果：①特殊召唤条件和②诱发效果
function s.initial_effect(c)
	-- 记录该卡与「旋风」（卡号5318639）的关联
	aux.AddCodeList(c,5318639)
	-- ①：自己墓地有「旋风」存在的场合或者对方场上没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：「绚岚」速攻魔法卡或「旋风」发动的场合才能发动。同名怪兽不在自己场上存在的1只「绚岚」怪兽从卡组特殊召唤。这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 判断是否满足①效果的特殊召唤条件
function s.spcon(e,c)
	if c==nil then return true end
	-- 判断自己场上是否有足够的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断对方场上是否存在魔法·陷阱卡
		and (not Duel.IsExistingMatchingCard(Card.IsType,c:GetControler(),0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP)
		-- 判断自己墓地是否存在「旋风」
		or Duel.IsExistingMatchingCard(Card.IsCode,c:GetControler(),LOCATION_GRAVE,0,1,nil,5318639))
end
-- 判断是否满足②效果的发动条件
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and (re:GetHandler():IsCode(5318639)
		or re:GetHandler():IsSetCard(0x1d1) and re:IsActiveType(TYPE_QUICKPLAY))
end
-- 筛选可以特殊召唤的「绚岚」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1d1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确保场上没有同名怪兽
		and not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_MZONE,0,1,nil,c:GetCode())
end
-- 设置②效果的发动条件
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果发动后的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行②效果的处理流程
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 设置效果发动后直到回合结束时的限制效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制效果注册到场上
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的具体实现：不能特殊召唤非风属性怪兽
function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
