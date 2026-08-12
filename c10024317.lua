--パラメタルフォーゼ・メルキャスター
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，以这张卡以外的自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组选1张「炼装」魔法·陷阱卡在自己场上盖放。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：场上的这张卡被战斗·效果破坏的场合才能发动。从自己的额外卡组把「混炼装勇士·汞巫」以外的1只表侧表示的「炼装」灵摆怪兽加入手卡。这个回合，自己不能把这个效果加入手卡的卡以及那些同名卡在灵摆区域发动。
function c10024317.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性及效果动作注册
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
	-- 这个卡名的怪兽效果1回合只能使用1次。①：场上的这张卡被战斗·效果破坏的场合才能发动。从自己的额外卡组把「混炼装勇士·汞巫」以外的1只表侧表示的「炼装」灵摆怪兽加入手卡。这个回合，自己不能把这个效果加入手卡的卡以及那些同名卡在灵摆区域发动。
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
-- 过滤函数：检查作为破坏对象的卡片是否是表侧表示，且卡组中存在可以盖放的「炼装」魔法·陷阱卡
function c10024317.desfilter(c,tp)
	if c:IsFacedown() then return false end
	-- 检查我方场上在破坏指定卡后能否空出魔法与陷阱区域，且自己卡组中是否存在可以盖放的「炼装」魔法·陷阱卡
	return Duel.GetSZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(c10024317.filter,tp,LOCATION_DECK,0,1,nil,true)
end
-- 过滤函数：过滤出卡组中属于「炼装」系列的魔法或陷阱卡且该卡可以盖放在场上
function c10024317.filter(c,ignore)
	return c:IsSetCard(0xe1) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(ignore)
end
-- 效果目标：在发动时检查并选择除了此卡以外的我方场上1张表侧表示的卡作为对象，并设置破坏此对象的连锁操作信息
function c10024317.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c10024317.desfilter(chkc,tp) and chkc~=e:GetHandler() end
	-- 检查我方场上是否存在除了此卡以外、可作为效果对象的表侧表示卡片
	if chk==0 then return Duel.IsExistingTarget(c10024317.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),tp) end
	-- 向玩家发送提示信息以选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1张除了此卡以外表侧表示的卡片作为破坏对象并取对象
	local g=Duel.SelectTarget(tp,c10024317.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp)
	-- 设置当前处理的连锁操作信息为破坏选择的对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏作为对象的卡片，若成功破坏，则从卡组选择1张「炼装」魔法·陷阱卡盖放在我方场上
function c10024317.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁被选为破坏对象的卡片
	local tc=Duel.GetFirstTarget()
	-- 检查此卡和被选为对象的卡片是否仍与当前效果相关联，并且确认该对象卡是否被成功破坏
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 向玩家发送提示信息以选择要盖放的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 让玩家从卡组中选择1张符合盖放条件的「炼装」魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c10024317.filter,tp,LOCATION_DECK,0,1,1,nil,false)
		if g:GetCount()>0 then
			-- 将选择的魔法或陷阱卡盖放在自己的魔法与陷阱区域
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
-- 发动条件：检查此卡是否因效果或战斗被破坏，且被破坏前在场上存在
function c10024317.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数：过滤出额外卡组表侧表示的「炼装」灵摆怪兽且其卡号不能为此卡，同时可以加入手卡
function c10024317.thfilter(c)
	return c:IsSetCard(0xe1) and c:IsType(TYPE_PENDULUM) and c:IsFaceup() and not c:IsCode(10024317) and c:IsAbleToHand()
end
-- 效果目标：检查额外表侧表示卡中是否存在符合条件的灵摆怪兽，并设置加入手卡的连锁操作信息
function c10024317.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组表侧表示的卡中是否存在可以加入手卡的符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c10024317.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置当前处理的连锁操作信息为将指定数量的怪兽加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：从额外卡组将1只表侧表示的「混炼装勇士·汞巫」以外的「炼装」灵摆怪兽加入手卡，并在此回合限制玩家将该卡以及同名卡在灵摆区域发动
function c10024317.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息以选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从额外卡组表侧表示的卡中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c10024317.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 以效果原因将选择的卡片送回玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手卡的选择的卡片
		Duel.ConfirmCards(1-tp,g)
		local code=g:GetFirst():GetCode()
		-- 这个回合，自己不能把这个效果加入手卡的卡以及那些同名卡在灵摆区域发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(c10024317.aclimit)
		e1:SetLabel(code)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 在玩家效果环境注册限制发动效果，以限制对应卡片在本回合在灵摆区域的发动
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制发动条件：限制被加入手卡的卡以及那些同名卡在灵摆区域发动
function c10024317.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(e:GetLabel())
end
