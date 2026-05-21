--地盤沈下
-- 效果：
-- 指定没有使用的主要怪兽区域2处才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，指定的区域不能使用。
function c90502999.initial_effect(c)
	-- 指定没有使用的主要怪兽区域2处才能把这张卡发动。①：只要这张卡在魔法与陷阱区域存在，指定的区域不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c90502999.target)
	e1:SetOperation(c90502999.operation)
	c:RegisterEffect(e1)
end
-- 检查双方场上未使用的主要怪兽区域总数是否至少有2个
function c90502999.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上未使用的主要怪兽区域数量
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)
		-- 加上对方场上未使用的主要怪兽区域数量，判断总数是否大于1（即至少有2个空位）
		+Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)>1 end
	-- 让玩家选择双方主要怪兽区域中2个未使用的格子
	local dis=Duel.SelectDisableField(tp,2,LOCATION_MZONE,LOCATION_MZONE,0xe000e0)
	e:SetLabel(dis)
	-- 在界面上高亮显示被选择的区域
	Duel.Hint(HINT_ZONE,tp,dis)
end
-- 效果处理：获取选择的区域，若为后攻玩家则转换区域坐标，并注册使该区域不能使用的永续效果
function c90502999.operation(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetLabel()
	if tp==1 then
		zone=((zone&0xffff)<<16)|((zone>>16)&0xffff)
	end
	local c=e:GetHandler()
	-- ①：只要这张卡在魔法与陷阱区域存在，指定的区域不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_DISABLE_FIELD)
	e2:SetValue(zone)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
