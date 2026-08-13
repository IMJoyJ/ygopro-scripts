--一族の掟
-- 效果：
-- 发动时宣言1个种族。那个种族的怪兽不能攻击宣言。每次自己的准备阶段若不把1只怪兽作为祭品这张卡破坏。
function c296499.initial_effect(c)
	-- 发动时宣言1个种族。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c296499.target)
	c:RegisterEffect(e1)
	-- 那个种族的怪兽不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c296499.atktarget)
	c:RegisterEffect(e2)
	e2:SetLabelObject(e1)
	-- 每次自己的准备阶段若不把1只怪兽作为祭品这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c296499.mtcon)
	e3:SetOperation(c296499.mtop)
	c:RegisterEffect(e3)
end
-- 发动时的效果处理：在发动时让玩家宣言1个种族，并将宣言的种族记录在效果对象上，同时为卡片设置种族提示。
function c296499.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向玩家tp发送种族选择提示，提示内容为“请选择要宣言的种族”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让玩家tp从全部种族中宣言1个种族，返回值rc为所宣言的种族。
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL)
	e:SetLabel(rc)
	e:GetHandler():SetHint(CHINT_RACE,rc)
end
-- 判定怪兽c是否为发动时宣言的种族，若是则受不能攻击的效果影响。
function c296499.atktarget(e,c)
	return c:IsRace(e:GetLabelObject():GetLabel())
end
-- 维持代价的触发条件：仅在自己的准备阶段才进行维持代价处理。
function c296499.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己（tp），即只有自己的准备阶段才满足条件。
	return Duel.GetTurnPlayer()==tp
end
-- 维持代价的处理：若存在可解放的怪兽且玩家选择是，则解放1只怪兽；否则破坏这张卡。
function c296499.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上·手卡是否存在至少1只可解放的怪兽，并询问玩家是否解放1只怪兽作为维持代价；两项均满足才进入支付代价分支。
	if Duel.CheckReleaseGroupEx(tp,nil,1,REASON_MAINTENANCE,false,nil) and Duel.SelectYesNo(tp,aux.Stringid(296499,0)) then  --"是否要解放一只怪兽维持「一族之规」？"
		-- 从自己场上·手卡选择1只可解放的怪兽作为维持代价。
		local g=Duel.SelectReleaseGroupEx(tp,nil,1,1,REASON_MAINTENANCE,false,nil)
		-- 将选择的怪兽解放，作为这张卡的维持代价。
		Duel.Release(g,REASON_MAINTENANCE)
	else
		-- 若玩家不支付维持代价，则这张卡因无法支付维持代价而破坏。
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
