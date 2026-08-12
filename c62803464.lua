--地霊媒師アウス
-- 效果：
-- 这个卡名在规则上也当作「灵使」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把这张卡和1只地属性怪兽丢弃才能发动。原本种族和丢弃的怪兽的其中任意种相同而攻击力是1850以下的1只地属性怪兽从卡组加入手卡。这个效果的发动后，直到回合结束时自己不能把地属性以外的怪兽的效果发动。
-- ②：自己的地属性怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。
function c62803464.initial_effect(c)
	-- ①：从手卡把这张卡和1只地属性怪兽丢弃才能发动。原本种族和丢弃的怪兽的其中任意种相同而攻击力是1850以下的1只地属性怪兽从卡组加入手卡。这个效果的发动后，直到回合结束时自己不能把地属性以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,62803464)
	e1:SetCost(c62803464.srcost)
	e1:SetTarget(c62803464.srtg)
	e1:SetOperation(c62803464.srop)
	c:RegisterEffect(e1)
	-- ②：自己的地属性怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,62803465)
	e2:SetCondition(c62803464.spcon)
	e2:SetTarget(c62803464.sptg)
	e2:SetOperation(c62803464.spop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中可作为发动代价丢弃的地属性怪兽（且卡组中存在可检索的怪兽）
function c62803464.filter(c,sc,tp)
	if not (c:IsAttribute(ATTRIBUTE_EARTH) and c:IsDiscardable()) then return false end
	local race=c:GetOriginalRace()|sc:GetOriginalRace()
	-- 检查卡组中是否存在满足检索条件的地属性怪兽
	return Duel.IsExistingMatchingCard(c62803464.srfilter,tp,LOCATION_DECK,0,1,nil,race)
end
-- 过滤卡组中原本种族与丢弃怪兽相同、攻击力1850以下的地属性怪兽
function c62803464.srfilter(c,race)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAttackBelow(1850) and c:IsAbleToHand()
		and c:GetOriginalRace()&race>0
end
-- 效果①的发动代价（从手卡丢弃自身和1只地属性怪兽）
function c62803464.srcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	local c=e:GetHandler()
	-- 检查手卡中是否存在除自身以外的可丢弃地属性怪兽，且自身可丢弃
	if chk==0 then return Duel.IsExistingMatchingCard(c62803464.filter,tp,LOCATION_HAND,0,1,c,c,tp) and c:IsDiscardable() end
	-- 提示玩家选择要丢弃的手卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家选择1只手卡的地属性怪兽作为丢弃的代价
	local g=Duel.SelectMatchingCard(tp,c62803464.filter,tp,LOCATION_HAND,0,1,1,c,c,tp)
	e:SetLabelObject(g:GetFirst())
	g:AddCard(c)
	-- 将选择的怪兽和这张卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 效果①的发动准备与效果分类声明
function c62803464.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()==100
		e:SetLabel(0)
		return res
	end
	e:SetLabel(0)
	-- 设置操作信息为从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（检索地属性怪兽并添加不能发动地属性以外怪兽效果的限制）
function c62803464.srop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sc=e:GetLabelObject()
	local race=c:GetOriginalRace()|sc:GetOriginalRace()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c62803464.srfilter,tp,LOCATION_DECK,0,1,1,nil,race)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个效果的发动后，直到回合结束时自己不能把地属性以外的怪兽的效果发动。②：自己的地属性怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c62803464.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该回合内不能发动地属性以外怪兽效果的玩家限制
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能发动的怪兽效果类型（非地属性怪兽的效果）
function c62803464.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsNonAttribute(ATTRIBUTE_EARTH)
end
-- 过滤被战斗破坏送去墓地的我方场上的表侧表示地属性怪兽
function c62803464.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_EARTH)~=0
end
-- 效果②的发动条件（自己的地属性怪兽被战斗破坏时）
function c62803464.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c62803464.cfilter,1,nil,tp)
end
-- 效果②的发动准备与效果分类声明
function c62803464.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自身是否能特殊召唤以及怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的效果处理（将自身特殊召唤）
function c62803464.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
