--セイバー・コンビネーション
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要自己的场上·墓地·除外状态的「X-剑士」怪兽是10只以上，自己场上的「X-剑士」怪兽的攻击力上升自身的原本守备力数值。
-- ②：自己从额外卡组把「X-剑士」怪兽特殊召唤的场合才能发动。从手卡·卡组把1只「X-剑士」怪兽特殊召唤。
-- ③：对方怪兽的攻击宣言时才能发动。从手卡把1只「X-剑士」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册场地魔法卡的发动效果，使卡能被正常发动
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要自己的场上·墓地·除外状态的「X-剑士」怪兽是10只以上，自己场上的「X-剑士」怪兽的攻击力上升自身的原本守备力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为「X-剑士」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x100d))
	e2:SetCondition(s.atkcon)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- 自己从额外卡组把「X-剑士」怪兽特殊召唤的场合才能发动。从手卡·卡组把1只「X-剑士」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- 对方怪兽的攻击宣言时才能发动。从手卡把1只「X-剑士」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.spcon2)
	e4:SetTarget(s.sptg2)
	e4:SetOperation(s.spop2)
	c:RegisterEffect(e4)
end
-- 用于判断是否满足①效果的条件，即场上·墓地·除外状态的「X-剑士」怪兽是否达到10只以上
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x100d) and c:IsType(TYPE_MONSTER)
end
-- 判断是否满足①效果的条件，即场上·墓地·除外状态的「X-剑士」怪兽是否达到10只以上
function s.atkcon(e)
	-- 判断是否满足①效果的条件，即场上·墓地·除外状态的「X-剑士」怪兽是否达到10只以上
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,10,nil)
end
-- 设置①效果的攻击力加成值为怪兽的原本守备力
function s.atkval(e,c)
	return c:GetBaseDefense()
end
-- 用于筛选从额外卡组特殊召唤的「X-剑士」怪兽
function s.exfilter(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSummonPlayer(tp) and c:IsSetCard(0x100d) and c:IsFaceup()
end
-- 判断是否满足②效果的条件，即是否有从额外卡组特殊召唤的「X-剑士」怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.exfilter,1,nil,tp)
end
-- 用于筛选可以特殊召唤的「X-剑士」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x100d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置②效果的处理条件，检查是否有满足条件的怪兽可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否有满足条件的「X-剑士」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置②效果的处理信息，告知将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 执行②效果的处理，选择并特殊召唤怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「X-剑士」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否满足③效果的条件，即对方怪兽攻击宣言时
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击的怪兽
	local at=Duel.GetAttacker()
	return at and at:IsControler(1-tp) and at:IsRelateToBattle()
end
-- 设置③效果的处理条件，检查是否有满足条件的怪兽可特殊召唤
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否有满足条件的「X-剑士」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置③效果的处理信息，告知将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行③效果的处理，选择并特殊召唤怪兽
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「X-剑士」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
