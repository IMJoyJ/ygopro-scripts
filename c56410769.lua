--波紋鳥
-- 效果：
-- 1星怪兽×2
-- ①：只要自己场上的怪兽全部是攻击表示，那些怪兽的攻击力上升500。
-- ②：只要自己场上的怪兽全部是守备表示，对方不能攻击宣言。
-- ③：把这张卡1个超量素材取除，以场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
local s,id,o=GetID()
-- 注册卡片效果
function s.initial_effect(c)
	-- 添加超量召唤手续：1星怪兽×2
	aux.AddXyzProcedure(c,nil,1,2)
	c:EnableReviveLimit()
	-- ③：把这张卡1个超量素材取除，以场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"表示形式变更"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(s.poscost)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	-- ①：只要自己场上的怪兽全部是攻击表示，那些怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的对象为表侧攻击表示怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsPosition,POS_FACEUP_ATTACK))
	e2:SetValue(500)
	e2:SetCondition(s.atkcon)
	c:RegisterEffect(e2)
	-- ②：只要自己场上的怪兽全部是守备表示，对方不能攻击宣言。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.cacon)
	c:RegisterEffect(e3)
end
-- 表示形式变更效果的代价：取除这张卡的1个超量素材
function s.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：可以改变表示形式的怪兽
function s.posfilter(c)
	return c:IsCanChangePosition()
end
-- 表示形式变更效果的目标选择
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) end
	-- 检查场上是否存在可以改变表示形式的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择场上1只可以改变表示形式的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 表示形式变更效果的实际处理
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		-- 改变目标怪兽的表示形式（表侧守备表示与表侧攻击表示互相转换）
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- 攻击力上升效果的适用条件：自己场上的怪兽全部是攻击表示
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧攻击表示怪兽
	return Duel.IsExistingMatchingCard(Card.IsPosition,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,POS_FACEUP_ATTACK)
		-- 检查自己场上不存在守备表示怪兽
		and not Duel.IsExistingMatchingCard(Card.IsPosition,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,POS_DEFENSE)
end
-- 不能攻击宣言效果的适用条件：自己场上的怪兽全部是守备表示
function s.cacon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只守备表示怪兽
	return Duel.IsExistingMatchingCard(Card.IsPosition,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,POS_DEFENSE)
		-- 检查自己场上不存在攻击表示怪兽
		and not Duel.IsExistingMatchingCard(Card.IsPosition,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,POS_ATTACK)
end
