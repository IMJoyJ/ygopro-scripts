--インスペクト・ボーダー
-- 效果：
-- 自己场上有怪兽存在的场合，这张卡不能召唤·特殊召唤。
-- ①：只要这张卡在怪兽区域存在，那个期间双方各自在1回合可以发动的怪兽的效果次数变成最多到场上的怪兽的种类（仪式·融合·同调·超量·灵摆·连接）数量次数为止。
function c15397015.initial_effect(c)
	-- 自己场上有怪兽存在的场合，这张卡不能召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c15397015.sumcon)
	c:RegisterEffect(e1)
	-- 自己场上有怪兽存在的场合，这张卡不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(c15397015.sumlimit)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在怪兽区域存在，那个期间双方各自在1回合可以发动的怪兽的效果次数
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(c15397015.counterop)
	c:RegisterEffect(e3)
	-- 变成最多到场上的怪兽的种类（仪式·融合·同调·超量·灵摆·连接）数量次数为止。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(1,1)
	e4:SetValue(c15397015.elimit)
	c:RegisterEffect(e4)
end
-- 作为召唤限制效果的条件：当这张卡的控制者场上有怪兽存在时，该卡不能进行通常召唤。
function c15397015.sumcon(e)
	-- 判断控制者场上怪兽区是否有怪兽（数量>0），若有则使召唤限制效果生效。
	return Duel.GetFieldGroupCount(e:GetHandler():GetControler(),LOCATION_MZONE,0)>0
end
-- 作为特殊召唤限制效果：检查尝试特殊召唤的玩家（sp）的怪兽区是否有怪兽，若没有怪兽才允许这张卡特殊召唤。
function c15397015.sumlimit(e,se,sp,st,pos,tp)
	-- 检查尝试特殊召唤的玩家（sp）场上怪兽区数量是否为0，若是则返回 true 表示允许特殊召唤。
	return Duel.GetFieldGroupCount(sp,LOCATION_MZONE,0)==0
end
-- 记录本回合双方发动怪兽效果的次数：每当怪兽效果发动时，为冲浪检察官注册一个以发动玩家区分的标记；标记在回合结束重置，用于后续限制效果判断。
function c15397015.counterop(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsActiveType(TYPE_MONSTER) then return end
	e:GetHandler():RegisterFlagEffect(15397015+ep,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 过滤器：判断一张卡是否表侧表示且属于指定的额外怪兽种类（如融合、同调等），用于统计场上存在的怪兽种类数。
function c15397015.cfilter(c,type)
	return c:IsFaceup() and c:IsType(type)
end
-- 限制怪兽效果发动：计算场上表侧表示怪兽包含的额外种类数量，若某玩家本回合已发动的怪兽效果次数达到或超过该数量，则禁止该玩家再发动怪兽效果（返回 true 表示不能发动）。
function c15397015.elimit(e,re,tp)
	if not re:IsActiveType(TYPE_MONSTER) then return false end
	local ct=0
	for i,type in ipairs({TYPE_FUSION,TYPE_RITUAL,TYPE_SYNCHRO,TYPE_XYZ,TYPE_PENDULUM,TYPE_LINK}) do
		-- 检查场上是否存在至少1只表侧表示且属于当前遍历的种类 type 的怪兽；若存在，则将种类计数 ct 加 1，用于累加场上的怪兽种类数。
		if Duel.IsExistingMatchingCard(c15397015.cfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil,type) then
			ct=ct+1
		end
	end
	return e:GetHandler():GetFlagEffect(15397015+tp)>=ct
end
