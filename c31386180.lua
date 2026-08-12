--始祖の守護者ティラス
-- 效果：
-- 5星怪兽×2
-- 这张卡的效果只在这张卡持有超量素材的场合适用。
-- ①：场上的这张卡不会被效果破坏。
-- ②：这张卡进行战斗的战斗阶段结束时，以对方场上1张卡为对象发动。那张对方的卡破坏。
-- ③：自己结束阶段发动。这张卡1个超量素材取除。
function c31386180.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为5的怪兽2只以上作为素材
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- 场上的这张卡不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetCondition(c31386180.condition)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这张卡进行战斗的战斗阶段结束时，以对方场上1张卡为对象发动。那张对方的卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31386180,0))  --"选择对方场上存在的1张卡破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c31386180.decon)
	e2:SetTarget(c31386180.destg)
	e2:SetOperation(c31386180.desop)
	c:RegisterEffect(e2)
	-- 自己结束阶段发动。这张卡1个超量素材取除。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31386180,1))  --"取除1个超量素材"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c31386180.rmcon)
	e3:SetOperation(c31386180.rmop)
	c:RegisterEffect(e3)
end
-- 效果适用条件：此卡持有超量素材
function c31386180.condition(e)
	return e:GetHandler():GetOverlayCount()>0
end
-- 效果适用条件：此卡参与过战斗
function c31386180.decon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 选择对方场上1张卡作为破坏对象
function c31386180.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	if chk==0 then return true end
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为目标
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果，将目标卡破坏
function c31386180.desop(e,tp,eg,ep,ev,re,r,rp)
	if not c31386180.condition(e) then return end
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果适用条件：当前为自己的回合
function c31386180.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 执行取除1个超量素材的效果
function c31386180.rmop(e,tp,eg,ep,ev,re,r,rp)
	if not c31386180.condition(e) then return end
	local c=e:GetHandler()
	c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end
