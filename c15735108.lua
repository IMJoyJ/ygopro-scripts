--マジックカード「クロス・ソウル」
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：进行1只怪兽的上级召唤。那个时候，也能作为自己场上的怪兽的代替而把对方场上的怪兽解放。这个效果上级召唤的怪兽在这个回合不能解放。
-- ②：这张卡从场上送去墓地的场合发动。对方可以让这张卡的①的效果适用。
local s,id,o=GetID()
-- 注册卡片的两个效果：①通常召唤效果和②对方发动效果
function s.initial_effect(c)
	-- ①：进行1只怪兽的上级召唤。那个时候，也能作为自己场上的怪兽的代替而把对方场上的怪兽解放。这个效果上级召唤的怪兽在这个回合不能解放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合发动。对方可以让这张卡的①的效果适用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.sumcon2)
	e2:SetTarget(s.sumtg2)
	e2:SetOperation(s.sumop2)
	c:RegisterEffect(e2)
end
-- 定义过滤函数，用于判断手牌是否可以被上级召唤
function s.sumfilter(c,ec)
	-- 为手牌添加额外祭品要求（攻击表示或守备表示）
	local e1=Effect.CreateEffect(ec)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
	c:RegisterEffect(e1)
	local res=c:IsSummonable(true,nil,1) or c:IsMSetable(true,nil,1)
	e1:Reset()
	return res
end
-- 设置效果的发动条件，检查手牌中是否存在满足召唤条件的卡
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在满足召唤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil,e:GetHandler()) end
	-- 设置连锁操作信息，表示将要进行召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 处理效果发动时的选择和召唤操作
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 选择满足条件的卡
	local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil,c):GetFirst()
	if tc then s.summon(e,tp,tc) end
end
-- 执行召唤操作，根据卡的召唤方式决定是通常召唤还是Set
function s.summon(e,tp,tc)
	local c=e:GetHandler()
	-- 为召唤的卡添加额外祭品要求
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local s1=tc:IsSummonable(true,nil,1)
	local s2=tc:IsMSetable(true,nil,1)
	-- 根据召唤方式和位置选择决定是通常召唤还是Set
	if (s1 and s2 and Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) or not s2 then
		-- 执行通常召唤
		Duel.Summon(tp,tc,true,nil,1)
	else
		-- 执行Set
		Duel.MSet(tp,tc,true,nil,1)
	end
	-- 设置召唤的怪兽在本回合不能被解放
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	tc:RegisterEffect(e2,true)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	tc:RegisterEffect(e3,true)
end
-- 判断此卡是否从场上送去墓地
function s.sumcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 设置效果的发动条件，允许对方选择是否使用此卡效果
function s.sumtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，表示将要进行召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 处理对方选择使用此卡效果时的召唤操作
function s.sumop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查对方手牌中是否存在满足召唤条件的卡，并询问对方是否使用此卡效果
	if Duel.IsExistingMatchingCard(s.sumfilter,1-tp,LOCATION_HAND,0,1,nil,c) and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then  --"是否使用「魔法卡「灵魂交错」」的效果？"
		-- 提示对方玩家选择要召唤的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
		-- 选择满足条件的卡
		local tc=Duel.SelectMatchingCard(1-tp,s.sumfilter,1-tp,LOCATION_HAND,0,1,1,nil,c):GetFirst()
		s.summon(e,1-tp,tc)
	end
end
