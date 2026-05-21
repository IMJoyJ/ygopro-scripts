--Recette de Spécialité～料理長自慢のレシピ～
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「新式魔厨」仪式怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效。「新式魔厨」怪兽的效果特殊召唤的怪兽在自己场上存在的场合，可以再把那张无效的卡破坏。
-- ②：自己对「饥饿的汉堡」的特殊召唤成功的场合，把墓地的这张卡除外才能发动。对方场上的怪兽尽可能解放。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（发动无效并可选破坏）和②效果（墓地除外解放对方场上怪兽）。
function s.initial_effect(c)
	-- ①：自己场上有「新式魔厨」仪式怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效。「新式魔厨」怪兽的效果特殊召唤的怪兽在自己场上存在的场合，可以再把那张无效的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	-- ②：自己对「饥饿的汉堡」的特殊召唤成功的场合，把墓地的这张卡除外才能发动。对方场上的怪兽尽可能解放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"对方场上的怪兽尽可能解放"
	e2:SetCategory(CATEGORY_RELEASE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.relcon)
	-- 设置发动代价为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.reltg)
	e2:SetOperation(s.relop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「新式魔厨」仪式怪兽。
function s.negfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x196) and c:GetType()&0x81==0x81
end
-- ①效果的发动条件：自己场上有「新式魔厨」仪式怪兽存在，且对方连锁中的卡片发动可以被无效。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「新式魔厨」仪式怪兽。
	return Duel.IsExistingMatchingCard(s.negfilter,tp,LOCATION_MZONE,0,1,nil)
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
		-- 并且该连锁的发动可以被无效。
		and Duel.IsChainNegatable(ev)
end
-- ①效果的发动准备与目标确认，设置操作信息为无效该发动。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 过滤条件：自己场上表侧表示的、由「新式魔厨」怪兽的效果特殊召唤的怪兽。
function s.descfilter(c)
	return c:IsFaceup() and c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x196)
end
-- ①效果的处理：使该发动无效，若满足条件则可选择将该卡破坏。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 如果成功使发动无效，且该卡在场上并可以被破坏。
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) and rc:IsDestructable()
		-- 并且自己场上存在由「新式魔厨」怪兽的效果特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(s.descfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 询问玩家是否选择将那张无效的卡破坏。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把那张卡破坏？"
		-- 中断当前效果处理，使后续的破坏处理不与无效同时进行。
		Duel.BreakEffect()
		-- 将那张无效的卡破坏。
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
-- 过滤条件：由自己特殊召唤的、表侧表示的「饥饿的汉堡」。
function s.relfilter(c,tp)
	return c:IsCode(30243636) and c:IsFaceup() and c:IsSummonPlayer(tp)
end
-- ②效果的发动条件：自己对「饥饿的汉堡」的特殊召唤成功。
function s.relcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.relfilter,1,nil,tp)
end
-- ②效果的发动准备与目标确认，检查对方场上是否存在可以被效果解放的怪兽。
function s.reltg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只可以被效果解放的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,1,nil) end
end
-- ②效果的处理：将对方场上的怪兽尽可能解放。
function s.relop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有可以被效果解放的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		-- 将获取到的怪兽全部解放。
		Duel.Release(g,REASON_EFFECT)
	end
end
