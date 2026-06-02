--ENウェーブ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的「元素英雄」怪兽成为融合怪兽的融合召唤的素材，被送去墓地的场合或者被除外的场合才能发动。从卡组把1只「新空间侠」怪兽或者「元素英雄 新宇侠」特殊召唤。
-- ②：「新空间侠」怪兽或者「元素英雄 新宇侠」从自己的场上·墓地回到自己的卡组·额外卡组的场合才能发动。从自己墓地选1只「元素英雄」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果注册，包含卡片关联密码注册、卡片发动效果、①效果和②效果的注册
function s.initial_effect(c)
	-- 将「元素英雄 新宇侠」（89943723）加入该卡的关联卡片密码列表中
	aux.AddCodeList(c,89943723)
	-- 将「元素英雄」（0x3008）系列怪兽加入该卡的关联系列怪兽列表中
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
-- 过滤满足条件的融合素材怪兽：原本由自己控制、被送去墓地或除外，且原本在场上时是「元素英雄」怪兽，或者不在场上时是「元素英雄」怪兽
function s.dspconfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and not c:IsReason(REASON_RETURN)
		and (c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousSetCard(0x3008)
			or not c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsSetCard(0x3008))
end
-- 检查是否因融合召唤将满足条件的怪兽作为素材
function s.dspcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_FUSION and eg:IsExists(s.dspconfilter,1,nil,tp)
end
-- 过滤卡组中可以特殊召唤的「新空间侠」怪兽或「元素英雄 新宇侠」
function s.dspfilter(c,e,tp)
	return (c:IsSetCard(0x1f) or c:IsCode(89943723)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备与合法性检查
function s.dsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以特殊召唤的「新空间侠」怪兽或「元素英雄 新宇侠」
		and Duel.IsExistingMatchingCard(s.dspfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息为：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际效果处理
function s.dspop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，检查自己场上的主要怪兽区域是否有空位，若无则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.dspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤满足条件的回到卡组的怪兽：原本由自己控制、现在仍由自己控制、原本在场上或墓地的「新空间侠」怪兽或「元素英雄 新宇侠」
function s.gspconfilter(c,tp)
	return ((c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1f)) or c:IsCode(89943723))
		and c:IsPreviousControler(tp) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_MZONE+LOCATION_GRAVE)
end
-- 检查是否有满足条件的怪兽回到持有者卡组
function s.gspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.gspconfilter,1,nil,tp)
end
-- 过滤自己墓地中可以特殊召唤的「元素英雄」怪兽
function s.gspfilter(c,e,tp)
	return c:IsSetCard(0x3008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动准备与合法性检查
function s.gsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地中是否存在可以特殊召唤的「元素英雄」怪兽
		and Duel.IsExistingMatchingCard(s.gspfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息为：从墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果的实际效果处理
function s.gspop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，检查自己场上的主要怪兽区域是否有空位，若无则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.gspfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
