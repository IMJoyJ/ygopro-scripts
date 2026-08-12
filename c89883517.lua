--濡れ衣
-- 效果：
-- 「冤枉」在1回合只能发动1张。
-- ①：对方的手卡·场上的卡合计数量比自己的手卡·场上的卡合计数量多的场合，以场上1张表侧表示的卡为对象才能发动。双方玩家在这次决斗中不能把那张表侧表示的卡以外的和作为对象的卡同名卡的效果发动。
function c89883517.initial_effect(c)
	-- 「冤枉」在1回合只能发动1张。①：对方的手卡·场上的卡合计数量比自己的手卡·场上的卡合计数量多的场合，以场上1张表侧表示的卡为对象才能发动。双方玩家在这次决斗中不能把那张表侧表示的卡以外的和作为对象的卡同名卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,89883517+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c89883517.condition)
	e1:SetTarget(c89883517.target)
	e1:SetOperation(c89883517.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件：对方的手卡·场上的卡合计数量比自己的手卡·场上的卡合计数量多
function c89883517.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己手卡和场上的卡片合计数量
	local ct1=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD+LOCATION_HAND,0)
	-- 获取对方手卡和场上的卡片合计数量
	local ct2=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD+LOCATION_HAND)
	return ct1<ct2
end
-- 进行发动时的对象选择处理
function c89883517.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 检查场上是否存在除这张卡以外的表侧表示的卡可以作为对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1张表侧表示的卡作为对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
end
-- 效果处理：注册限制双方玩家发动同名卡效果的决斗永续效果
function c89883517.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 双方玩家在这次决斗中不能把那张表侧表示的卡以外的和作为对象的卡同名卡的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c89883517.aclimit)
	e1:SetLabel(tc:GetCode())
	-- 向全局环境注册限制效果发动的效果
	Duel.RegisterEffect(e1,tp)
	-- 双方玩家在这次决斗中不能把那张表侧表示的卡以外的和作为对象的卡同名卡的效果发动。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetLabel(tc:GetFieldID())
	-- 向全局环境注册用于记录对象卡片场上ID的效果
	Duel.RegisterEffect(e2,tp)
	e1:SetLabelObject(e2)
end
-- 限制发动效果的过滤条件：同名卡且不是作为对象的那张卡本身
function c89883517.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return rc:IsCode(e:GetLabel()) and (not rc:IsOnField() or rc:GetFieldID()~=e:GetLabelObject():GetLabel())
end
