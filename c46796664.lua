--DD魔導賢者コペルニクス
-- 效果：
-- ←1 【灵摆】 1→
-- ①：自己不是「DD」怪兽不能灵摆召唤。这个效果不会被无效化。
-- ②：只在这张卡在灵摆区域存在才有1次，给与自己伤害的魔法卡的效果的处理时，可以把那个效果无效。那之后，这张卡破坏。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。除「DD 魔导贤者 哥白尼」外的1张「DD」卡或「契约书」卡从卡组送去墓地。
function c46796664.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「DD」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c46796664.splimit)
	c:RegisterEffect(e1)
	-- ②：只在这张卡在灵摆区域存在才有1次，给与自己伤害的魔法卡的效果的处理时，可以把那个效果无效。那之后，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetCondition(c46796664.discon)
	e2:SetOperation(c46796664.disop)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。除「DD 魔导贤者 哥白尼」外的1张「DD」卡或「契约书」卡从卡组送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(46796664,0))  --"送去墓地"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,46796664)
	e3:SetTarget(c46796664.tgtg)
	e3:SetOperation(c46796664.tgop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 限制非DD怪兽进行灵摆召唤
function c46796664.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0xaf) and bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 判断连锁是否可以被无效且满足伤害条件
function c46796664.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查连锁是否可被无效且未被无效化
	return Duel.IsChainNegatable(ev) and not Duel.IsChainDisabled(ev)
		-- 确保连锁效果为魔法卡且触发了伤害判定且该效果尚未使用过
		and re:IsActiveType(TYPE_SPELL) and aux.damcon1(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():GetFlagEffect(46796664)==0
end
-- 处理灵摆区域效果的发动，询问玩家是否发动并无效效果后破坏自身
function c46796664.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 询问玩家是否发动该效果
	if not Duel.SelectEffectYesNo(tp,e:GetHandler()) then return end
	e:GetHandler():RegisterFlagEffect(46796664,RESET_EVENT+RESETS_STANDARD,0,1)
	-- 尝试使连锁效果无效
	if not Duel.NegateEffect(ev) then return end
	-- 中断当前效果处理，防止后续效果同时处理
	Duel.BreakEffect()
	-- 将自身破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 过滤满足条件的DD或契约书卡牌
function c46796664.tgfilter(c)
	return c:IsSetCard(0xaf,0xae) and not c:IsCode(46796664) and c:IsAbleToGrave()
end
-- 设置怪兽效果发动时的处理信息，准备从卡组选择一张卡送去墓地
function c46796664.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的卡牌
	if chk==0 then return Duel.IsExistingMatchingCard(c46796664.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 执行怪兽效果的处理，选择并送入墓地一张符合条件的卡
function c46796664.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的一张卡
	local g=Duel.SelectMatchingCard(tp,c46796664.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
