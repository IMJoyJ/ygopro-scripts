--パラメタルフォーゼ・メルキャスター
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，以这张卡以外的自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组选1张「炼装」魔法·陷阱卡在自己场上盖放。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：场上的这张卡被战斗·效果破坏的场合才能发动。从自己的额外卡组把「混炼装勇士·汞巫」以外的1只表侧表示的「炼装」灵摆怪兽加入手卡。这个回合，自己不能把这个效果加入手卡的卡以及那些同名卡在灵摆区域发动。
function c10024317.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以这张卡以外的自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组选1张「炼装」魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10024317,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c10024317.target)
	e1:SetOperation(c10024317.operation)
	c:RegisterEffect(e1)
	-- ①：场上的这张卡被战斗·效果破坏的场合才能发动。从自己的额外卡组把「混炼装勇士·汞巫」以外的1只表侧表示的「炼装」灵摆怪兽加入手卡。这个回合，自己不能把这个效果加入手卡的卡以及那些同名卡在灵摆区域发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10024317,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,10024317)
	e2:SetCondition(c10024317.thcon)
	e2:SetTarget(c10024317.thtg)
	e2:SetOperation(c10024317.thop)
	c:RegisterEffect(e2)
end
-- 判断目标卡是否满足破坏条件，包括是否为表侧表示、是否有空的灵摆区域、卡组中是否存在符合条件的「炼装」魔法·陷阱卡
function c10024317.desfilter(c,tp)
	if c:IsFacedown() then return false end
	-- 检查目标卡是否满足破坏条件，包括是否有空的灵摆区域、卡组中是否存在符合条件的「炼装」魔法·陷阱卡
	return Duel.GetSZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(c10024317.filter,tp,LOCATION_DECK,0,1,nil,true)
end
-- 过滤函数，用于筛选卡组中符合条件的「炼装」魔法·陷阱卡
function c10024317.filter(c,ignore)
	return c:IsSetCard(0xe1) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(ignore)
end
-- 设置灵摆效果的目标选择函数，用于选择要破坏的卡
function c10024317.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c10024317.desfilter(chkc,tp) and chkc~=e:GetHandler() end
	-- 检查是否满足发动条件，即场上是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingTarget(c10024317.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择要破坏的目标卡
	local g=Duel.SelectTarget(tp,c10024317.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp)
	-- 设置操作信息，表示将要破坏目标卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 设置灵摆效果的处理函数，用于执行破坏和盖放操作
function c10024317.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断卡片是否有效并执行破坏操作，若成功则继续处理后续操作
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		-- 从卡组中选择符合条件的「炼装」魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c10024317.filter,tp,LOCATION_DECK,0,1,1,nil,false)
		if g:GetCount()>0 then
			-- 将选中的卡在自己场上盖放
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
-- 设置触发效果的发动条件，判断该卡是否因战斗或效果被破坏且在场上
function c10024317.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数，用于筛选额外卡组中符合条件的「炼装」灵摆怪兽
function c10024317.thfilter(c)
	return c:IsSetCard(0xe1) and c:IsType(TYPE_PENDULUM) and c:IsFaceup() and not c:IsCode(10024317) and c:IsAbleToHand()
end
-- 设置触发效果的目标选择函数，用于选择要加入手牌的卡
function c10024317.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即额外卡组中是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c10024317.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息，表示将要将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 设置触发效果的处理函数，用于执行加入手牌和限制发动的操作
function c10024317.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从额外卡组中选择符合条件的「炼装」灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c10024317.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		local code=g:GetFirst():GetCode()
		-- 创建并注册一个效果，限制对方发动与该卡同名的魔法或陷阱卡
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(c10024317.aclimit)
		e1:SetLabel(code)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册到玩家的全局环境中
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制发动效果的判断函数，用于判断是否为同名卡的魔法或陷阱卡
function c10024317.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(e:GetLabel())
end
