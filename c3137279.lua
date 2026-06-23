--ゴーティスの兆イグジープ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：鱼族怪兽被除外的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被除外的下个回合的准备阶段，以自己的墓地·除外状态的1张「魊影」陷阱卡为对象才能发动。那张卡在自己场上盖放。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②效果
function s.initial_effect(c)
	-- ①：鱼族怪兽被除外的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_REMOVE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的下个回合的准备阶段，以自己的墓地·除外状态的1张「魊影」陷阱卡为对象才能发动。那张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 判断是否满足①效果的发动条件，即是否有鱼族怪兽被除外
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH)
end
-- 判断是否满足①效果的发动条件，即是否有鱼族怪兽被除外
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
-- ①效果的发动时的处理，判断是否可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的发动处理，将卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的发动条件判断，判断是否为下个回合的准备阶段
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否为下个回合的准备阶段
	return Duel.GetTurnCount()-c:GetTurnID()==1
end
-- 筛选满足②效果发动条件的「魊影」陷阱卡
function s.setfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_TRAP) and c:IsSetCard(0x18a) and c:IsSSetable()
end
-- ②效果的发动时的处理，选择要盖放的卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.setfilter(chkc) end
	-- 判断是否有满足条件的卡可以盖放
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择要盖放的卡
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 设置操作信息，表示将卡从墓地离开
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- ②效果的发动处理，将卡盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 执行盖放操作
		Duel.SSet(tp,tc)
	end
end
