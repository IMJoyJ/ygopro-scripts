--ゴルゴニック・アンブラル
local s,id,o=GetID()
-- 初始化效果：注册起动效果及永续限制效果
function s.initial_effect(c)
	-- ①：自己场上没有怪兽存在，或者自己场上的怪兽只有表侧表示的「戈耳工」怪兽的场合才能发动。这张卡从手卡特殊召唤，从卡组把1只岩石族以外的「戈耳工」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区存在，自己不是「No.」超量怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	c:RegisterEffect(e2)
	-- ③：把包含这张卡的怪兽作为「No.」超量怪兽的超量召唤的素材的场合，这张卡可以当作2个数量的素材使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DOUBLE_XMATERIAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.sxyzfilter)
	e3:SetValue(id)
	e3:SetCountLimit(1,id+o)
	c:RegisterEffect(e3)
end
-- 过滤条件：里侧表示，或者不是「戈耳工」怪兽的卡
function s.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x87)
end
-- 判断自己场上是否没有里侧表示或非「戈耳工」的怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回判断结果
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：可以加入手卡的岩石族以外的「戈耳工」怪兽
function s.thfilter(c)
	return c:IsSetCard(0x87) and not c:IsRace(RACE_ROCK) and c:IsType(TYPE_MONSTER)
		and c:IsAbleToHand()
end
-- 效果发动条件：判断自身能否特殊召唤且卡组是否有可以加入手卡的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否有可用的主要怪兽区
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 且卡组存在可以加入手卡的满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：包含特殊召唤操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置操作信息：包含从卡组检索加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的操作：特殊召唤自身并从卡组检索怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果自身在有效区域并且特殊召唤成功
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 且卡组存在可以检索的怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1张满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的怪兽
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- ②效果的限制范围：额外卡组的非「No.」超量怪兽
function s.splimit(e,c)
	return not (c:IsSetCard(0x48) and c:IsType(TYPE_XYZ)) and c:IsLocation(LOCATION_EXTRA)
end
-- ③效果的适用范围：「No.」怪兽
function s.sxyzfilter(e,c)
	return c:IsSetCard(0x48)
end
