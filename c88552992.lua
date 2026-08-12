--先史遺産ゴールデン・シャトル
-- 效果：
-- 1回合1次，自己的主要阶段时才能发动。自己场上的全部名字带有「先史遗产」的怪兽的等级上升1星。
function c88552992.initial_effect(c)
	-- 1回合1次，自己的主要阶段时才能发动。自己场上的全部名字带有「先史遗产」的怪兽的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88552992,0))  --"等级上升"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c88552992.lvtg)
	e1:SetOperation(c88552992.lvop)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示、等级在1以上且卡名含有「先史遗产」的怪兽
function c88552992.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsSetCard(0x70)
end
-- 效果发动的目标检查函数
function c88552992.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c88552992.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理函数：使自己场上所有满足条件的「先史遗产」怪兽等级上升1星
function c88552992.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有满足过滤条件的「先史遗产」怪兽
	local g=Duel.GetMatchingGroup(c88552992.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 等级上升1星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
