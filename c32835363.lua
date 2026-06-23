--クラッキング
-- 效果：
-- 场上存在的怪兽被卡的效果送去墓地时，给与那些怪兽的原本持有者800分伤害。这个效果1回合只能使用1次。
function c32835363.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 场上存在的怪兽被卡的效果送去墓地时，给与那些怪兽的原本持有者800分伤害。这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c32835363.regcon)
	e2:SetOperation(c32835363.regop)
	c:RegisterEffect(e2)
	-- 场上存在的怪兽被卡的效果送去墓地时，给与那些怪兽的原本持有者800分伤害。这个效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32835363,0))  --"伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_CUSTOM+32835363)
	e3:SetTarget(c32835363.damtg)
	e3:SetOperation(c32835363.damop)
	c:RegisterEffect(e3)
end
-- 检测是否有怪兽因效果被送入墓地且位于场上，若存在则标记对应玩家是否受到影响
function c32835363.regcon(e,tp,eg,ep,ev,re,r,rp)
	local d1=false
	local d2=false
	local tc=eg:GetFirst()
	while tc do
		if tc:IsPreviousLocation(LOCATION_MZONE) and tc:IsType(TYPE_MONSTER) and tc:IsReason(REASON_EFFECT) then
			if tc:GetControler()==0 then d1=true
			else d2=true end
		end
		tc=eg:GetNext()
	end
	local evt_p=PLAYER_NONE
	if d1 and d2 then evt_p=PLAYER_ALL
	elseif d1 then evt_p=0
	elseif d2 then evt_p=1 end
	e:SetLabel(evt_p)
	return evt_p~=PLAYER_NONE
end
-- 触发自定义时点EVENT_CUSTOM+32835363，用于发动伤害效果
function c32835363.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 触发自定义时点EVENT_CUSTOM+32835363，用于发动伤害效果
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+32835363,e,0,tp,e:GetLabel(),0)
end
-- 设置伤害效果的目标参数为800，并注册伤害操作信息
function c32835363.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将伤害值设置为800
	Duel.SetTargetParam(800)
	-- 注册伤害操作信息，指定伤害目标和伤害值
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,ep,800)
end
-- 根据伤害对象是否为双方，分别对两名玩家造成伤害
function c32835363.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的伤害值
	local d=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if ep==PLAYER_ALL then
		-- 对当前玩家造成指定伤害，并触发伤害时点
		Duel.Damage(tp,d,REASON_EFFECT,true)
		-- 对对方玩家造成指定伤害，并触发伤害时点
		Duel.Damage(1-tp,d,REASON_EFFECT,true)
		-- 完成伤害时点的处理
		Duel.RDComplete()
	else
		-- 对指定玩家造成伤害
		Duel.Damage(ep,d,REASON_EFFECT)
	end
end
