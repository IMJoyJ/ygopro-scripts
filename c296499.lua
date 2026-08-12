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
-- 选择并记录宣言的种族
function c296499.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择种族
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让玩家从所有种族中选择一个种族
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL)
	e:SetLabel(rc)
	e:GetHandler():SetHint(CHINT_RACE,rc)
end
-- 判断目标怪兽是否为宣言的种族
function c296499.atktarget(e,c)
	return c:IsRace(e:GetLabelObject():GetLabel())
end
-- 判断是否为自己的准备阶段
function c296499.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段处理函数，检查是否需要解放怪兽维持效果
function c296499.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有可解放的怪兽并询问玩家是否选择解放
	if Duel.CheckReleaseGroupEx(tp,nil,1,REASON_MAINTENANCE,false,nil) and Duel.SelectYesNo(tp,aux.Stringid(296499,0)) then  --"是否要解放一只怪兽维持「一族之规」？"
		-- 选择1只怪兽进行解放
		local g=Duel.SelectReleaseGroupEx(tp,nil,1,1,REASON_MAINTENANCE,false,nil)
		-- 解放选中的怪兽
		Duel.Release(g,REASON_MAINTENANCE)
	else
		-- 若未选择解放则破坏此卡
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
