--奇跡のピラミッド
-- 效果：
-- 自己场上表侧表示存在的不死族怪兽的攻击力上升对方场上存在的怪兽数量×200的数值。自己场上表侧表示存在的不死族怪兽1只被破坏的场合，可以作为代替把这张卡送去墓地。
function c66835946.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上表侧表示存在的不死族怪兽的攻击力上升对方场上存在的怪兽数量×200的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的对象为自己场上表侧表示存在的不死族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ZOMBIE))
	e2:SetValue(c66835946.val)
	c:RegisterEffect(e2)
	-- 自己场上表侧表示存在的不死族怪兽1只被破坏的场合，可以作为代替把这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c66835946.destg)
	e3:SetValue(1)
	e3:SetOperation(c66835946.desop)
	c:RegisterEffect(e3)
end
-- 计算攻击力上升数值的函数，返回对方场上怪兽数量×200的数值
function c66835946.val(e,c)
	-- 获取对方怪兽区域的卡片数量并乘以200作为攻击力上升的数值
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)*200
end
-- 代替破坏效果的条件判断与询问函数，验证被破坏的怪兽是否满足代替条件，并询问玩家是否发动代替效果
function c66835946.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local tc=eg:GetFirst()
		return eg:GetCount()==1 and tc:IsLocation(LOCATION_MZONE) and tc:IsControler(tp) and tc:IsFaceup() and tc:IsRace(RACE_ZOMBIE)
			and not tc:IsReason(REASON_REPLACE)
	end
	-- 询问玩家是否选择发动该卡代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏效果的执行函数，将此卡送去墓地
function c66835946.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡（奇迹之金字塔）因效果送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
