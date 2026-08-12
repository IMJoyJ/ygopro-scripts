--No.39 希望皇ホープ・ライジング
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，以「No.39 希望皇 霍普·升腾」以外的自己墓地1只「No.」超量怪兽为对象才能发动。那只怪兽守备表示特殊召唤。那之后，可以把这张卡的超量素材全部作为那只怪兽的超量素材。
-- ②：自己把怪兽超量召唤的场合才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化函数：设置超量召唤手续、苏生限制，并注册①效果（特殊召唤成功时复活墓地「No.」超量怪兽）和②效果（自己超量召唤时从墓地特殊召唤）
function s.initial_effect(c)
	-- 设置超量召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合，以「No.39 希望皇 霍普·升腾」以外的自己墓地1只「No.」超量怪兽为对象才能发动。那只怪兽守备表示特殊召唤。那之后，可以把这张卡的超量素材全部作为那只怪兽的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤墓地超量怪兽"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	-- ②：自己把怪兽超量召唤的场合才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"这张卡从墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 将此卡的卡号关联为「No.39」怪兽，以便其他相关卡片进行判定
aux.xyz_number[93777634]=39
-- 过滤条件：自己墓地中除「No.39 希望皇 霍普·升腾」以外的「No.」超量怪兽，且能以守备表示特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x48) and c:IsType(TYPE_XYZ) and not c:IsCode(id)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的发动准备与对象选择：检查是否满足发动条件，并进行取对象处理
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	-- 检查当前玩家的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件的「No.」超量怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择墓地中1只符合条件的「No.」超量怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息：包含特殊召唤分类，目标为选择的怪兽，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的处理：将作为对象的怪兽守备表示特殊召唤，之后可选择将此卡的所有超量素材转移给该怪兽
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup()
	-- 获取在发动时选择的作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍符合条件，则将其以守备表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0
		-- 若此卡仍在场上且持有超量素材，玩家可以选择是否将素材转移
		and c:IsRelateToEffect(e) and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否转移超量素材？"
		-- 中断当前效果处理，使后续的素材转移处理在时点上不与特殊召唤同时进行
		Duel.BreakEffect()
		-- 将此卡的所有超量素材全部重叠作为该怪兽的超量素材
		Duel.Overlay(tc,g)
	end
end
-- 过滤条件：自己成功进行超量召唤的怪兽
function s.cfilter(c,tp)
	return c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsSummonPlayer(tp)
end
-- ②效果的发动条件：自己成功超量召唤怪兽的场合
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ②效果的发动准备：检查怪兽区域空位以及此卡是否能从墓地特殊召唤
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息：包含特殊召唤分类，目标为此卡，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理：将此卡从墓地特殊召唤，并添加离场时除外的限制
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于墓地，则将其表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
