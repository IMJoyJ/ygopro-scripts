--氷結界に住む魔酔虫
-- 效果：
-- ①：这张卡召唤的场合，指定没有使用的主要怪兽区域1处发动。这张卡得到以下效果。
-- ●只要这张卡在怪兽区域存在，指定的区域不能使用。
function c92065772.initial_effect(c)
	-- ①：这张卡召唤的场合，指定没有使用的主要怪兽区域1处发动。这张卡得到以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92065772,0))  --"怪兽区1处不能使用"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c92065772.target)
	e1:SetOperation(c92065772.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时的处理，初始化区域标记，并确认双方场上是否存在可用的主要怪兽区域
function c92065772.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetLabel(0)
	-- 检查自己场上是否有可用的主要怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)<=0
		-- 检查对方场上是否有可用的主要怪兽区域，若双方都没有可用区域则结束效果处理
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
	-- 让发动效果的玩家选择1个双方场上未使用的主要怪兽区域
	local dis1=Duel.SelectDisableField(tp,1,LOCATION_MZONE,LOCATION_MZONE,0xe000e0)
	e:SetLabel(dis1)
end
-- 效果处理，获取选中的区域标记，并在后攻玩家发动时进行区域标记的位移转换，最后使这张卡得到不能使用该区域的效果
function c92065772.operation(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetLabel()
	if tp==1 then
		zone=((zone&0xffff)<<16)|((zone>>16)&0xffff)
	end
	local c=e:GetHandler()
	-- ●只要这张卡在怪兽区域存在，指定的区域不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_DISABLE_FIELD)
	e2:SetValue(zone)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
