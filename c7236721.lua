--界放せし肆世壊
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己场上的「恐吓爪牙族」连接怪兽以及「维萨斯-斯塔弗罗斯特」不会成为对方的效果的对象，不会被对方的效果破坏。
-- ②：自己的「恐吓爪牙族」连接怪兽或者「维萨斯-斯塔弗罗斯特」战斗破坏的怪兽不去墓地而除外。
-- ③：从自己的场上·墓地把1只「恐吓爪牙族」连接怪兽除外，以对方场上1张卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 注册卡片记有「维萨斯-斯塔弗罗斯特」的卡片密码
	aux.AddCodeList(c,56099748)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己场上的「恐吓爪牙族」连接怪兽以及「维萨斯-斯塔弗罗斯特」不会成为对方的效果的对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.immtg)
	-- 设置不能成为对象的效果仅对对方的效果有效
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置不会被破坏的效果仅对对方的效果有效
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ②：自己的「恐吓爪牙族」连接怪兽或者「维萨斯-斯塔弗罗斯特」战斗破坏的怪兽不去墓地而除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e3:SetValue(LOCATION_REMOVED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.immtg)
	c:RegisterEffect(e3)
	-- ③：从自己的场上·墓地把1只「恐吓爪牙族」连接怪兽除外，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCountLimit(1,id)
	e5:SetCost(s.descost)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end
-- 过滤自己场上表侧表示的「维萨斯-斯塔弗罗斯特」以及「恐吓爪牙族」连接怪兽
function s.immtg(e,c)
	return c:IsFaceup() and (c:IsCode(56099748) or (c:IsType(TYPE_LINK) and c:IsSetCard(0x17a)))
end
-- 过滤自己场上或墓地可以作为Cost除外的「恐吓爪牙族」连接怪兽
function s.cfilter(c)
	return c:IsType(TYPE_LINK) and c:IsSetCard(0x17a)
		and c:IsAbleToRemoveAsCost()
end
-- 效果③的Cost处理函数：从自己的场上·墓地把1只「恐吓爪牙族」连接怪兽除外
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上或墓地是否存在至少1只满足条件的「恐吓爪牙族」连接怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己场上或墓地1只满足条件的「恐吓爪牙族」连接怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果③的Target处理函数：以对方场上1张卡为对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少1张卡可以作为效果对象
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果③的Operation处理函数：将作为对象的卡破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
