--天威龍－スールヤ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：幻龙族怪兽或除效果怪兽以外的表侧表示怪兽在自己场上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡作为幻龙族同调怪兽的同调素材送去墓地的场合才能发动。从额外卡组把1只「天威」连接怪兽特殊召唤。那之后，自己失去这个效果特殊召唤的怪兽的连接标记数量×1000基本分。这个效果特殊召唤的怪兽不能作为连接素材。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②效果的发动条件与处理
function s.initial_effect(c)
	-- ①效果：幻龙族怪兽或除效果怪兽以外的表侧表示怪兽在自己场上存在的场合才能发动。这张卡从手卡特殊召唤。
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
	-- ②效果：这张卡作为幻龙族同调怪兽的同调素材送去墓地的场合才能发动。从额外卡组把1只「天威」连接怪兽特殊召唤。那之后，自己失去这个效果特殊召唤的怪兽的连接标记数量×1000基本分。这个效果特殊召唤的怪兽不能作为连接素材。
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
-- 过滤函数，用于判断场上是否存在满足条件的怪兽（幻龙族或非效果怪兽且表侧表示）
function s.cfilter(c)
	return c:IsFaceup() and (c:IsRace(RACE_WYRM) or not c:IsType(TYPE_EFFECT))
end
-- ①效果的发动条件：场上存在幻龙族怪兽或除效果怪兽以外的表侧表示怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在满足条件的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动时点处理，判断是否可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，提示将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理函数，执行特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡从手牌特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：作为幻龙族同调怪兽的同调素材送去墓地
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetReasonCard():IsRace(RACE_WYRM)
		and e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 过滤函数，用于选择额外卡组中满足条件的「天威」连接怪兽
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x12c) and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断是否有足够的额外卡组区域进行特殊召唤
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②效果的发动时点处理，判断是否可以特殊召唤
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在满足条件的「天威」连接怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息，提示将要从额外卡组特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的处理函数，执行从额外卡组特殊召唤并扣除LP的操作
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择一只满足条件的「天威」连接怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 判断是否成功特殊召唤该怪兽
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 设置效果，使该怪兽不能作为连接素材，并扣除LP
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
		-- 中断当前效果处理，防止错时点
		Duel.BreakEffect()
		-- 根据特殊召唤的怪兽的连接标记数量，扣除对应的基本分
		Duel.SetLP(tp,Duel.GetLP(tp)-tc:GetLink()*1000)
	end
end
