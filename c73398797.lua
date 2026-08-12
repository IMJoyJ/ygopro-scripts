--白竜の聖騎士
-- 效果：
-- 「白龙降临」降临。
-- ①：这张卡向里侧守备表示怪兽攻击的伤害步骤开始时发动。那只里侧守备表示怪兽破坏。
-- ②：把这张卡解放才能发动。从手卡·卡组把1只「青眼白龙」特殊召唤。这个回合，自己的「青眼白龙」不能攻击。
function c73398797.initial_effect(c)
	-- 注册该卡记有「青眼白龙」和「白龙降临」卡名的关联关系
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
	-- ②：把这张卡解放才能发动。从手卡·卡组把1只「青眼白龙」特殊召唤。
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
-- 伤害步骤开始时自身向里侧守备表示怪兽攻击的发动条件判断函数
function c73398797.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为被攻击目标的里侧守备表示怪兽
	local d=Duel.GetAttackTarget()
	-- 检查自身是否是攻击怪兽，且存在被攻击怪兽并且其处于里侧守备表示状态
	return e:GetHandler()==Duel.GetAttacker() and d and d:IsPosition(POS_FACEDOWN_DEFENSE)
end
-- ①效果的发动可行性检查函数（Target）
function c73398797.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前效果包含破坏作为攻击目标怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
-- ①效果的结算操作函数（Operation）
function c73398797.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为被攻击目标的怪兽
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		-- 将攻击目标的里侧守备表示怪兽破坏
		Duel.Destroy(d,REASON_EFFECT)
	end
end
-- ②效果的发动代价函数，检查并解放自身
function c73398797.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为效果发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤手卡·卡组中能被特殊召唤的「青眼白龙」的过滤条件
function c73398797.spfilter(c,e,tp)
	return c:IsCode(89631139) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动可行性检查函数（Target）
function c73398797.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查若自身解放后，场上的怪兽区域是否有可放置特殊召唤怪兽的空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡或卡组中是否存在可以特殊召唤的「青眼白龙」
		and Duel.IsExistingMatchingCard(c73398797.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前效果包含从手卡或卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果的结算操作函数（Operation）
function c73398797.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若场上已无怪兽区域空格，结算终止
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己手卡或卡组中1张符合过滤条件的「青眼白龙」
	local g=Duel.SelectMatchingCard(tp,c73398797.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将选中的怪兽以正面表示特殊召唤
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	-- 这个回合，自己的「青眼白龙」不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	-- 设置不能攻击效果的作用对象为「青眼白龙」
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,89631139))
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在玩家的全局环境注册该效果
	Duel.RegisterEffect(e1,tp)
end
