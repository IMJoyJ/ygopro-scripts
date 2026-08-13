--超念導体ビヒーマス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡和对方怪兽进行过战斗时，可以把那只怪兽和这张卡从游戏中除外。
function c15028680.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整怪兽（任意）＋1只以上调整以外的怪兽（任意）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡和对方怪兽进行过战斗时，可以把那只怪兽和这张卡从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15028680,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLED)
	e1:SetTarget(c15028680.target)
	e1:SetOperation(c15028680.operation)
	c:RegisterEffect(e1)
end
-- 【伤害计算后时点】发动条件判定：若本卡是对方怪兽的攻击目标且攻击怪兽可以除外，或本卡是攻击怪兽且对方攻击目标可以除外，则允许发动；随后将攻击怪兽与攻击目标中仍与本次战斗相关的卡组成对象组，并设置除外操作信息（数量为组内卡数）。
function c15028680.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取当前战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前战斗的攻击目标怪兽（直接攻击时为nil）。
	local t=Duel.GetAttackTarget()
	if chk==0 then
		return (t==c and a:IsAbleToRemove())
			or (a==c and t~=nil and t:IsAbleToRemove())
	end
	local g=Group.CreateGroup()
	if a:IsRelateToBattle() then g:AddCard(a) end
	if t~=nil and t:IsRelateToBattle() then g:AddCard(t) end
	-- 设置本次效果的操作信息：类别为除外，对象为g，除外数量为g:GetCount()，目标玩家和位置不限制（0）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果处理：重新获取本次战斗的攻击怪兽和攻击目标，将它们组成组，再从中筛选出仍与本次战斗相关的卡，最后将这些卡以表侧表示除外。
function c15028680.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击怪兽（在效果处理阶段重新获取）。
	local a=Duel.GetAttacker()
	-- 获取当前战斗的攻击目标怪兽（在效果处理阶段重新获取，直接攻击时为nil）。
	local d=Duel.GetAttackTarget()
	local g=Group.FromCards(a,d)
	local rg=g:Filter(Card.IsRelateToBattle,nil)
	-- 将筛选出的卡以表侧表示从游戏中除外，除外原因是效果。
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
end
