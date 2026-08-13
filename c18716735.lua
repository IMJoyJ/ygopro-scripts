--レアメタルフォーゼ・ビスマギア
-- 效果：
-- ←8 【灵摆】 8→
-- ①：1回合1次，以这张卡以外的自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组选1张「炼装」魔法·陷阱卡在自己场上盖放。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：场上的这张卡被战斗·效果破坏的场合才能发动。这个回合的结束阶段，从卡组把1只「炼装」怪兽加入手卡。
function c18716735.initial_effect(c)
	-- 为这张卡注册灵摆怪兽属性，使其能够作为灵摆怪兽进行灵摆召唤和灵摆卡的发动。
	aux.EnablePendulumAttribute(c)
	-- ←8 【灵摆】 8→ ①：1回合1次，以这张卡以外的自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组选1张「炼装」魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18716735,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c18716735.target)
	e1:SetOperation(c18716735.operation)
	c:RegisterEffect(e1)
	-- 【怪兽效果】这个卡名的怪兽效果1回合只能使用1次。①：场上的这张卡被战斗·效果破坏的场合才能发动。这个回合的结束阶段，从卡组把1只「炼装」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18716735,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,18716735)
	e2:SetCondition(c18716735.regcon)
	e2:SetOperation(c18716735.regop)
	c:RegisterEffect(e2)
end
-- 目标选择过滤器：对象必须是自己场上表侧表示且不是这张卡，同时满足我方魔陷区有空位且卡组存在可盖放的「炼装」魔法·陷阱卡。
function c18716735.desfilter(c,tp)
	if c:IsFacedown() then return false end
	-- 确认我方魔陷区有空余位置，并且卡组中存在可盖放的「炼装」魔法·陷阱卡，以此作为能否选择该对象的条件。
	return Duel.GetSZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(c18716735.filter,tp,LOCATION_DECK,0,1,nil,true)
end
-- 定义可检索的「炼装」魔法·陷阱卡：含有「炼装」字段，类型为魔法/陷阱，且当前可以被盖放。
function c18716735.filter(c,ignore)
	return c:IsSetCard(0xe1) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(ignore)
end
-- 灵摆效果发动时的目标选择处理：选择这张卡以外自己场上1张表侧表示的卡作为破坏对象，并设置操作信息为破坏1张卡。
function c18716735.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c18716735.desfilter(chkc,tp) and chkc~=e:GetHandler() end
	-- 发动合法性检查：判断是否存在满足条件的目标（自己场上表侧表示且不是这张卡，并且满足盖放条件）。
	if chk==0 then return Duel.IsExistingTarget(c18716735.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),tp) end
	-- 提示玩家正在选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上表侧表示的卡中选择1张（不能选这张卡本身）作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c18716735.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp)
	-- 设置本次效果处理将破坏1张卡的操作信息，供后续连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理时：若发动卡和目标卡仍与效果关联，则破坏对象卡；破坏成功后，从卡组选择1张「炼装」魔法·陷阱卡盖放到自己场上。
function c18716735.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的被破坏对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认灵摆卡自身和对象卡都未被无效或离场导致失去关联，然后以效果破坏对象卡；破坏成功后才继续后续盖放处理。
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 提示玩家正在选择要盖放的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组选择1张满足条件的「炼装」魔法·陷阱卡（不取对象，在处理时选择）。
		local g=Duel.SelectMatchingCard(tp,c18716735.filter,tp,LOCATION_DECK,0,1,1,nil,false)
		if g:GetCount()>0 then
			-- 将选中的「炼装」魔法·陷阱卡盖放到自己场上。
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
-- 怪兽效果的发动条件：这张卡被战斗或效果破坏，且破坏前在场上。
function c18716735.regcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果处理：在结束阶段注册一个延迟效果，使该回合结束阶段时检索1只「炼装」怪兽加入手卡。
function c18716735.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合的结束阶段，从卡组把1只「炼装」怪兽加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c18716735.thcon)
	e1:SetOperation(c18716735.thop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将生成的结束阶段延迟效果注册给当前玩家（tp），使在其回合结束阶段时执行检索。
	Duel.RegisterEffect(e1,tp)
end
-- 定义检索目标：卡组中「炼装」字段的怪兽卡，并且可以加入手卡。
function c18716735.thfilter(c)
	return c:IsSetCard(0xe1) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 延迟效果的发动条件：卡组中存在符合条件的「炼装」怪兽。
function c18716735.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查卡组中是否存在至少1只符合条件的「炼装」怪兽，作为条件判定。
	return Duel.IsExistingMatchingCard(c18716735.thfilter,tp,LOCATION_DECK,0,1,nil)
end
-- 延迟效果的实际处理：从卡组选1只「炼装」怪兽加入手牌，并向对方确认。
function c18716735.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方展示该卡的发动动画，提示正在处理这张卡的效果。
	Duel.Hint(HINT_CARD,0,18716735)
	-- 提示玩家正在选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只符合条件的「炼装」怪兽。
	local g=Duel.SelectMatchingCard(tp,c18716735.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
