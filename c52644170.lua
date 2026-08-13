--メンタルクロス・デーモン
-- 效果：
-- 念动力族调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，以自己的除外状态的1只7星以下的念动力族怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：自己·对方的战斗阶段，把自己场上1只其他怪兽解放才能发动。自己基本分回复那只怪兽的原本攻击力的数值，这张卡的攻击力直到回合结束时上升那个数值。
local s,id,o=GetID()
-- 定义该卡的初始效果函数：为卡添加同调召唤手续，并注册①特殊召唤与②回复·攻击力上升两个诱发即时效果。
function s.initial_effect(c)
	-- 设置同调召唤手续：素材要求为‘念动力族调整＋调整以外的怪兽1只以上’，即调整必须为念动力族，非调整任意。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_PSYCHO),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己·对方的主要阶段，以自己的除外状态的1只7星以下的念动力族怪兽为对象才能发动。那只怪兽特殊召唤。
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
	-- ②：自己·对方的战斗阶段，把自己场上1只其他怪兽解放才能发动。自己基本分回复那只怪兽的原本攻击力的数值，这张卡的攻击力直到回合结束时上升那个数值。
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
-- ①效果的发动条件判断：当处于主要阶段时允许发动（自己·对方的主要阶段均可）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前是否为主要阶段。
	return Duel.IsMainPhase()
end
-- 定义①效果的对象筛选函数：选择自己除外状态的1只7星以下的念动力族怪兽，且该怪兽可以被特殊召唤（表侧表示）。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsRace(RACE_PSYCHO) and c:IsLevelBelow(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- ①效果的发动判定与目标选择：若指定对象则校验其位于除外区且满足筛选条件；未指定时检查是否有空位且存在可选择的‘除外状态的念动力族怪兽’。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.spfilter(chkc,e,tp) and chkc:IsControler(tp) end
	-- 发动前检查自己场上是否有可用的主要怪兽区域空位，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在满足s.spfilter条件的念动力族怪兽，可作为效果对象。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向玩家显示‘请选择要特殊召唤的卡’的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己除外状态的符合条件的怪兽中选择1只，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息：本连锁将把对象怪兽特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：取得对象怪兽，若其仍与连锁相关，则将其以表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得连锁处理时的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上（不追加额外条件）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件判断：只在战斗阶段内可以发动。
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前是否为战斗阶段。
	return Duel.IsBattlePhase()
end
-- 定义解放代价的筛选函数：选择原本攻击力大于0的怪兽（用于回复其原本攻击力的数值）。
function s.cfilter(c)
	return c:GetTextAttack()>0
end
-- ②效果的代价处理：从自己场上选择1只其他原本攻击力大于0的怪兽解放，并将其原本攻击力数值暂时记录在效果标签中，供后续回复使用。
function s.lpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 检查自己场上是否存在1只可解放且原本攻击力大于0的怪兽作为代价。
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,e:GetHandler()) end
	-- 选择1只满足条件的‘其他怪兽’作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,e:GetHandler())
	e:SetLabel(g:GetFirst():GetTextAttack())
	-- 将选择的怪兽解放，作为发动②效果的代价。
	Duel.Release(g,REASON_COST)
end
-- ②效果的目标设定：将回复对象设为自己，回复数值设为解放怪兽的原本攻击力，并设置操作信息；同时清空标签。
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabel()~=0 end
	-- 设置本连锁的目标玩家为发动者自己（LP回复对象）。
	Duel.SetTargetPlayer(tp)
	-- 设置本连锁的目标参数为解放怪兽的原本攻击力数值。
	Duel.SetTargetParam(e:GetLabel())
	-- 设置操作信息：本连锁将进行LP回复，回复量为记录的数值。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,e:GetLabel())
	e:SetLabel(0)
end
-- ②效果处理：执行LP回复，若实际回复且此卡仍表侧在场，则让此卡的攻击力上升回复数值直到回合结束。
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从当前连锁信息中取得之前设置的目标玩家和回复参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家回复对应数值的LP，得到实际回复量lp。
	local lp=Duel.Recover(p,d,REASON_EFFECT)
	if lp>0 and c:IsFaceup() and c:IsRelateToChain() then
		-- 这张卡的攻击力直到回合结束时上升那个数值。
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
