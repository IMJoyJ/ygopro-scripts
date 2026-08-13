--天威龍－スールヤ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：幻龙族怪兽或除效果怪兽以外的表侧表示怪兽在自己场上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡作为幻龙族同调怪兽的同调素材送去墓地的场合才能发动。从额外卡组把1只「天威」连接怪兽特殊召唤。那之后，自己失去这个效果特殊召唤的怪兽的连接标记数量×1000基本分。这个效果特殊召唤的怪兽不能作为连接素材。
local s,id,o=GetID()
-- 创建并注册这张卡的两个效果：①为手牌起动效果，在自己场上有幻龙族怪兽或非效果怪兽表侧表示时从手卡特殊召唤这张卡；②为诱发效果，在这张卡作为幻龙族同调怪兽的同调素材送去墓地时从额外卡组特殊召唤1只「天威」连接怪兽，之后扣除对应LP并赋予不能作为连接素材的限制。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：幻龙族怪兽或除效果怪兽以外的表侧表示怪兽在自己场上存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡作为幻龙族同调怪兽的同调素材送去墓地的场合才能发动。从额外卡组把1只「天威」连接怪兽特殊召唤。那之后，自己失去这个效果特殊召唤的怪兽的连接标记数量×1000基本分。这个效果特殊召唤的怪兽不能作为连接素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从额外卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 过滤函数，判断怪兽是否为表侧表示且种族为幻龙族，或者是否为除效果怪兽以外的表侧表示怪兽，用于检查①效果所需的存在条件。
function s.cfilter(c)
	return c:IsFaceup() and (c:IsRace(RACE_WYRM) or not c:IsType(TYPE_EFFECT))
end
-- ①效果的发动条件，检查自己场上是否存在至少1只满足条件的怪兽（幻龙族或非效果怪兽且表侧表示），存在才能发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体检查自己场上主要怪兽区是否存在至少1张符合条件的表侧表示怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动合法性判定：自己场上存在可用主要怪兽区空格，并且这张卡能够被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的主要怪兽区，用于容纳从手卡特殊召唤的这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，将这张卡登记为将要特殊召唤的对象，以便其他效果（如星尘龙等）能正确响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理时的操作：若这张卡仍与效果关联，则将其特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：这张卡作为幻龙族同调怪兽的同调素材被送去墓地，且现在在墓地，并且是同调召唤（REASON_SYNCHRO）导致的。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetReasonCard():IsRace(RACE_WYRM)
		and e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 选择额外卡组特殊召唤对象的过滤条件：必须是「天威」连接怪兽、能被特殊召唤，并且特殊召唤后有空余的额外怪兽区/可用区域。
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x12c) and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 额外检查特殊召唤这张连接怪兽时自己场上有可用的区域（额外怪兽区或连接端指向区域）。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②效果发动时的目标检查和操作登记：确认额外卡组有符合条件的「天威」连接怪兽，然后将从额外卡组特殊召唤1只怪兽的信息登记。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在至少1张满足spfilter2的「天威」连接怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 登记操作信息：从额外卡组特殊召唤1只怪兽，具体对象在效果处理时选择。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理：从额外卡组特殊召唤1只「天威」连接怪兽，为它赋予不能作为连接素材的效果，特殊召唤完成后扣除自己对应的基本分。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的「天威」连接怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若选中的怪兽仍能特殊召唤，则执行分步特殊召唤，成功则继续后续的无效连接素材和扣LP处理。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 那之后，自己失去这个效果特殊召唤的怪兽的连接标记数量×1000基本分。这个效果特殊召唤的怪兽不能作为连接素材。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 完成分步特殊召唤，使特殊召唤正式成功。
		Duel.SpecialSummonComplete()
		-- 中断当前效果处理，使后续扣血与特殊召唤不同时处理，避免错失时点。
		Duel.BreakEffect()
		-- 自己失去基本分，数值为特殊召唤的「天威」连接怪兽的连接标记数量×1000。
		Duel.SetLP(tp,Duel.GetLP(tp)-tc:GetLink()*1000)
	end
end
