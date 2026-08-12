--悪醒師ナイトメルト
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把自己场上1只怪兽解放才能发动。和那只怪兽是原本卡名不同并是原本的种族·属性·等级·攻击力·守备力相同的1只怪兽从卡组特殊召唤。把从额外卡组特殊召唤的怪兽解放发动的场合，也能从额外卡组选这个效果特殊召唤的怪兽。
function c66569334.initial_effect(c)
	-- ①：把自己场上1只怪兽解放才能发动。和那只怪兽是原本卡名不同并是原本的种族·属性·等级·攻击力·守备力相同的1只怪兽从卡组特殊召唤。把从额外卡组特殊召唤的怪兽解放发动的场合，也能从额外卡组选这个效果特殊召唤的怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66569334,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,66569334)
	e1:SetCost(c66569334.spcost)
	e1:SetTarget(c66569334.sptg)
	e1:SetOperation(c66569334.spop)
	c:RegisterEffect(e1)
end
-- 设置发动代价标记，用于在target中确认是否通过cost流程发动
function c66569334.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 过滤可解放的怪兽：检查怪兽是否属于自己或在场上表侧表示，且卡组（或额外卡组）中存在与其对应的可特殊召唤怪兽
function c66569334.cfilter(c,e,tp)
	local loc=nil
	if c:IsSummonLocation(LOCATION_EXTRA) then loc=LOCATION_DECK+LOCATION_EXTRA else loc=LOCATION_DECK end
	return (c:IsControler(tp) or c:IsFaceup()) and c:IsLevelAbove(0)
		-- 检查卡组或额外卡组中是否存在满足特殊召唤条件的对应怪兽
		and Duel.IsExistingMatchingCard(c66569334.spfilter,tp,loc,0,1,nil,c,e,tp)
end
-- 过滤满足特殊召唤条件的怪兽：原本卡名不同，但原本等级、种族、属性、攻击力、守备力相同，且能被特殊召唤
function c66569334.spfilter(c,mc,e,tp)
	return c:IsLevel(mc:GetOriginalLevel()) and not c:IsOriginalCodeRule(mc:GetOriginalCodeRule())
		and c:IsRace(mc:GetOriginalRace()) and c:IsAttribute(mc:GetOriginalAttribute())
		and c:GetTextAttack()==mc:GetTextAttack() and c:GetTextDefense()==mc:GetTextDefense()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若从卡组特殊召唤，检查在解放该怪兽后，自己场上是否有可用的主要怪兽区域
		and (not c:IsLocation(LOCATION_EXTRA) and Duel.GetMZoneCount(tp,c)>0
			-- 若从额外卡组特殊召唤，检查在解放该怪兽后，自己场上是否有可用于从额外卡组特殊召唤的怪兽区域
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0)
end
-- 效果1的发动准备：检查并选择自己场上1只怪兽解放作为代价，根据解放怪兽的来源确定特殊召唤的范围，并设置特殊召唤的操作信息
function c66569334.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查自己场上是否存在满足解放条件且能拉出对应怪兽的怪兽
		return Duel.CheckReleaseGroup(tp,c66569334.cfilter,1,nil,e,tp)
	end
	local c=e:GetHandler()
	-- 玩家选择自己场上1只满足条件的怪兽准备解放
	local g=Duel.SelectReleaseGroup(tp,c66569334.cfilter,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local loc=nil
	if tc:IsSummonLocation(LOCATION_EXTRA) then
		e:SetLabel(1)
		loc=LOCATION_DECK+LOCATION_EXTRA
	else
		e:SetLabel(0)
		loc=LOCATION_DECK
	end
	e:SetLabelObject(tc)
	-- 将选择的怪兽解放
	Duel.Release(g,REASON_COST)
	-- 设置特殊召唤的操作信息，包含特殊召唤的数量和来源区域
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
-- 效果1的效果处理：从卡组（或额外卡组）将1只与解放怪兽原本属性、种族、等级、攻防相同但原本卡名不同的怪兽特殊召唤
function c66569334.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域，若无则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local rc=e:GetLabelObject()
	local loc=nil
	if e:GetLabel()==1 then loc=LOCATION_DECK+LOCATION_EXTRA else loc=LOCATION_DECK end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组（或额外卡组）中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c66569334.spfilter,tp,loc,0,1,1,nil,rc,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
