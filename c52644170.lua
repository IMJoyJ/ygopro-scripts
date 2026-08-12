--メンタルクロス・デーモン
-- 效果：
-- 念动力族调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，以自己的除外状态的1只7星以下的念动力族怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：自己·对方的战斗阶段，把自己场上1只其他怪兽解放才能发动。自己基本分回复那只怪兽的原本攻击力的数值，这张卡的攻击力直到回合结束时上升那个数值。
local s,id,o=GetID()
-- 初始化效果，设置同调召唤手续并注册两个诱发即时效果
function s.initial_effect(c)
	-- 为该卡添加同调召唤手续，要求1只念动力族调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_PSYCHO),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 设置第一个诱发即时效果，用于特殊召唤除外状态的念动力族7星以下怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 设置第二个诱发即时效果，用于在战斗阶段解放怪兽回复LP并提升自身攻击力
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回复基本分"
	e2:SetCategory(CATEGORY_RECOVER+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.lpcon)
	e2:SetCost(s.lpcost)
	e2:SetTarget(s.lptg)
	e2:SetOperation(s.lpop)
	c:RegisterEffect(e2)
end
-- 判断是否处于主要阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于主要阶段
	return Duel.IsMainPhase()
end
-- 定义特殊召唤目标怪兽的过滤条件
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsRace(RACE_PSYCHO) and c:IsLevelBelow(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 设置特殊召唤效果的目标选择函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.spfilter(chkc,e,tp) and chkc:IsControler(tp) end
	-- 检查是否有足够的场上空位和满足条件的目标怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的目标怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的目标怪兽
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息，确定特殊召唤的目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 设置特殊召唤效果的操作函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否处于战斗阶段
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于战斗阶段
	return Duel.IsBattlePhase()
end
-- 定义解放怪兽的过滤条件，要求攻击力大于0
function s.cfilter(c)
	return c:GetTextAttack()>0
end
-- 设置回复LP效果的费用支付函数
function s.lpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 检查是否有满足条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,e:GetHandler()) end
	-- 选择满足条件的可解放怪兽
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,e:GetHandler())
	e:SetLabel(g:GetFirst():GetTextAttack())
	-- 解放选中的怪兽作为费用
	Duel.Release(g,REASON_COST)
end
-- 设置回复LP效果的目标选择函数
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabel()~=0 end
	-- 设置操作信息中的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置操作信息中的目标参数
	Duel.SetTargetParam(e:GetLabel())
	-- 设置操作信息，确定回复LP的数量
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,e:GetLabel())
	e:SetLabel(0)
end
-- 设置回复LP并提升攻击力的效果操作函数
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复指定数值的LP
	local lp=Duel.Recover(p,d,REASON_EFFECT)
	if lp>0 and c:IsFaceup() and c:IsRelateToChain() then
		-- 创建一个临时效果，使自身攻击力提升指定数值直到回合结束
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(lp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
