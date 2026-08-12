--光天使スローネ
-- 效果：
-- 把这张卡作为超量召唤的素材的场合，不是以怪兽3只以上为素材的超量召唤不能使用。
-- ①：自己对「光天使」怪兽的召唤·特殊召唤成功的场合才能发动。这张卡从手卡特殊召唤，自己从卡组抽1张。那张抽到的卡是「光天使」怪兽的场合，可以把那只怪兽特殊召唤。
function c91110378.initial_effect(c)
	-- 开启全局标记，用于限制超量召唤素材的数量
	Duel.EnableGlobalFlag(GLOBALFLAG_XMAT_COUNT_LIMIT)
	-- 把这张卡作为超量召唤的素材的场合，不是以怪兽3只以上为素材的超量召唤不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_XYZ_MIN_COUNT)
	e1:SetValue(3)
	c:RegisterEffect(e1)
	-- ①：自己对「光天使」怪兽的召唤·特殊召唤成功的场合才能发动。这张卡从手卡特殊召唤，自己从卡组抽1张。那张抽到的卡是「光天使」怪兽的场合，可以把那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91110378,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c91110378.spcon)
	e2:SetTarget(c91110378.sptg)
	e2:SetOperation(c91110378.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己召唤·特殊召唤成功的表侧表示「光天使」怪兽
function c91110378.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x86) and c:IsSummonPlayer(tp)
end
-- 检查是否有「光天使」怪兽召唤·特殊召唤成功
function c91110378.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c91110378.cfilter,1,nil,tp)
end
-- 效果发动目标：检查是否能抽卡、是否有空怪兽区域以及此卡是否能特殊召唤
function c91110378.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查自己场上是否有空怪兽区域，以及此卡是否可以特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：特殊召唤此卡并抽1张卡，若抽到的是「光天使」怪兽则可以将其特殊召唤
function c91110378.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有空怪兽区域，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 若此卡仍存在于手卡，则将其特殊召唤，若特殊召唤成功则继续处理
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 玩家从卡组抽1张卡，若抽卡失败则结束处理
		if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
		-- 获取刚刚抽到的那张卡
		local dc=Duel.GetOperatedGroup():GetFirst()
		if dc:IsSetCard(0x86) and dc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 检查自己场上是否有空怪兽区域，并询问玩家是否要将抽到的怪兽特殊召唤
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(91110378,1)) then  --"是否要把抽到的怪兽特殊召唤？"
			-- 中断当前效果，使后续的特殊召唤处理与抽卡不视为同时处理
			Duel.BreakEffect()
			-- 将抽到的「光天使」怪兽特殊召唤
			Duel.SpecialSummon(dc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
