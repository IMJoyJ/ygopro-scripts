--R.B.ラスト・スタンド
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：同名卡不在自己场上存在的1只「反叛曲机器人」怪兽从自己的卡组·额外卡组·墓地特殊召唤。这张卡的发动后，直到回合结束时自己不是攻击力1500以下的机械族怪兽不能从额外卡组特殊召唤。
-- ②：自己场上的「反叛曲机器人」怪兽为对象的魔法·陷阱·怪兽的效果由对方发动时，把墓地的这张卡除外才能发动。那个效果无效。
local s,id,o=GetID()
-- 初始化并注册①②两个效果：①为在自由时点可发动的魔陷发动类特殊召唤效果，②为墓地的诱发即时无效效果，两者共用同一卡号次数限制，即这个卡名的①②的效果1回合只能有1次使用其中任意1个
function s.initial_effect(c)
	-- ①：同名卡不在自己场上存在的1只「反叛曲机器人」怪兽从自己的卡组·额外卡组·墓地特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的「反叛曲机器人」怪兽为对象的魔法·陷阱·怪兽的效果由对方发动时，把墓地的这张卡除外才能发动。那个效果无效
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.discon)
	-- 设置发动代价：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
-- 特殊召唤过滤函数：是「反叛曲机器人」怪兽、可以被特殊召唤、自己场上不存在其同名卡，且位于卡组·墓地时需有可用的主要怪兽区、位于额外卡组时需有可用的额外出场空格
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1cf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认自己场上不存在与该卡同名的表侧表示的卡
		and not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_ONFIELD,0,1,nil,c:GetCode())
		-- 若该卡位于卡组或墓地，则要求自己场上有可用的主要怪兽区
		and (c:IsLocation(LOCATION_DECK+LOCATION_GRAVE) and Duel.GetMZoneCount(tp)>0
			-- 若该卡位于额外卡组，则要求自己场上有能让额外卡组怪兽出场的可用空格
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- ①效果的对象函数：确认存在满足条件的可特殊召唤的怪兽，并设置特殊召唤的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己的卡组·额外卡组·墓地存在至少1只满足条件的「反叛曲机器人」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：预计从自己的卡组·额外卡组·墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA)
end
-- ①效果处理：提示并让自己选择1只满足条件的「反叛曲机器人」怪兽特殊召唤；若是通过卡的发动处理，则注册本回合的额外卡组特殊召唤限制
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示「请选择要特殊召唤的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己从卡组·额外卡组·墓地选择1只满足条件且不受王家长眠之谷影响的「反叛曲机器人」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不是攻击力1500以下的机械族怪兽不能从额外卡组特殊召唤。②：自己场上的「反叛曲机器人」怪兽为对象的魔法·陷阱·怪兽的效果由对方发动时……那个效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		-- 把该特殊召唤限制效果注册为玩家效果，直到回合结束时适用
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制条件：从额外卡组特殊召唤的怪兽若不是攻击力1500以下的机械族怪兽，则不能特殊召唤
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_MACHINE) and c:GetTextAttack()>=0 and c:GetTextAttack()<=1500)
end
-- 过滤函数：自己场上表侧表示存在的「反叛曲机器人」怪兽
function s.cfilter(c,tp)
	return c:IsSetCard(0x1cf) and c:IsLocation(LOCATION_MZONE)
		and c:IsControler(tp) and c:IsFaceup()
end
-- ②效果的发动条件：对方发动的效果取卡为对象，取得该连锁的对象卡片组，且该连锁可以被无效、对象中包含自己场上的「反叛曲机器人」怪兽
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 取得该连锁的效果所取的的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g then return false end
	local c=e:GetHandler()
	-- 检查该连锁的发动能否被无效
	return Duel.IsChainNegatable(ev)
		and g:IsExists(s.cfilter,1,nil,tp)
end
-- ②效果的目标函数：设置使效果无效的操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将发动的那个效果作为使无效的处理对象
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ②效果处理：使那个效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的效果无效
	Duel.NegateEffect(ev)
end
