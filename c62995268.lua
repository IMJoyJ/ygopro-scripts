--白き森のわざわいなり
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡·卡组把1只「白森林」怪兽特殊召唤。那之后，可以进行1只「白森林」同调怪兽的同调召唤。
-- ②：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化卡片效果：注册①效果（特殊召唤+同调召唤）和②效果（送墓盖回）
function s.initial_effect(c)
	-- ①：从手卡·卡组把1只「白森林」怪兽特殊召唤。那之后，可以进行1只「白森林」同调怪兽的同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡·卡组中可以特殊召唤的「白森林」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1b1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备：检查怪兽区域是否有空位，以及手卡·卡组是否存在可特殊召唤的「白森林」怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在至少1只满足特殊召唤条件的「白森林」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁信息：包含从手卡·卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 过滤条件：额外卡组中可以进行同调召唤的「白森林」同调怪兽
function s.syncfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x1b1) and c:IsSynchroSummonable(nil)
end
-- ①效果的处理：特殊召唤1只「白森林」怪兽，之后可选择进行1只「白森林」同调怪兽的同调召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域，若无空位则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡或卡组选择1只满足条件的「白森林」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	-- 若成功将选中的怪兽以表侧表示特殊召唤
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 立即刷新场上卡片状态信息（以便后续同调召唤能正确检测场上素材）
		Duel.AdjustAll()
		-- 检查额外卡组是否存在可以进行同调召唤的「白森林」同调怪兽
		if Duel.IsExistingMatchingCard(s.syncfilter,tp,LOCATION_EXTRA,0,1,nil)
			-- 询问玩家是否选择进行同调召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否进行同调召唤？"
			-- 产生时间点间隔，使前后效果处理不同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要同调召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 玩家从额外卡组选择1只可同调召唤的「白森林」同调怪兽
			local sg=Duel.SelectMatchingCard(tp,s.syncfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
			-- 对选中的怪兽进行同调召唤
			Duel.SynchroSummon(tp,sg:GetFirst(),nil)
		end
	end
end
-- ②效果的发动条件：这张卡作为怪兽效果发动的代价被送去墓地
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
end
-- ②效果的发动准备：检查自身是否可以盖放，并设置连锁信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 设置连锁信息：包含将墓地的这张卡移出墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- ②效果的处理：将墓地的这张卡在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于墓地，则将其在自己场上盖放
	if c:IsRelateToEffect(e) then Duel.SSet(tp,c) end
end
