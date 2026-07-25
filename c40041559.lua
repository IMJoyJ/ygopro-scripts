--Genia of the Ring
-- 效果：
-- 这张卡在手卡存在的场合：可以以场上1只表侧表示怪兽为对象；这张卡特殊召唤，作为对象的怪兽变成魔法师族。这个回合，作为对象的怪兽只有1次不会被卡的效果破坏，这个效果的发动后，直到回合结束时自己不是魔法师族怪兽不能从额外卡组特殊召唤。
-- 这张卡为让魔法师族怪兽的效果发动而被解放或者被除外的场合：可以把这张卡加入手卡。
-- 「戒指的魔灵」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 注册①②③效果
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合：可以以场上1只表侧表示怪兽为对象；这张卡特殊召唤，作为对象的怪兽变成魔法师族。这个回合，作为对象的怪兽只有1次不会被卡的效果破坏，这个效果的发动后，直到回合结束时自己不是魔法师族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡为让魔法师族怪兽的效果发动而被解放或者被除外的场合：可以把这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
-- 过滤场上表侧表示的怪兽
function s.spfilter(c)
	return c:IsFaceup()
end
-- ①效果的 Target 函数：以场上1只表侧表示怪兽为对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.spfilter(chkc) end
	local c=e:GetHandler()
	-- 检查场上是否存在表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查怪兽区是否有空位以及自身是否可以特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只表侧表示怪兽为对象
	Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的 Operation 函数：这张卡特殊召唤，作为对象的怪兽变成魔法师族且赋予1次卡效果破坏抗性，本回合限制从额外卡组特殊召唤魔法师族怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) and not tc:IsImmuneToEffect(e) then
		-- 作为对象的怪兽变成魔法师族。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_SPELLCASTER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个回合，作为对象的怪兽只有1次不会被卡的效果破坏，
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCountLimit(1)
		e2:SetValue(s.valcon)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
	-- 这个效果的发动后，直到回合结束时自己不是魔法师族怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetTarget(s.splimit)
	-- 给玩家注册全局限制：不能从额外卡组特殊召唤非魔法师族怪兽
	Duel.RegisterEffect(e3,tp)
end
-- 判断破坏原因是否为卡的效果
function s.valcon(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 限制不能从额外卡组特殊召唤非魔法师族怪兽
function s.splimit(e,c)
	return not c:IsRace(RACE_SPELLCASTER) and c:IsLocation(LOCATION_EXTRA)
end
-- 检查发动条件：是否为让魔法师族怪兽的效果发动而被解放或被除外
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsRace(RACE_SPELLCASTER)
end
-- ②效果的 Target 函数：检查这张卡是否可以加入手卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果的 Operation 函数：将这张卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍然存在并受王家长眠之谷等影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 可以把这张卡加入手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
