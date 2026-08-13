--リンク・デコーダー
-- 效果：
-- 4星以下的电子界族怪兽1只
-- 这个卡名的效果1回合只能使用1次。
-- ①：作为原本攻击力是2300以上的电子界族连接怪兽的连接素材让这张卡被送去墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化卡片效果：设定连接召唤条件，并注册①效果（作为连接素材送去墓地时特殊召唤）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定连接召唤手续：用1只4星以下的电子界族怪兽作为连接素材。
	aux.AddLinkProcedure(c,s.mfilter,1,1)
	-- 这个卡名的效果1回合只能使用1次。①：作为原本攻击力是2300以上的电子界族连接怪兽的连接素材让这张卡被送去墓地的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
-- 连接素材的过滤条件：等级4以下的电子界族怪兽。
function s.mfilter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_CYBERSE)
end
-- 效果①的发动条件：这张卡作为原本攻击力2300以上的电子界族连接怪兽的连接素材被送去墓地。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK
		and rc:IsRace(RACE_CYBERSE) and rc:GetBaseAttack()>=2300
end
-- 效果发动时点检查：自己场上主要怪兽区有空位，且这张卡可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果处理为特殊召唤这张卡（1张）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：将这张卡特殊召唤；若特殊召唤成功，为其附加‘从场上离开的场合除外’的效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍与效果关联，则将其表侧表示特殊召唤到自己场上；若特殊召唤成功，则继续附加离场除外效果。
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
