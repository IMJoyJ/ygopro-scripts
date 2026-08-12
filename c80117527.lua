--No.11 ビッグ・アイ
-- 效果：
-- 7星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只怪兽为对象才能发动（这个效果发动的回合，这张卡不能攻击）。得到那只怪兽的控制权。
function c80117527.initial_effect(c)
	-- 添加以2只7星怪兽为素材的超量召唤手续
	aux.AddXyzProcedure(c,nil,7,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只怪兽为对象才能发动（这个效果发动的回合，这张卡不能攻击）。得到那只怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetDescription(aux.Stringid(80117527,0))  --"得到控制权"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c80117527.cost)
	e1:SetTarget(c80117527.target)
	e1:SetOperation(c80117527.operation)
	c:RegisterEffect(e1)
end
-- 设置该卡片的“No.”编号为11
aux.xyz_number[80117527]=11
-- 效果发动代价与条件的判定：检查是否能取除1个超量素材，且本回合这张卡没有进行过攻击宣言
function c80117527.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
		and e:GetHandler():GetAttackAnnouncedCount()==0 end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	-- （这个效果发动的回合，这张卡不能攻击）
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 效果发动的对象选择与信息注册：选择对方场上1只可以改变控制权的怪兽作为对象
function c80117527.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	-- 检查对方场上是否存在至少1只可以改变控制权的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 玩家选择对方场上1只可以改变控制权的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为改变1只怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理的执行：获取对象怪兽并转移其控制权
function c80117527.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 得到目标怪兽的控制权
		Duel.GetControl(tc,tp)
	end
end
