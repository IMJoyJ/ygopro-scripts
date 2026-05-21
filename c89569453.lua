--断絶の落とし穴
-- 效果：
-- ①：对方把攻击力1500以下的怪兽召唤·反转召唤·特殊召唤时才能发动。那些攻击力1500以下的怪兽里侧除外。
local s,id,o=GetID()
-- 定义卡片的效果，注册在对方通常召唤、反转召唤、特殊召唤成功时发动的魔法·陷阱卡激活效果。
function s.initial_effect(c)
	-- ①：对方把攻击力1500以下的怪兽召唤·反转召唤·特殊召唤时才能发动。那些攻击力1500以下的怪兽里侧除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤条件：对方召唤·反转召唤·特殊召唤的、场上表侧表示且攻击力1500以下、可以被里侧除外的怪兽。
function s.filter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsAttackBelow(1500) and c:IsSummonPlayer(1-tp)
		and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
-- 效果发动的目标检测与处理，确认召唤的怪兽中是否存在符合条件的怪兽，并将其设为效果对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.filter,1,nil,tp) end
	local g=eg:Filter(s.filter,nil,tp)
	-- 将符合条件的怪兽设置为该连锁的效果处理对象。
	Duel.SetTargetCard(g)
	-- 设置操作信息，声明该效果的处理分类为除外，并指定要除外的卡片数量和位置。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 过滤条件：效果处理时，仍表侧表示存在于怪兽区且攻击力在1500以下的怪兽。
function s.rmfilter(c)
	return c:IsFaceup() and c:IsAttackBelow(1500) and c:IsLocation(LOCATION_MZONE)
end
-- 效果处理的执行，筛选出仍与连锁相关的目标怪兽并将其里侧表示除外。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍合法的目标怪兽，并筛选出符合条件的卡片组。
	local g=Duel.GetTargetsRelateToChain():Filter(s.rmfilter,nil)
	if g:GetCount()>0 then
		-- 将筛选出的怪兽因效果里侧表示除外。
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end
