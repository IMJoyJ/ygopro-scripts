--Live☆Twin キスキル
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，若自己场上没有其他怪兽存在则能发动。从手卡·卡组把1只「璃拉」怪兽特殊召唤。
-- ②：只要这张卡在怪兽区域存在，每次对方怪兽攻击宣言，自己回复500基本分。
function c36326160.initial_effect(c)
	-- 效果原文内容：①：这张卡召唤·特殊召唤的场合，若自己场上没有其他怪兽存在则能发动。从手卡·卡组把1只「璃拉」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36326160,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e1:SetCountLimit(1,36326160)
	e1:SetCondition(c36326160.spcon)
	e1:SetTarget(c36326160.sptg)
	e1:SetOperation(c36326160.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 效果原文内容：②：只要这张卡在怪兽区域存在，每次对方怪兽攻击宣言，自己回复500基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c36326160.reccon)
	e3:SetOperation(c36326160.recop)
	c:RegisterEffect(e3)
end
-- 规则层面操作：判断自己场上是否只有这张卡（即没有其他怪兽）
function c36326160.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断自己场上是否只有这张卡（即没有其他怪兽）
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
end
-- 规则层面操作：定义过滤函数，用于筛选「璃拉」怪兽且可特殊召唤的卡片
function c36326160.spfilter(c,e,tp)
	return c:IsSetCard(0x153) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面操作：设置发动条件，检查手卡或卡组是否存在满足条件的「璃拉」怪兽
function c36326160.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查场上是否有足够的特殊召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面操作：检查手卡或卡组是否存在满足条件的「璃拉」怪兽
		and Duel.IsExistingMatchingCard(c36326160.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 规则层面操作：设置连锁操作信息，表示将要特殊召唤1只「璃拉」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 规则层面操作：执行特殊召唤流程，选择并特殊召唤符合条件的「璃拉」怪兽
function c36326160.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断场上是否还有特殊召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面操作：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面操作：选择满足条件的「璃拉」怪兽
	local g=Duel.SelectMatchingCard(tp,c36326160.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面操作：将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 规则层面操作：判断攻击方是否不是自己
function c36326160.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断攻击方是否不是自己
	return Duel.GetAttacker():GetControler()~=tp
end
-- 规则层面操作：执行回复LP效果，每次对方攻击宣言时回复500基本分
function c36326160.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：显示发动卡片的动画提示
	Duel.Hint(HINT_CARD,0,36326160)
	-- 规则层面操作：使自己回复500基本分
	Duel.Recover(tp,500,REASON_EFFECT)
end
