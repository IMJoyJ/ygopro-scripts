--スター・ライゼオル
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以把自己场上1个超量素材取除，从手卡特殊召唤。这个方法特殊召唤过的回合，自己不是4阶超量怪兽不能从额外卡组特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。从卡组把1张「雷火沸动」魔法·陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化卡片效果，注册①的特殊召唤规则和②的特殊召唤成功时盖放魔陷的效果。
function s.initial_effect(c)
	-- ①：这张卡可以把自己场上1个超量素材取除，从手卡特殊召唤。这个方法特殊召唤过的回合，自己不是4阶超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的场合才能发动。从卡组把1张「雷火沸动」魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上拥有超量素材的超量怪兽。
function s.cfilter(c,tp)
	return c:IsType(TYPE_XYZ)
		and c:CheckRemoveOverlayCard(tp,1,REASON_SPSUMMON)
end
-- 特殊召唤规则的条件：手卡特殊召唤时，检查怪兽区域是否有空位，且自己场上是否存在可以取除超量素材的怪兽。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空位，且自己场上是否存在至少1个可以取除的超量素材。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_SPSUMMON)
end
-- 特殊召唤规则的目标选择：从自己场上选择1只拥有超量素材的超量怪兽，并将其作为效果的目标对象保存。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足条件的、拥有超量素材的超量怪兽。
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,c)
	-- 提示玩家选择要取除超量素材的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)  --"请选择要取除超量素材的怪兽"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的操作：取除所选怪兽的1个超量素材，并对玩家施加“本回合不是4阶超量怪兽不能从额外卡组特殊召唤”的限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	tc:RemoveOverlayCard(tp,1,1,REASON_SPSUMMON)
	-- 这个方法特殊召唤过的回合，自己不是4阶超量怪兽不能从额外卡组特殊召唤。从卡组把1张「雷火沸动」魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤非4阶超量怪兽的限制效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能从额外卡组特殊召唤4阶超量怪兽以外的怪兽。
function s.splimit(e,c)
	return not (c:IsType(TYPE_XYZ) and c:IsRank(4)) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤条件：卡组中可以盖放的「雷火沸动」魔法·陷阱卡。
function s.setfilter(c)
	return c:IsSetCard(0x1be) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 盖放效果的发动准备：检查魔法与陷阱区域是否有空位，以及卡组中是否存在可盖放的「雷火沸动」魔法·陷阱卡。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的魔法与陷阱区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在至少1张满足条件的「雷火沸动」魔法·陷阱卡。
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 盖放效果的执行：从卡组选择1张「雷火沸动」魔法·陷阱卡在自己场上盖放。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查魔法与陷阱区域是否仍有空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要盖放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组中选择1张满足条件的「雷火沸动」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的卡片在自己场上盖放。
		Duel.SSet(tp,tc)
	end
end
