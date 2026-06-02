--白竜の聖騎士
-- 效果：
-- 「白龙降临」降临。
-- ①：这张卡向里侧守备表示怪兽攻击的伤害步骤开始时发动。那只里侧守备表示怪兽破坏。
-- ②：把这张卡解放才能发动。从手卡·卡组把1只「青眼白龙」特殊召唤。这个回合，自己的「青眼白龙」不能攻击。
function c73398797.initial_effect(c)
	aux.AddCodeList(c,89631139,9786492)
	c:EnableReviveLimit()
	-- ①：这张卡向里侧守备表示怪兽攻击的伤害步骤开始时发动。那只里侧守备表示怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73398797,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCondition(c73398797.descon)
	e1:SetTarget(c73398797.destg)
	e1:SetOperation(c73398797.desop)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放才能发动。从手卡·卡组把1只「青眼白龙」特殊召唤。这个回合，自己的「青眼白龙」不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73398797,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c73398797.spcost)
	e2:SetTarget(c73398797.sptg)
	e2:SetOperation(c73398797.spop)
	c:RegisterEffect(e2)
end
-- 效果①（攻击里侧守备表示怪兽时将其破坏）的发动条件函数
function c73398797.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	-- 检查自身是否为攻击怪兽，且攻击目标存在并且是里侧守备表示
	return e:GetHandler()==Duel.GetAttacker() and d and d:IsPosition(POS_FACEDOWN_DEFENSE)
end
-- 效果①的发动准备函数
function c73398797.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为破坏攻击目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
-- 效果①的处理函数
function c73398797.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		-- 因效果破坏该怪兽
		Duel.Destroy(d,REASON_EFFECT)
	end
end
-- 效果②（解放自身特召青眼白龙）的发动代价函数
function c73398797.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：卡名为「青眼白龙」且可以被特殊召唤
function c73398797.spfilter(c,e,tp)
	return c:IsCode(89631139) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备函数
function c73398797.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有可用空位（因为自身会被解放，所以可用空位数量大于-1即可）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 并且手卡或卡组中存在至少1只满足特召条件的「青眼白龙」
		and Duel.IsExistingMatchingCard(c73398797.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的处理函数
function c73398797.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否还有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡或卡组选择1只「青眼白龙」
	local g=Duel.SelectMatchingCard(tp,c73398797.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将选中的「青眼白龙」以表侧表示特殊召唤
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	-- 这个回合，自己的「青眼白龙」不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	-- 设置不能攻击的效果对象为卡名为「青眼白龙」的怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,89631139))
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局注册该不能攻击的场上效果
	Duel.RegisterEffect(e1,tp)
end
