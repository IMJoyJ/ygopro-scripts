--グリード
-- 效果：
-- 因卡的效果进行抽卡的玩家，在那个回合的结束阶段终了时受到因卡的效果抽的卡的数量×500的伤害。
function c89405199.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 因卡的效果进行抽卡的玩家
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DRAW)
	e2:SetCondition(c89405199.drcon)
	e2:SetOperation(c89405199.drop)
	c:RegisterEffect(e2)
	-- 在那个回合的结束阶段终了时受到因卡的效果抽的卡的数量×500的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(89405199,0))  --"伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(c89405199.damcon)
	e3:SetTarget(c89405199.damtg)
	e3:SetOperation(c89405199.damop)
	c:RegisterEffect(e3)
end
-- 过滤抽卡事件，仅在抽卡原因为卡的效果时满足条件
function c89405199.drcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 在自身卡片上注册或更新标记，记录因卡的效果抽卡的玩家以及累计抽卡张数，该标记在回合结束时重置
function c89405199.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local flag=(ep==0 and 89405199 or 89405200)
	local ct=c:GetFlagEffectLabel(flag)
	if ct then
		c:SetFlagEffectLabel(flag,ct+ev)
	else
		c:RegisterFlagEffect(flag,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,ev)
	end
end
-- 检查本回合是否有任意玩家因卡的效果抽过卡
function c89405199.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(89405199)>0 or c:GetFlagEffect(89405200)>0
end
-- 伤害效果的发动准备，获取双方玩家因效果抽卡的数量，并向系统宣告将要造成伤害的操作信息
function c89405199.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local ct1=c:GetFlagEffectLabel(89405199)
	local ct2=c:GetFlagEffectLabel(89405200)
	if ct1 and ct2 then
		-- 宣告操作信息：双方玩家都将受到伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
	elseif ct1 then
		-- 宣告操作信息：玩家0将受到 抽卡张数×500 的伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,0,ct1*500)
	elseif ct2 then
		-- 宣告操作信息：玩家1将受到 抽卡张数×500 的伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1,ct2*500)
	end
end
-- 伤害效果的实际处理，获取双方玩家因效果抽卡的数量，分别给予对应的伤害，并完成伤害时点
function c89405199.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct1=c:GetFlagEffectLabel(89405199+tp)
	local ct2=c:GetFlagEffectLabel(89405199+1-tp)
	-- 若当前玩家有因效果抽卡的记录，则对其造成 抽卡张数×500 的效果伤害（分步处理）
	if ct1 then Duel.Damage(tp,ct1*500,REASON_EFFECT,true) end
	-- 若对手玩家有因效果抽卡的记录，则对其造成 抽卡张数×500 的效果伤害（分步处理）
	if ct2 then Duel.Damage(1-tp,ct2*500,REASON_EFFECT,true) end
	-- 触发并完成分步造成的伤害时点
	Duel.RDComplete()
end
