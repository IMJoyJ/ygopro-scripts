--ダイナレスラー・カパプテラ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合，以对方场上1只怪兽为对象才能发动。那只怪兽送去墓地。
-- ②：这张卡作为「恐龙摔跤手」连接怪兽的连接素材送去墓地的场合才能发动。那只连接怪兽的攻击力直到回合结束时上升1000。
function c93507434.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：对方场上的怪兽数量比自己场上的怪兽多的场合，以对方场上1只怪兽为对象才能发动。那只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93507434,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,93507434)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c93507434.tgcon)
	e1:SetTarget(c93507434.tgtg)
	e1:SetOperation(c93507434.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡作为「恐龙摔跤手」连接怪兽的连接素材送去墓地的场合才能发动。那只连接怪兽的攻击力直到回合结束时上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93507434,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(c93507434.atkcon)
	e2:SetTarget(c93507434.atktg)
	e2:SetOperation(c93507434.atkop)
	c:RegisterEffect(e2)
	-- 建立作为素材的卡片与其对应的素材触发效果之间的关联，以便在效果处理时能正确获取到本次召唤出的连接怪兽
	aux.CreateMaterialReasonCardRelation(c,e2)
end
-- 效果①的发动条件判定函数
function c93507434.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定对方场上的怪兽数量是否比自己场上的怪兽数量多
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
end
-- 效果①的发动准备（判定与选择对象）函数
function c93507434.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 在发动时，判定对方场上是否存在至少1只可以作为对象选择的怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 给发动效果的玩家发送提示信息，提示其选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为：将选中的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果①的处理（送去墓地）函数
function c93507434.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的第一个效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将该对象怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- 效果②的发动条件判定函数：此卡在墓地，且作为「恐龙摔跤手」连接怪兽的连接素材送去墓地
function c93507434.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and c:GetReasonCard():IsSetCard(0x11a)
end
-- 效果②的发动准备函数
function c93507434.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=e:GetHandler():GetReasonCard()
	if chk==0 then return rc:IsRelateToEffect(e) end
	-- 将本次召唤出的连接怪兽设置为当前连锁的效果对象
	Duel.SetTargetCard(rc)
end
-- 效果②的处理（上升攻击力）函数
function c93507434.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的连接怪兽
	local rc=Duel.GetFirstTarget()
	if rc:IsRelateToChain() then
		-- 那只连接怪兽的攻击力直到回合结束时上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		rc:RegisterEffect(e1)
	end
end
