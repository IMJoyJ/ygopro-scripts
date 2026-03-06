--ダイノルフィア・リヴァージョン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「恐啡肽狂龙」融合怪兽存在的场合，把基本分支付一半，从自己墓地把1张反击陷阱卡除外才能发动。这个效果变成和那张反击陷阱卡发动时的效果相同。
-- ②：自己基本分是2000以下，自己要受到战斗伤害的伤害计算时，把墓地的这张卡除外才能发动。那次战斗发生的对自己的战斗伤害变成0。
function c28292031.initial_effect(c)
	-- ①：自己场上有「恐啡肽狂龙」融合怪兽存在的场合，把基本分支付一半，从自己墓地把1张反击陷阱卡除外才能发动。这个效果变成和那张反击陷阱卡发动时的效果相同。
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
	-- 将墓地的这张卡除外作为cost
	e0:SetCost(aux.bfgcost)
	e0:SetOperation(c28292031.damop)
	c:RegisterEffect(e0)
end
-- 过滤函数，用于检查场上是否存在「恐啡肽狂龙」融合怪兽
function c28292031.cfilter(c)
	return c:IsSetCard(0x173) and c:IsType(TYPE_FUSION) and c:IsFaceup()
end
-- 效果发动的条件，检查场上是否存在「恐啡肽狂龙」融合怪兽
function c28292031.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在「恐啡肽狂龙」融合怪兽
	return Duel.IsExistingMatchingCard(c28292031.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 支付一半基本分作为cost
function c28292031.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤函数，用于检查墓地是否存在可以发动的反击陷阱卡
function c28292031.filter(c,event)
	if not (c:GetType()==TYPE_TRAP+TYPE_COUNTER and c:IsAbleToRemoveAsCost()) then return false end
	local te=c:CheckActivateEffect(false,true,false)
	return te and te:GetCode()==event
end
-- 效果的发动处理，选择并除外一张反击陷阱卡，复制其效果
function c28292031.target(event)
	return 	function(e,tp,eg,ep,ev,re,r,rp,chk)
			if chk==0 then
				if e:GetLabel()==0 then return false end
				e:SetLabel(0)
				-- 检查墓地是否存在可以发动的反击陷阱卡
				return Duel.IsExistingMatchingCard(c28292031.filter,tp,LOCATION_GRAVE,0,1,nil,event)
			end
			e:SetLabel(0)
			-- 提示玩家选择要除外的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			-- 选择一张反击陷阱卡除外
			local g=Duel.SelectMatchingCard(tp,c28292031.filter,tp,LOCATION_GRAVE,0,1,1,nil,event)
			local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
			-- 支付一半基本分
			Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
			-- 将选中的反击陷阱卡除外
			Duel.Remove(g,POS_FACEUP,REASON_COST)
			e:SetProperty(te:GetProperty())
			local tg=te:GetTarget()
			if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
			te:SetLabelObject(e:GetLabelObject())
			e:SetLabelObject(te)
			-- 清除已注册的处理信息
			Duel.ClearOperationInfo(0)
		end
end
-- 效果的执行处理，执行被复制的效果
function c28292031.operation(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
-- 判断是否满足效果发动条件，基本分≤2000且即将受到战斗伤害
function c28292031.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断基本分≤2000且即将受到战斗伤害
	return Duel.GetLP(tp)<=2000 and Duel.GetBattleDamage(tp)>0
end
-- 效果的执行处理，使下次受到的战斗伤害变为0
function c28292031.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 使下次受到的战斗伤害变为0
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 注册使下次受到的战斗伤害变为0的效果
	Duel.RegisterEffect(e1,tp)
end
