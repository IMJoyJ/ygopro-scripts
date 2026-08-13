--ダイノルフィア・リヴァージョン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「恐啡肽狂龙」融合怪兽存在的场合，把基本分支付一半，从自己墓地把1张反击陷阱卡除外才能发动。这个效果变成和那张反击陷阱卡发动时的效果相同。
-- ②：自己基本分是2000以下，自己要受到战斗伤害的伤害计算时，把墓地的这张卡除外才能发动。那次战斗发生的对自己的战斗伤害变成0。
function c28292031.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「恐啡肽狂龙」融合怪兽存在的场合，把基本分支付一半，从自己墓地把1张反击陷阱卡除外才能发动。这个效果变成和那张反击陷阱卡发动时的效果相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28292031,0))  --"复制反击陷阱卡"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,28292031+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c28292031.condition)
	e1:SetCost(c28292031.cost)
	e1:SetTarget(c28292031.target(EVENT_CHAINING))
	e1:SetOperation(c28292031.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_BATTLE_END,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetTarget(c28292031.target(EVENT_FREE_CHAIN))
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SUMMON)
	e3:SetTarget(c28292031.target(EVENT_SUMMON))
	c:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON)
	e4:SetTarget(c28292031.target(EVENT_FLIP_SUMMON))
	c:RegisterEffect(e4)
	local e5=e1:Clone()
	e5:SetCode(EVENT_SPSUMMON)
	e5:SetTarget(c28292031.target(EVENT_SPSUMMON))
	c:RegisterEffect(e5)
	local e6=e1:Clone()
	e6:SetCode(EVENT_TO_HAND)
	e6:SetTarget(c28292031.target(EVENT_TO_HAND))
	c:RegisterEffect(e6)
	local e7=e1:Clone()
	e7:SetCode(EVENT_ATTACK_ANNOUNCE)
	e7:SetTarget(c28292031.target(EVENT_ATTACK_ANNOUNCE))
	c:RegisterEffect(e7)
	-- ②：自己基本分是2000以下，自己要受到战斗伤害的伤害计算时，把墓地的这张卡除外才能发动。那次战斗发生的对自己的战斗伤害变成0。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e0:SetRange(LOCATION_GRAVE)
	e0:SetCondition(c28292031.damcon)
	-- 设置②效果发动时把墓地的这张卡除外作为代价（aux.bfgcost即除外自身作为COST）。
	e0:SetCost(aux.bfgcost)
	e0:SetOperation(c28292031.damop)
	c:RegisterEffect(e0)
end
-- “恐啡肽狂龙融合怪兽”的筛选条件：卡名属于「恐啡肽狂龙」字段、是融合怪兽且表侧表示。
function c28292031.cfilter(c)
	return c:IsSetCard(0x173) and c:IsType(TYPE_FUSION) and c:IsFaceup()
end
-- ①效果的发动条件：自己场上有1只表侧表示的「恐啡肽狂龙」融合怪兽存在。
function c28292031.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足cfilter条件的「恐啡肽狂龙」融合怪兽。
	return Duel.IsExistingMatchingCard(c28292031.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的代价函数：将e的Label置为1，标记已满足支付代价的前提；实际支付一半LP和除外反击陷阱的动作在target流程中统一完成，以便同时处理复制效果。
function c28292031.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 墓地可作为复制对象的反击陷阱卡的筛选条件：必须是反击陷阱、可以除外，且自身存在能在当前时点发动的效果（CheckActivateEffect确认其可发动且效果Code与当前事件一致）。
function c28292031.filter(c,event)
	if not (c:GetType()==TYPE_TRAP+TYPE_COUNTER and c:IsAbleToRemoveAsCost()) then return false end
	local te=c:CheckActivateEffect(false,true,false)
	return te and te:GetCode()==event
end
-- ①效果发动时的选择与复制处理：先检查合法性并确认墓地有符合条件的反击陷阱，玩家选择1张后，支付一半LP并将其除外，然后把被复制反击陷阱卡的效果属性、目标处理等保存到e的LabelObject中，供后续处理时调用。
function c28292031.target(event)
	return 	function(e,tp,eg,ep,ev,re,r,rp,chk)
			if chk==0 then
				if e:GetLabel()==0 then return false end
				e:SetLabel(0)
				-- 确认自己墓地存在1张符合条件的反击陷阱卡，且该卡的效果发动Code与当前时点事件一致。
				return Duel.IsExistingMatchingCard(c28292031.filter,tp,LOCATION_GRAVE,0,1,nil,event)
			end
			e:SetLabel(0)
			-- 弹出“请选择要除外的卡”的提示，让玩家从墓地选择要除外的反击陷阱卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			-- 玩家从自己墓地选择1张符合条件的反击陷阱卡作为复制对象（event作为额外参数传给过滤器）。
			local g=Duel.SelectMatchingCard(tp,c28292031.filter,tp,LOCATION_GRAVE,0,1,1,nil,event)
			local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
			-- 支付自己当前基本分一半的LP作为发动代价。
			Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
			-- 将选择的反击陷阱卡表侧表示除外作为发动代价。
			Duel.Remove(g,POS_FACEUP,REASON_COST)
			e:SetProperty(te:GetProperty())
			local tg=te:GetTarget()
			if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
			te:SetLabelObject(e:GetLabelObject())
			e:SetLabelObject(te)
			-- 清除当前连锁的操作信息，避免被复制的反击陷阱效果在处理过程中被当作新的发动而被错误响应。
			Duel.ClearOperationInfo(0)
		end
end
-- ①效果实际处理时，取出之前保存的被复制反击陷阱卡的效果，并执行该效果的Operation函数，使本效果变成和那张反击陷阱卡发动时的效果相同。
function c28292031.operation(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
-- ②效果的发动条件：自己LP在2000以下，且本次战斗中自己将要受到战斗伤害。
function c28292031.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足“自己基本分是2000以下”且“自己要受到的战斗伤害大于0”。
	return Duel.GetLP(tp)<=2000 and Duel.GetBattleDamage(tp)>0
end
-- ②效果处理时，给己方玩家设置一个“不会受到战斗伤害”的持续效果，使本次战斗对自己的战斗伤害变成0，到伤害阶段结束时重置。
function c28292031.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 那次战斗发生的对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将刚生成的“避免战斗伤害”效果注册到场上，作用于己方玩家，从而把本次对自己的战斗伤害变为0。
	Duel.RegisterEffect(e1,tp)
end
