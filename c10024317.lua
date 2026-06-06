--パラメタルフォーゼ・メルキャスター
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，以这张卡以外的自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组选1张「炼装」魔法·陷阱卡在自己场上盖放。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：场上的这张卡被战斗·效果破坏的场合才能发动。从自己的额外卡组把「混炼装勇士·汞巫」以外的1只表侧表示的「炼装」灵摆怪兽加入手卡。这个回合，自己不能把这个效果加入手卡的卡以及那些同名卡在灵摆区域发动。
function c10024317.initial_effect(c)
	-- 启用灵摆怪兽属性与效果
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
-- 过滤条件：判断是否为自己场上表侧表示、破坏后有空余魔陷区且卡组存在可盖放的「炼装」魔陷卡的卡
function c10024317.desfilter(c,tp)
	if c:IsFacedown() then return false end
	-- 判断破坏后是否能有空余的魔陷区域用于盖放，且卡组存在可盖放的「炼装」魔法·陷阱卡
	return Duel.GetSZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(c10024317.filter,tp,LOCATION_DECK,0,1,nil,true)
end
-- 过滤条件：判断是否为可盖放的「炼装」魔法·陷阱卡
function c10024317.filter(c,ignore)
	return c:IsSetCard(0xe1) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(ignore)
end
-- 灵摆效果的发动条件与对象选择：选择此卡以外的自己场上1张表侧表示的卡为对象，设定破坏的操作信息
function c10024317.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c10024317.desfilter(chkc,tp) and chkc~=e:GetHandler() end
	-- 检查场上是否存在此卡以外满足过滤条件的表侧表示的卡
	if chk==0 then return Duel.IsExistingTarget(c10024317.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张表侧表示的卡作为效果的对象
	local g=Duel.SelectTarget(tp,c10024317.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp)
	-- 设置操作信息：破坏选中的对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 灵摆效果的处理：将选中的卡破坏，并从卡组选1张「炼装」魔法·陷阱卡在自己场上盖放
function c10024317.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的对象卡
	local tc=Duel.GetFirstTarget()
	-- 如果此卡和对象卡均在场上，则将对象卡破坏
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组选择1张满足盖放条件的「炼装」魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c10024317.filter,tp,LOCATION_DECK,0,1,1,nil,false)
		if g:GetCount()>0 then
			-- 将选中的卡盖放在自己场上
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
-- 怪兽效果的发动条件判断：判断场上的此卡是否被战斗或效果破坏
function c10024317.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：判断是否为额外卡组中表侧表示的、「混炼装勇士·汞巫」以外且可加入手牌的「炼装」灵摆怪兽
function c10024317.thfilter(c)
	return c:IsSetCard(0xe1) and c:IsType(TYPE_PENDULUM) and c:IsFaceup() and not c:IsCode(10024317) and c:IsAbleToHand()
end
-- 怪兽效果的发动条件与靶指向：检查自己额外卡组是否有满足条件的怪兽，并设定加入手牌的操作信息
function c10024317.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己额外卡组是否存在可加入手牌的「炼装」灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c10024317.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：从额外卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 怪兽效果的处理：从额外卡组将1只表侧表示的「炼装」灵摆怪兽加入手牌，并在本回合限制玩家不能在灵摆区域发动该卡及同名卡
function c10024317.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从额外卡组选择1只满足条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c10024317.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 以效果将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认加入手牌的卡
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
		-- 向玩家注册在灵摆区域不能发动该卡及同名卡的效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制发动的具体条件限制：不能进行以该卡片为卡号的魔陷发动
function c10024317.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(e:GetLabel())
end
