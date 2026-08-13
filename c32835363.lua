--クラッキング
-- 效果：
-- 场上存在的怪兽被卡的效果送去墓地时，给与那些怪兽的原本持有者800分伤害。这个效果1回合只能使用1次。
function c32835363.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 场上存在的怪兽被卡的效果送去墓地时，这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c32835363.regcon)
	e2:SetOperation(c32835363.regop)
	c:RegisterEffect(e2)
	-- 给与那些怪兽的原本持有者800分伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32835363,0))  --"伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_CUSTOM+32835363)
	e3:SetTarget(c32835363.damtg)
	e3:SetOperation(c32835363.damop)
	c:RegisterEffect(e3)
end
-- 遍历这次送去墓地的卡，筛选出从怪兽区域被卡的效果送去墓地的怪兽，并按控制者分别记录是否存在，用于后续判断伤害对象。
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
-- 当条件满足时，以本卡为触发卡，向之前记录到的玩家引发一个自定义时点事件，用于触发后续的伤害效果。
function c32835363.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 以本卡作为触发卡，引发EVENT_CUSTOM+32835363自定义事件，效果来源为e，玩家参数为记录到的伤害对象，从而启动伤害效果的连锁。
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+32835363,e,0,tp,e:GetLabel(),0)
end
-- 伤害效果的发动时点处理：必发效果，无发动条件限制，设置伤害数值为800，并设置操作信息，宣告给对应玩家造成800效果伤害。
function c32835363.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的处理参数设置为800，即实际造成的伤害数值。
	Duel.SetTargetParam(800)
	-- 设置本次效果的操作信息为伤害效果，目标玩家为ep，伤害值为800，供其他卡牌效果（如星尘龙等）进行响应检测。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,ep,800)
end
-- 伤害处理：根据连锁记录的目标玩家造成伤害；若目标为双方，则分别给双方造成800伤害，并完成伤害时点处理；否则只给目标玩家造成伤害。
function c32835363.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设置的处理参数，即之前保存的伤害数值800。
	local d=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if ep==PLAYER_ALL then
		-- 以效果伤害方式给当前操作玩家tp造成800点伤害，并标记为分解伤害/回复过程，以便中间触发其他时点。
		Duel.Damage(tp,d,REASON_EFFECT,true)
		-- 以效果伤害方式给另一方玩家（1-tp）造成800点伤害，同样标记为分解过程。
		Duel.Damage(1-tp,d,REASON_EFFECT,true)
		-- 完成本次伤害/回复过程的时点处理，触发相关卡片的诱发效果。
		Duel.RDComplete()
	else
		-- 给指定玩家ep造成800点效果伤害（不分解，一次性处理）。
		Duel.Damage(ep,d,REASON_EFFECT)
	end
end
