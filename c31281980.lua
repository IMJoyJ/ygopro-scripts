--ヒール・ウェーバー
-- 效果：
-- 选择这张卡以外的自己场上表侧表示存在的1只怪兽发动。回复选择怪兽的等级×100的数值的基本分。这个效果1回合只能使用1次。
function c31281980.initial_effect(c)
	-- 选择这张卡以外的自己场上表侧表示存在的1只怪兽发动。回复选择怪兽的等级×100的数值的基本分。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31281980,0))  --"LP回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c31281980.rectg)
	e1:SetOperation(c31281980.recop)
	c:RegisterEffect(e1)
end
-- 定义选择对象的过滤条件：必须是自己场上表侧表示且等级大于0的怪兽。
function c31281980.filter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 效果发动时的目标处理：验证对象合法性、判断是否存在可选择的怪兽，然后让玩家选择1只表侧表示且等级>0的自己场上怪兽作为对象，并设定回复LP的信息。
function c31281980.rectg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c31281980.filter(chkc) end
	-- 发动条件判定：检查自己场上是否存在1只满足过滤条件且除效果处理者自身以外的表侧表示怪兽可作为对象，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c31281980.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向玩家发送选择提示信息，提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只满足过滤条件的表侧表示怪兽作为效果对象（不能选择效果处理者自身），并注册为效果对象。
	local g=Duel.SelectTarget(tp,c31281980.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置操作信息：本次效果处理将回复基本分，数值为目标怪兽等级×100。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetLevel()*100)
end
-- 效果处理：取得选择的目标怪兽，若目标仍表侧表示且与效果相关，则回复基本分。
function c31281980.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使玩家回复目标怪兽等级×100的基本分。
		Duel.Recover(tp,tc:GetLevel()*100,REASON_EFFECT)
	end
end
