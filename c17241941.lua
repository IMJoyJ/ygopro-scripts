--ダイカミナリ・ジャイクロプス
-- 效果：
-- ←5 【灵摆】 5→
-- ①：1回合1次，以自己场上1只灵摆怪兽和对方场上1只怪兽为对象才能发动。那些怪兽的表示形式变更。
-- 【怪兽效果】
-- 从额外卡组特殊召唤的这张卡被同调召唤使用的场合除外。这个卡名的②③的怪兽效果1回合各能使用1次。
-- ①：这张卡召唤成功的场合才能发动。这张卡的表示形式变更。
-- ②：这张卡的表示形式变更的场合，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。
-- ③：这张卡在灵摆区域被破坏的场合才能发动。选自己的灵摆区域1张卡回到持有者手卡。
function c17241941.initial_effect(c)
	-- 为这张灵摆怪兽卡注册灵摆召唤/灵摆卡发动所需的固有效果，使其能作为灵摆怪兽在灵摆区域发动、进行灵摆召唤等。
	aux.EnablePendulumAttribute(c)
	-- 从额外卡组特殊召唤的这张卡被同调召唤使用的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(LOCATION_REMOVED)
	e1:SetCondition(c17241941.rmcon)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以自己场上1只灵摆怪兽和对方场上1只怪兽为对象才能发动。那些怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17241941,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetTarget(c17241941.postg)
	e2:SetOperation(c17241941.posop)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤成功的场合才能发动。这张卡的表示形式变更。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(17241941,1))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(c17241941.postg2)
	e3:SetOperation(c17241941.posop2)
	c:RegisterEffect(e3)
	-- 这个卡名的②③的怪兽效果1回合各能使用1次。②：这张卡的表示形式变更的场合，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(17241941,2))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_CHANGE_POS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,17241941)
	e4:SetTarget(c17241941.destg)
	e4:SetOperation(c17241941.desop)
	c:RegisterEffect(e4)
	-- 这个卡名的②③的怪兽效果1回合各能使用1次。③：这张卡在灵摆区域被破坏的场合才能发动。选自己的灵摆区域1张卡回到持有者手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(17241941,3))
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCountLimit(1,17241942)
	e5:SetCondition(c17241941.thcon)
	e5:SetTarget(c17241941.thtg)
	e5:SetOperation(c17241941.thop)
	c:RegisterEffect(e5)
end
-- 判断这张卡是否满足“从额外卡组特殊召唤的这张卡被同调召唤使用”的条件：即其召唤位置来自额外卡组，且离场原因包含作为同调召唤素材（REASON_MATERIAL+REASON_SYNCHRO）。
function c17241941.rmcon(e)
	local c=e:GetHandler()
	return c:IsSummonLocation(LOCATION_EXTRA)
		and bit.band(c:GetReason(),REASON_MATERIAL+REASON_SYNCHRO)==REASON_MATERIAL+REASON_SYNCHRO
end
-- 判定对象候选：表侧表示、灵摆怪兽、且可以变更表示形式的怪兽。
function c17241941.posfilter1(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsCanChangePosition()
end
-- 灵摆效果①的发动条件与取对象处理：确认场上存在符合条件的目标（自己场上有1只灵摆怪兽、对方场上有1只可变更表示形式的怪兽），并让玩家选择这两只怪兽作为对象。
function c17241941.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动合法性检查：自己场上是否存在至少1只满足posfilter1条件的灵摆怪兽。
	if chk==0 then return Duel.IsExistingTarget(c17241941.posfilter1,tp,LOCATION_MZONE,0,1,nil)
		-- 发动合法性检查：对方怪兽区域是否存在至少1只可以变更表示形式的怪兽。
		and Duel.IsExistingTarget(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出“请选择要改变表示形式的怪兽”的选择提示框，提示当前玩家选择我方灵摆怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让当前玩家从自己场上选择1只满足条件的灵摆怪兽，并将其登记为效果对象。
	local g1=Duel.SelectTarget(tp,c17241941.posfilter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 再次弹出“请选择要改变表示形式的怪兽”的选择提示框，用于选择对方怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让当前玩家从对方场上选择1只可以变更表示形式的怪兽，并将其登记为效果对象。
	local g2=Duel.SelectTarget(tp,Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置本次连锁的操作信息：登记“变更2只怪兽的表示形式”（CATEGORY_POSITION）的效果处理信息。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,2,0,0)
end
-- 效果处理时，取出本连锁登记的对象卡组，筛选出仍与该效果关联的卡，并将它们全部变更表示形式。
function c17241941.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理中登记的对象卡组（即发动时选择的两只怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 变更相关对象怪兽的表示形式：表侧攻击表示变为表侧守备表示，里侧攻击表示变为里侧守备表示，表侧/里侧守备表示变为表侧攻击表示。
		Duel.ChangePosition(tg,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- 怪兽效果①的发动条件与目标设定：这张卡召唤成功时，若自身可以变更表示形式，则登记变更这张卡表示形式的处理信息。
function c17241941.postg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanChangePosition() end
	-- 设置本次连锁的操作信息：登记“变更这张卡1只怪兽的表示形式”（CATEGORY_POSITION）的效果处理信息。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 效果处理时，若这张卡仍与该效果关联，则变更这张卡的表示形式。
function c17241941.posop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 变更这张卡的表示形式：表侧攻击表示变为表侧守备表示，里侧攻击表示变为里侧守备表示，守备表示变为表侧攻击表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- 判定对象是否为表侧表示的魔法·陷阱卡，用于②效果选择破坏对象。
function c17241941.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ②效果发动时的取对象处理：确认场上存在至少1张表侧表示的魔法·陷阱卡可作为对象，然后让玩家选择其中1张并登记为对象，并登记破坏处理信息。
function c17241941.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c17241941.desfilter(chkc) end
	-- 发动合法性检查：双方场上是否存在至少1张表侧表示的魔法·陷阱卡可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c17241941.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 弹出“请选择要破坏的卡”的选择提示框，提示当前玩家选择要破坏的魔法·陷阱卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张表侧表示的魔法·陷阱卡，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c17241941.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次连锁的操作信息：登记“破坏这1张卡”（CATEGORY_DESTROY）的效果处理信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理时，取得选择的对象卡，若该卡仍与效果关联，则将其破坏。
function c17241941.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁效果处理时唯一的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ③效果的发动条件：这张卡被破坏前位于灵摆区域，且被破坏时是表侧表示。
function c17241941.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_PZONE) and c:IsFaceup()
end
-- ③效果的发动条件与目标检索：确认自己灵摆区域存在至少1张可以回到手卡的卡，并登记从灵摆区域选1张卡回手卡的处理信息。
function c17241941.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己灵摆区域是否存在至少1张可以加入手卡的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_PZONE,0,1,nil) end
	-- 设置本次连锁的操作信息：登记将1张自己灵摆区域的卡回到持有者手卡（CATEGORY_TOHAND）的处理信息，目标位置为灵摆区域。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_PZONE)
end
-- 效果处理时，让玩家从自己灵摆区域选择1张可以回到手卡的卡，显示选择动画并送回持有者手卡。
function c17241941.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要返回手牌的卡”的选择提示框，提示当前玩家选择要返回手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从自己灵摆区域选择1张可以回到手卡的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_PZONE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 为被选择的卡显示选中动画，并记录这些卡成为（广义的）效果对象。
		Duel.HintSelection(g)
		-- 以效果原因将选择的卡送回持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
