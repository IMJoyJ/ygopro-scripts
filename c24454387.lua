--ズットモザウルス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己场上有其他的恐龙族怪兽存在，对方怪兽不能选择这张卡作为攻击对象。
-- ②：以自己场上1张其他卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 注册两个效果：①不能成为攻击对象的效果和②起动破坏效果
function s.initial_effect(c)
	-- ①：只要自己场上有其他的恐龙族怪兽存在，对方怪兽不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCondition(s.lacon)
	-- 设置效果值为imval1函数，用于判断是否能成为攻击对象
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- ②：以自己场上1张其他卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断是否为表侧表示的恐龙族怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR)
end
-- 条件函数：判断自己场上是否存在其他恐龙族怪兽
function s.lacon(e)
	local c=e:GetHandler()
	-- 检查自己场上是否存在至少1只其他恐龙族怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_MZONE,0,1,c)
end
-- 破坏效果的发动时处理函数，用于选择目标并设置操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc~=c end
	-- 检查是否满足发动条件：场上存在至少1张自己场上的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,0,1,c) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1张自己场上的卡作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,0,1,1,c)
	-- 设置连锁的操作信息，说明将要破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的处理函数，用于执行破坏操作
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 若目标卡仍存在于场上则将其破坏
	if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
