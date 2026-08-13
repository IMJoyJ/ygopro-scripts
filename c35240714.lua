--セイバー・コンビネーション
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要自己的场上·墓地·除外状态的「X-剑士」怪兽是10只以上，自己场上的「X-剑士」怪兽的攻击力上升自身的原本守备力数值。
-- ②：自己从额外卡组把「X-剑士」怪兽特殊召唤的场合才能发动。从手卡·卡组把1只「X-剑士」怪兽特殊召唤。
-- ③：对方怪兽的攻击宣言时才能发动。从手卡把1只「X-剑士」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化函数：注册该卡的发动效果（e1）、①攻击力上升永续效果（e2）、②额外特召时从手卡/卡组特召的诱发效果（e3）、③对方攻击宣言时从手卡特召的诱发效果（e4）。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要自己的场上·墓地·除外状态的「X-剑士」怪兽是10只以上，自己场上的「X-剑士」怪兽的攻击力上升自身的原本守备力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 将攻击力上升效果的作用对象限定为场上的「X-剑士」怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x100d))
	e2:SetCondition(s.atkcon)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- ②：自己从额外卡组把「X-剑士」怪兽特殊召唤的场合才能发动。从手卡·卡组把1只「X-剑士」怪兽特殊召唤。
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
	-- ③：对方怪兽的攻击宣言时才能发动。从手卡把1只「X-剑士」怪兽特殊召唤。
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
-- 过滤函数：判断卡是否为表侧表示的「X-剑士」怪兽（IsFaceupEx用于包含场上、墓地、除外的相应状态），用于①的数量统计。
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x100d) and c:IsType(TYPE_MONSTER)
end
-- ①的发动条件：己方场上·墓地·除外的「X-剑士」怪兽合计达到10只以上。
function s.atkcon(e)
	-- 具体检查：从己方场上（MZONE）、墓地（GRAVE）、除外（REMOVED）中是否存在至少10张满足s.cfilter的卡。
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,10,nil)
end
-- 攻击力上升数值取该怪兽的原本守备力。
function s.atkval(e,c)
	return c:GetBaseDefense()
end
-- 过滤函数：判断从额外卡组特殊召唤的「X-剑士」怪兽是否由tp玩家召唤且表侧表示，用于②触发。
function s.exfilter(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSummonPlayer(tp) and c:IsSetCard(0x100d) and c:IsFaceup()
end
-- ②的触发条件：本次特殊召唤成功的怪兽中存在至少1只由tp玩家从额外卡组特殊召唤的「X-剑士」怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.exfilter,1,nil,tp)
end
-- 过滤函数：作为特殊召唤候选的卡须为「X-剑士」怪兽，且能被tp玩家正常特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x100d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②发动条件（chk==0）：自己怪兽区有空位，且手卡·卡组中存在可特殊召唤的「X-剑士」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己怪兽区存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认手卡·卡组中存在至少1张满足s.spfilter的「X-剑士」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：本次效果将从手卡·卡组把1只「X-剑士」怪兽特殊召唤（不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果处理：若仍存在空位，从手卡·卡组选择1只「X-剑士」怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己怪兽区没有空位，则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组中筛选出1张满足s.spfilter的「X-剑士」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③触发条件：对方怪兽进行攻击宣言，且该攻击怪兽与战斗相关（能够进行伤害计算）。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前攻击宣言的怪兽。
	local at=Duel.GetAttacker()
	return at and at:IsControler(1-tp) and at:IsRelateToBattle()
end
-- ③发动条件（chk==0）：自己怪兽区有空位，且手卡中存在可特殊召唤的「X-剑士」怪兽。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己怪兽区存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认手卡中存在至少1张满足s.spfilter的「X-剑士」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记操作信息：本次效果将从手卡把1只「X-剑士」怪兽特殊召唤（不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ③效果处理：若仍存在空位，从手卡选择1只「X-剑士」怪兽特殊召唤。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己怪兽区没有空位，则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中筛选出1张满足s.spfilter的「X-剑士」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
