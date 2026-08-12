--レアメタルフォーゼ・ビスマギア
-- 效果：
-- ←8 【灵摆】 8→
-- ①：1回合1次，以这张卡以外的自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组选1张「炼装」魔法·陷阱卡在自己场上盖放。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：场上的这张卡被战斗·效果破坏的场合才能发动。这个回合的结束阶段，从卡组把1只「炼装」怪兽加入手卡。
function c18716735.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性（灵摆召唤，灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以这张卡以外的自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组选1张「炼装」魔法·陷阱卡在自己场上盖放。
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
	-- ①：场上的这张卡被战斗·效果破坏的场合才能发动。这个回合的结束阶段，从卡组把1只「炼装」怪兽加入手卡。
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
-- 过滤函数，用于判断场上一张表侧表示的卡是否可以被破坏并满足盖放条件
function c18716735.desfilter(c,tp)
	if c:IsFacedown() then return false end
	-- 判断目标卡所在位置是否有空的魔法陷阱区域，并且卡组中是否存在满足条件的「炼装」魔法陷阱卡
	return Duel.GetSZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(c18716735.filter,tp,LOCATION_DECK,0,1,nil,true)
end
-- 过滤函数，用于筛选卡组中满足条件的「炼装」魔法陷阱卡
function c18716735.filter(c,ignore)
	return c:IsSetCard(0xe1) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(ignore)
end
-- 设置效果目标，选择满足条件的场上卡作为破坏对象
function c18716735.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c18716735.desfilter(chkc,tp) and chkc~=e:GetHandler() end
	-- 检查是否存在满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(c18716735.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的场上卡作为破坏对象
	local g=Duel.SelectTarget(tp,c18716735.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp)
	-- 设置效果操作信息，记录将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数，执行破坏和盖放操作
function c18716735.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断效果是否有效且目标卡存在并成功破坏
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组中选择满足条件的「炼装」魔法陷阱卡
		local g=Duel.SelectMatchingCard(tp,c18716735.filter,tp,LOCATION_DECK,0,1,1,nil,false)
		if g:GetCount()>0 then
			-- 将选中的魔法陷阱卡盖放在场上
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
-- 判断该卡是否因战斗或效果被破坏且在场上被破坏
function c18716735.regcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 注册一个在结束阶段触发的效果，用于检索「炼装」怪兽
function c18716735.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 注册一个在结束阶段触发的效果，用于检索「炼装」怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c18716735.thcon)
	e1:SetOperation(c18716735.thop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数，用于筛选卡组中满足条件的「炼装」怪兽
function c18716735.thfilter(c)
	return c:IsSetCard(0xe1) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 判断在结束阶段是否可以检索「炼装」怪兽
function c18716735.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查卡组中是否存在满足条件的「炼装」怪兽
	return Duel.IsExistingMatchingCard(c18716735.thfilter,tp,LOCATION_DECK,0,1,nil)
end
-- 处理结束阶段的效果，检索并加入手牌
function c18716735.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示该卡发动的动画提示
	Duel.Hint(HINT_CARD,0,18716735)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的「炼装」怪兽
	local g=Duel.SelectMatchingCard(tp,c18716735.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看了加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
