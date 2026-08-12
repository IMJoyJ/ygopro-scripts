--力の代行者 マーズ
-- 效果：
-- ①：场上的这张卡不受魔法卡的效果影响。
-- ②：自己场上有「天空的圣域」存在，自己基本分比对方多的场合，这张卡的攻击力·守备力上升那个相差数值。
function c91123920.initial_effect(c)
	-- 在卡片关系中记录该卡提到了「天空的圣域」
	aux.AddCodeList(c,56433456)
	-- ①：场上的这张卡不受魔法卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c91123920.efilter)
	c:RegisterEffect(e1)
	-- ②：自己场上有「天空的圣域」存在，自己基本分比对方多的场合，这张卡的攻击力·守备力上升那个相差数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c91123920.val)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
-- 免疫效果的筛选函数，判断效果是否为魔法卡的效果
function c91123920.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL)
end
-- 计算攻击力·守备力上升数值的函数
function c91123920.val(e,c)
	local tp=c:GetControler()
	-- 若场上不存在「天空的圣域」，则上升数值为0
	if not Duel.IsEnvironment(56433456,tp) then return 0 end
	-- 计算双方玩家的基本分差值
	local v=Duel.GetLP(tp)-Duel.GetLP(1-tp)
	if v>0 then return v else return 0 end
end
