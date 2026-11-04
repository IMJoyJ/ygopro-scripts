--ENウェーブ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的「元素英雄」怪兽成为融合怪兽的融合召唤的素材，被送去墓地的场合或者被除外的场合才能发动。从卡组把1只「新空间侠」怪兽或者「元素英雄 新宇侠」特殊召唤。
-- ②：「新空间侠」怪兽或者「元素英雄 新宇侠」从自己的场上·墓地回到自己的卡组·额外卡组的场合才能发动。从自己墓地选1只「元素英雄」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果
function s.initial_effect(c)
	-- 注册卡名列表「元素英雄 新宇侠」
	aux.AddCodeList(c,89943723)
	-- 注册系列列表「元素英雄」
	aux.AddSetNameMonsterList(c,0x3008)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己的「元素英雄」怪兽成为融合怪兽的融合召唤的素材，被送去墓地的场合或者被除外的场合才能发动。从卡组把1只「新空间侠」怪兽或者「元素英雄 新宇侠」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.dspcon)
	e1:SetTarget(s.dsptg)
	e1:SetOperation(s.dspop)
	c:RegisterEffect(e1)
	-- ②：「新空间侠」怪兽或者「元素英雄 新宇侠」从自己的场上·墓地回到自己的卡组·额外卡组的场合才能发动。从自己墓地选1只「元素英雄」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.gspcon)
	e2:SetTarget(s.gsptg)
	e2:SetOperation(s.gspop)
	c:RegisterEffect(e2)
end
-- 过滤作为融合素材送墓或除外的「元素英雄」怪兽
function s.dspconfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c:IsFaceupEx() and not c:IsReason(REASON_RETURN)
		and (c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousSetCard(0x3008)
			or not c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsSetCard(0x3008))
end
-- 确认是否因融合召唤素材送墓或除外
function s.dspcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_FUSION and eg:IsExists(s.dspconfilter,1,nil,tp)
end
-- 过滤「新空间侠」怪兽或「元素英雄 新宇侠」
function s.dspfilter(c,e,tp)
	return (c:IsSetCard(0x1f) or c:IsCode(89943723)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 确认怪兽区空位及卡组是否存在满足条件的怪兽
function s.dsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主要怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否存在「新空间侠」怪兽或「元素英雄 新宇侠」
		and Duel.IsExistingMatchingCard(s.dspfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 从卡组特殊召唤「新空间侠」怪兽或「元素英雄 新宇侠」
function s.dspop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查主要怪兽区是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.dspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤从场上·墓地回到卡组·额外卡组的「新空间侠」怪兽或「元素英雄 新宇侠」
function s.gspconfilter(c,tp)
	return ((c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1f)) or c:IsCode(89943723))
		and c:IsPreviousControler(tp) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_MZONE+LOCATION_GRAVE)
end
-- 确认是否有满足条件的怪兽回到卡组
function s.gspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.gspconfilter,1,nil,tp)
end
-- 过滤墓地的「元素英雄」怪兽
function s.gspfilter(c,e,tp)
	return c:IsSetCard(0x3008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 确认怪兽区空位及墓地是否存在「元素英雄」怪兽
function s.gsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主要怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在可特殊召唤的「元素英雄」怪兽
		and Duel.IsExistingMatchingCard(s.gspfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：从墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 从墓地特殊召唤「元素英雄」怪兽
function s.gspop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查主要怪兽区是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地选择1只「元素英雄」怪兽
	local g=Duel.SelectMatchingCard(tp,s.gspfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
