--始祖の守護者ティラス
-- 效果：
-- 5星怪兽×2
-- 这张卡的效果只在这张卡持有超量素材的场合适用。
-- ①：场上的这张卡不会被效果破坏。
-- ②：这张卡进行战斗的战斗阶段结束时，以对方场上1张卡为对象发动。那张对方的卡破坏。
-- ③：自己结束阶段发动。这张卡1个超量素材取除。
function c31386180.initial_effect(c)
	-- 为始祖守护者 提拉斯添加XYZ召唤手续：用任意2只等级5的怪兽叠放来XYZ召唤。
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- 这张卡的效果只在这张卡持有超量素材的场合适用。①：场上的这张卡不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetCondition(c31386180.condition)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：这张卡进行战斗的战斗阶段结束时，以对方场上1张卡为对象发动。那张对方的卡破坏。
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
	-- ③：自己结束阶段发动。这张卡1个超量素材取除。
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
-- 判断这张卡是否持有超量素材：超量素材数量大于0时条件成立，用于限定此卡的效果只在其持有超量素材时适用。
function c31386180.condition(e)
	return e:GetHandler():GetOverlayCount()>0
end
-- 效果②的发动条件：当前处于战斗阶段结束时，且这张卡本回合进行过战斗（与这张卡进行过战斗的卡片数量大于0）才满足。
function c31386180.decon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 效果②的取对象处理：如果处于检查对象合法性阶段，要求对象是对方场上的卡；进入发动时则让玩家从对方场上选择1张卡作为对象，并登记破坏1张卡的操作信息。
function c31386180.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	if chk==0 then return true end
	-- 向当前玩家发送选择提示信息，内容为“请选择要破坏的卡”，用于选择卡片的提示缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让当前玩家从对方场上选择1张卡（不限定卡类型），作为此效果的对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 登记当前连锁的破坏类操作信息：目标为g，数量为g中的卡数，供其他卡在发动/处理时进行效果检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果②的发动处理：先确认这张卡仍持有超量素材；再取对象卡，若对象卡仍与此效果有关且仍在对方场上，则将那张卡破坏。
function c31386180.desop(e,tp,eg,ep,ev,re,r,rp)
	if not c31386180.condition(e) then return end
	-- 获取此效果发动时选择的对象卡（唯一的取对象目标）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- 以效果为原因，将对象卡破坏送入墓地。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果③的发动条件：当前回合玩家是这张卡的控制者/效果发动者，即在自己的结束阶段时满足。
function c31386180.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否等于tp，用于限定是“自己”的结束阶段。
	return Duel.GetTurnPlayer()==tp
end
-- 效果③的发动处理：先确认这张卡仍持有超量素材，然后由这张卡的控制者取除其1个超量素材。
function c31386180.rmop(e,tp,eg,ep,ev,re,r,rp)
	if not c31386180.condition(e) then return end
	local c=e:GetHandler()
	c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end
