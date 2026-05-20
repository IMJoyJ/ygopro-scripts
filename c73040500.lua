--魔轟神ウルストス
-- 效果：
-- 自己手卡是2张以下的场合，自己场上表侧表示存在的名字带有「魔轰神」的怪兽的攻击力上升400。
function c73040500.initial_effect(c)
	-- 自己手卡是2张以下的场合，自己场上表侧表示存在的名字带有「魔轰神」的怪兽的攻击力上升400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(c73040500.con)
	e1:SetTarget(c73040500.tg)
	e1:SetValue(400)
	c:RegisterEffect(e1)
end
-- 定义效果适用的条件函数，判断自己手卡数量是否在2张以下
function c73040500.con(e)
	-- 获取自身控制者的手牌数量，并判断是否小于或等于2
	return Duel.GetFieldGroupCount(e:GetHandler():GetControler(),LOCATION_HAND,0)<=2
end
-- 定义受影响卡片的过滤函数，筛选表侧表示且卡名含有「魔轰神」的怪兽
function c73040500.tg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x35)
end
