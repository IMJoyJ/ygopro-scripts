--メタファイズ・ファクター
-- 效果：
-- ①：只要这张卡在场地区域存在，自己在5星以上的「玄化」怪兽召唤的场合需要的解放可以不用。这个效果1回合只能适用1次。这个效果适用召唤的怪兽在下个回合的结束阶段除外。
-- ②：只要这张卡在场地区域存在，对方不能对应自己的「玄化」怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。
function c20720928.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，自己在5星以上的「玄化」怪兽召唤的场合需要的解放可以不用。这个效果1回合只能适用1次。这个效果适用召唤的怪兽在下个回合的结束阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20720928,0))  --"使用「玄化因子」效果不用解放召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetCountLimit(1)
	e2:SetCondition(c20720928.ntcon)
	e2:SetTarget(c20720928.nttg)
	e2:SetOperation(c20720928.ntop)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在场地区域存在，对方不能对应自己的「玄化」怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_FZONE)
	e3:SetOperation(c20720928.chainop)
	c:RegisterEffect(e3)
end
-- 无解放召唤手续的发动条件：若查询的怪兽为空（c==nil）则允许适用；否则要求本次召唤无强制解放需求（minc==0）且召唤者主要怪兽区有空位，才能进行免解放召唤。
function c20720928.ntcon(e,c,minc)
	if c==nil then return true end
	-- 本次召唤所需的最低解放数为0（没有其他效果强制要求解放），并且召唤者场上存在空闲的主要怪兽区域。
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 筛选条件：要召唤的怪兽必须是5星以上且属于「玄化」字段，只有满足这些条件的手牌怪兽才能使用无解放召唤。
function c20720928.nttg(e,c)
	return c:IsLevelAbove(5) and c:IsSetCard(0x105)
end
-- 无解放召唤成功实际处理：先给怪兽打上使用玄化因子效果召唤的标记，再向当前玩家场上注册一个持续效果，该效果监听结束阶段，并在下个回合结束阶段（Duel.GetTurnCount()+1）将这只怪兽除外。
function c20720928.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	c:RegisterFlagEffect(20720928,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(20720928,1))  --"使用「玄化因子」效果召唤"
	-- 这个效果适用召唤的怪兽在下个回合的结束阶段除外。②：只要这张卡在场地区域存在，对方不能对应自己的「玄化」怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 将除外效果的触发时机设定为当前回合数+1，即下个回合的结束阶段。
	e2:SetLabel(Duel.GetTurnCount()+1)
	e2:SetLabelObject(c)
	e2:SetCondition(c20720928.rmcon)
	e2:SetOperation(c20720928.rmop)
	e2:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将这个持续效果注册到当前玩家 tp 的场上，使其作为全场效果在结束阶段统一检测并执行除外。
	Duel.RegisterEffect(e2,tp)
end
-- 除外效果的触发条件：先取出被标记的怪兽，若它仍带着‘使用玄化因子效果召唤’的标识，则检查当前回合数是否已到达设定的下个回合结束阶段；若标识已因离场等原因丢失，则重置该效果并取消本次除外。
function c20720928.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(20720928)~=0 then
		-- 判定当前回合数是否等于预设的下个回合数（即是否已到下个回合的结束阶段）。
		return Duel.GetTurnCount()==e:GetLabel()
	else
		e:Reset()
		return false
	end
end
-- 除外操作：取出被标记的怪兽，并将其作为效果对象进行表侧表示除外。
function c20720928.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将被标记的怪兽以表侧表示形式除外，理由为效果（REASON_EFFECT）。
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
-- 连锁发生时，若本次发动的效果对应的卡片是「玄化」怪兽且该效果是怪兽效果，同时发动玩家是自己（ep==tp），则设置连锁限制，封锁对方后续连锁。
function c20720928.chainop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsSetCard(0x105) and re:IsActiveType(TYPE_MONSTER) and ep==tp then
		-- 设置连锁限制条件，使本次连锁必须经过 chainlm 函数判断后才能继续发动效果。
		Duel.SetChainLimit(c20720928.chainlm)
	end
end
-- 连锁限制函数：仅允许原效果发动者（tp）进行连锁，其他玩家（rp）不能连锁，从而体现‘对方不能对应发动’的效果。
function c20720928.chainlm(e,rp,tp)
	return tp==rp
end
