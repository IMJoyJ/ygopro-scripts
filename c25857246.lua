--ヴァルキュルスの影霊衣
-- 效果：
-- 「影灵衣」仪式魔法卡降临
-- 这张卡若非以只使用除8星以外的怪兽来作的仪式召唤则不能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：对方怪兽的攻击宣言时，从自己墓地把1张「影灵衣」卡除外，把这张卡从手卡丢弃才能发动。那次攻击无效。那之后，战斗阶段结束。
-- ②：自己主要阶段才能发动。自己的手卡·场上最多2只怪兽解放，自己抽出那个数量。
function c25857246.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：对方怪兽的攻击宣言时，从自己墓地把1张「影灵衣」卡除外，把这张卡从手卡丢弃才能发动。那次攻击无效。那之后，战斗阶段结束。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置此卡的特殊召唤条件为必须通过仪式召唤且使用的仪式怪兽不能是8星
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。自己的手卡·场上最多2只怪兽解放，自己抽出那个数量。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25857246,0))  --"攻击无效"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,25857246)
	e2:SetCondition(c25857246.atkcon)
	e2:SetCost(c25857246.atkcost)
	e2:SetOperation(c25857246.atkop)
	c:RegisterEffect(e2)
	-- 设置此卡的起动效果为在主要阶段发动，消耗手卡或场上的怪兽解放来抽卡
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(25857246,1))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,25857247)
	e3:SetTarget(c25857246.target)
	e3:SetOperation(c25857246.operation)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断怪兽是否不是8星
function c25857246.mat_filter(c)
	return not c:IsLevel(8)
end
-- 判断攻击方是否为对方
function c25857246.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击方是否为对方
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 过滤函数，用于判断墓地的卡是否为「影灵衣」卡且可以除外
function c25857246.cfilter(c)
	return c:IsSetCard(0xb4) and c:IsAbleToRemoveAsCost()
end
-- 判断是否满足发动条件：手卡可丢弃且墓地有「影灵衣」卡可除外
function c25857246.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable()
		-- 判断是否满足发动条件：手卡可丢弃且墓地有「影灵衣」卡可除外
		and Duel.IsExistingMatchingCard(c25857246.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择墓地一张「影灵衣」卡除外
	local g=Duel.SelectMatchingCard(tp,c25857246.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 将此卡丢入墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 无效攻击并跳过对方的战斗阶段
function c25857246.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效此次攻击
	if Duel.NegateAttack() then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 跳过对方的战斗阶段
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
-- 设置发动效果的条件：可以抽卡且场上或手卡有可解放的怪兽
function c25857246.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 判断场上或手卡是否有可解放的怪兽
		and Duel.CheckReleaseGroupEx(tp,nil,1,REASON_EFFECT,true,nil) end
	-- 设置效果发动时的操作信息为抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果，根据解放的怪兽数量进行抽卡
function c25857246.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否可以抽卡
	if not Duel.IsPlayerCanDraw(tp) then return end
	-- 获取玩家牌组的卡数
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct==0 then ct=1 end
	if ct>2 then ct=2 end
	-- 选择场上或手卡中最多可解放数量的怪兽
	local g=Duel.SelectReleaseGroupEx(tp,nil,1,ct,REASON_EFFECT,true,nil)
	if g:GetCount()>0 then
		-- 显示选中的怪兽被解放的动画
		Duel.HintSelection(g)
		-- 解放选中的怪兽
		local rct=Duel.Release(g,REASON_EFFECT)
		-- 根据解放的怪兽数量进行抽卡
		Duel.Draw(tp,rct,REASON_EFFECT)
	end
end
