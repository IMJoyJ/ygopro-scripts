--指環の精霊ジーニャ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，以场上1只表侧表示怪兽为对象才能发动。这张卡特殊召唤。作为对象的表侧表示怪兽变成魔法师族，这个回合只有1次不会被效果破坏。这个回合，自己不是魔法师族怪兽不能从额外卡组特殊召唤。
-- ②：这张卡为让魔法师族怪兽的效果发动，被解放的场合或者被除外的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册①效果为在手卡发动的起动效果，取场上1只表侧表示怪兽为对象，分类为特殊召唤，1回合只能使用1次；注册②效果为自身被解放时触发的一速诱发选发效果，分类为回手卡，1回合只能使用1次；再复制一个②效果改为自身被除外时触发并注册。
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，以场上1只表侧表示怪兽为对象才能发动。这张卡特殊召唤。
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
	-- ②：这张卡为让魔法师族怪兽的效果发动，被解放的场合或者被除外的场合才能发动。这张卡加入手卡。
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
-- 对象过滤条件：目标卡为表侧表示的怪兽。
function s.spfilter(c)
	return c:IsFaceup()
end
-- ①效果的目标函数：检查时点选择是否合法；发动条件检查：场上存在可以成为对象的表侧表示怪兽、自己主要怪兽区有空位且这张卡可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.spfilter(chkc) end
	local c=e:GetHandler()
	-- 发动条件检查：双方主要怪兽区存在1只以上可以成为效果对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 发动条件检查：自己主要怪兽区还有空位，且这张卡满足特殊召唤条件。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向玩家提示「请选择效果的对象」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择双方主要怪兽区1只表侧表示怪兽作为效果对象。
	Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：宣告本次连锁将确定特殊召唤这张卡自身1只。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：这张卡还在连锁关系内则将其表侧表示特殊召唤；取回效果对象，若对象仍为连锁相关的场上表侧表示怪兽且不免疫此效果，则赋予其变成魔法师族的效果和本回合1次不会被效果破坏的效果；最后注册一个持续到回合结束的限制效果，使自己这个回合不能从额外卡组特殊召唤魔法师族以外的怪兽。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡从手卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 取回当前连锁的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) and not tc:IsImmuneToEffect(e) then
		-- 作为对象的表侧表示怪兽变成魔法师族。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_SPELLCASTER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个回合只有1次不会被效果破坏。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCountLimit(1)
		e2:SetValue(s.valcon)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
	-- 这个回合，自己不是魔法师族怪兽不能从额外卡组特殊召唤。②：这张卡为让魔法师族怪兽的效果发动，被解放的场合或者被除外的场合才能发动。这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetTarget(s.splimit)
	-- 把不能特殊召唤的限制效果注册给当前回合玩家，持续到这个回合结束。
	Duel.RegisterEffect(e3,tp)
end
-- 效果破坏抗性判定：仅当破坏原因是效果时才适用不会被破坏。
function s.valcon(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 特殊召唤限制条件：禁止从额外卡组特殊召唤魔法师族以外的怪兽。
function s.splimit(e,c)
	return not c:IsRace(RACE_SPELLCASTER) and c:IsLocation(LOCATION_EXTRA)
end
-- ②效果发动条件：这张卡作为魔法师族怪兽的效果发动的代价被解放或被除外。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsRace(RACE_SPELLCASTER)
end
-- ②效果目标函数：发动条件为这张卡可以加入手卡，并设置回手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：宣告本次连锁将确定把这张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果处理：这张卡仍与连锁相关且不受王家长眠之谷影响时，将其以效果原因加入持有者的手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与当前连锁相关，且不受王家长眠之谷的影响。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 以效果原因把这张卡送去持有者的手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
