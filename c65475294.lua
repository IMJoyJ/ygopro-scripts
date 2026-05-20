--味方殺しの女騎士
-- 效果：
-- 每次自己的准备阶段，如果不用这张卡以外的1只怪兽做祭品维持，这张卡破坏。
function c65475294.initial_effect(c)
	-- 每次自己的准备阶段，如果不用这张卡以外的1只怪兽做祭品维持，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c65475294.costcon)
	e1:SetOperation(c65475294.costop)
	c:RegisterEffect(e1)
end
-- 维持代价效果的条件判断函数
function c65475294.costcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 维持代价效果的处理函数
function c65475294.costop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否存在除自身以外的可解放怪兽，并询问玩家是否选择支付维持代价
	if Duel.CheckReleaseGroupEx(tp,nil,1,REASON_MAINTENANCE,false,c) and Duel.SelectEffectYesNo(tp,c,aux.Stringid(65475294,0)) then  --"是否要解放一只怪兽维持「杀戮同伴的女骑士」？"
		-- 选择1只除自身以外的可解放怪兽
		local g=Duel.SelectReleaseGroupEx(tp,nil,1,1,REASON_MAINTENANCE,false,c)
		-- 解放选中的怪兽作为维持代价
		Duel.Release(g,REASON_MAINTENANCE)
	else
		-- 因无法支付维持代价而将这张卡破坏
		Duel.Destroy(c,REASON_COST)
	end
end
