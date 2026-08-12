--炎魔刃レーヴァテイン
-- 效果：
-- 炎属性怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，把自己场上1只其他的炎属性怪兽解放，以原本等级比那只怪兽低并原本种族相同的自己墓地1只炎属性怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
-- ②：自己的魔法与陷阱区域的里侧表示卡被对方的效果破坏的场合，可以作为代替把场上的这张卡除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含连接召唤手续、①效果（主要阶段解放场上炎属性怪兽特召墓地炎属性怪兽）和②效果（代破效果）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：炎属性怪兽2只。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_FIRE),2,2)
	-- ①：自己·对方的主要阶段，把自己场上1只其他的炎属性怪兽解放，以原本等级比那只怪兽低并原本种族相同的自己墓地1只炎属性怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己的魔法与陷阱区域的里侧表示卡被对方的效果破坏的场合，可以作为代替把场上的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.desreptg)
	e2:SetValue(s.desrepval)
	e2:SetOperation(s.desrepop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定函数：必须在主要阶段发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为主要阶段。
	return Duel.IsMainPhase()
end
-- 过滤作为解放Cost的场上炎属性怪兽：原本等级大于1，且解放后能使墓地存在满足条件的特召对象。
function s.costfilter(c,e,tp)
	-- 过滤条件：属性为炎属性、原本等级大于1，且该卡解放后能腾出可用的怪兽区域。
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:GetOriginalLevel()>1 and Duel.GetMZoneCount(tp,c)>0
		-- 过滤条件：自己墓地存在至少1只满足特召条件的炎属性怪兽（原本等级比解放怪兽低且原本种族相同）。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetOriginalLevel(),c:GetOriginalRace())
end
-- 过滤墓地中可特殊召唤的炎属性怪兽：原本等级比解放怪兽低、原本种族相同，且可以守备表示特殊召唤。
function s.spfilter(c,e,tp,lv,race)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLevelBelow(lv-1)
		and (c:GetOriginalRace()&race)~=0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的Cost处理函数：检查并选择场上1只其他的炎属性怪兽解放，并记录其原本等级和原本种族。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 步骤0：检查场上是否存在可作为Cost解放的、满足条件的炎属性怪兽（不包括自身）。
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.costfilter,1,c,e,tp) end
	-- 玩家选择1只满足条件的炎属性怪兽解放。
	local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,c,e,tp)
	e:SetLabel(g:GetFirst():GetOriginalLevel(),g:GetFirst():GetOriginalRace())
	-- 将选择的怪兽作为Cost解放。
	Duel.Release(g,REASON_COST)
end
-- ①效果的目标选择与提示函数：选择墓地中符合条件的1只炎属性怪兽作为对象，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lv,race=e:GetLabel()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp,lv,race) end
	if chk==0 then return true end
	-- 系统提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择墓地中1只满足条件的炎属性怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,lv,race)
	-- 设置特殊召唤的操作信息（包含对象卡片和数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的效果处理函数：将作为对象的墓地怪兽守备表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时作为对象的卡片。
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡片是否存在、是否仍与连锁相关，且不受王家长眠之谷的影响。
	if tc and tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽以表侧守备表示特殊召唤。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤需要代替破坏的卡片：自己魔陷区里侧表示的卡（不含场地），且因对方效果将被破坏。
function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField()
		and c:IsLocation(LOCATION_SZONE) and not c:IsLocation(LOCATION_FZONE) and c:IsFacedown()
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- ②效果的代替破坏目标判定：检查是否是对方效果破坏自己魔陷区的里侧卡，且场上的这张卡可以被除外。
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return rp==1-tp and eg:IsExists(s.repfilter,1,nil,tp)
		and c:IsAbleToRemove() and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED) end
	-- 询问玩家是否发动代替破坏的效果。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏的价值判定：确定被破坏的卡是否符合代替条件。
function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- ②效果的代替破坏处理函数：将场上的这张卡除外作为代替。
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示发动该卡的效果（展示卡片动画）。
	Duel.Hint(HINT_CARD,0,id)
	-- 将场上的这张卡表侧表示除外，作为代替破坏的处理。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
