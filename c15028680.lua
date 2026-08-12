--超念導体ビヒーマス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡和对方怪兽进行过战斗时，可以把那只怪兽和这张卡从游戏中除外。
function c15028680.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只以上调整以外的怪兽作为素材
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
-- 设置效果的发动条件为战斗阶段结束时，判断是否满足除外条件
function c15028680.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取本次战斗中攻击的怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗中被攻击的怪兽
	local t=Duel.GetAttackTarget()
	if chk==0 then
		return (t==c and a:IsAbleToRemove())
			or (a==c and t~=nil and t:IsAbleToRemove())
	end
	local g=Group.CreateGroup()
	if a:IsRelateToBattle() then g:AddCard(a) end
	if t~=nil and t:IsRelateToBattle() then g:AddCard(t) end
	-- 设置连锁操作信息，确定将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 设置效果的处理函数，执行除外操作
function c15028680.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗中攻击的怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗中被攻击的怪兽
	local d=Duel.GetAttackTarget()
	local g=Group.FromCards(a,d)
	local rg=g:Filter(Card.IsRelateToBattle,nil)
	-- 将满足条件的卡从游戏中除外
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
end
