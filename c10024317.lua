--パラメタルフォーゼ・メルキャスター
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，以这张卡以外的自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组选1张「炼装」魔法·陷阱卡在自己场上盖放。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：场上的这张卡被战斗·效果破坏的场合才能发动。从自己的额外卡组把「混炼装勇士·汞巫」以外的1只表侧表示的「炼装」灵摆怪兽加入手卡。这个回合，自己不能把这个效果加入手卡的卡以及那些同名卡在灵摆区域发动。
function c10024317.initial_effect(c)
	-- 为卡片添加灵摆怪兽的灵摆召唤以及灵摆卡发动的手续和属性
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
-- 过滤条件：判断卡片是否为表侧表示，且被破坏后能腾出魔陷区空位，且卡组中存在可以盖放的「炼装」魔法或陷阱卡
function c10024317.desfilter(c,tp)
	if c:IsFacedown() then return false end
	-- 判断自己魔陷区是否存在可用的空格，且卡组中存在至少1张可盖放的「炼装」魔法或陷阱卡
	return Duel.GetSZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(c10024317.filter,tp,LOCATION_DECK,0,1,nil,true)
end
-- 过滤条件：判断卡片是否属于「炼装」系列，且为魔法或陷阱卡，且能在场上盖放
function c10024317.filter(c,ignore)
	return c:IsSetCard(0xe1) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(ignore)
end
-- 效果的目标选择：判断场上是否存在除自身外可破坏且符合条件的本方卡片，若有则选择其为效果的对象
function c10024317.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c10024317.desfilter(chkc,tp) and chkc~=e:GetHandler() end
	-- 效果发动时的目标检查：判断自己场上是否存在至少1张除自身外可以作为对象的表侧表示卡片
	if chk==0 then return Duel.IsExistingTarget(c10024317.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上的1张卡作为效果对象
	local g=Duel.SelectTarget(tp,c10024317.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp)
	-- 设置操作信息：在连锁中注册破坏操作，目标为所选择的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果的执行操作：破坏作为对象的卡，并从卡组选择1张「炼装」魔法或陷阱卡在自己的魔陷区盖放
function c10024317.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的对象卡
	local tc=Duel.GetFirstTarget()
	-- 判断这张卡和对象卡是否仍与效果关联，并执行破坏操作，确认实际破坏成功
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组检索1张满足盖放条件的「炼装」魔法或陷阱卡
		local g=Duel.SelectMatchingCard(tp,c10024317.filter,tp,LOCATION_DECK,0,1,1,nil,false)
		if g:GetCount()>0 then
			-- 以效果将检索到的魔法或陷阱卡在自己的魔法与陷阱区域盖放
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
-- 条件检查：判断这张卡是否是表侧表示从场上因战斗或效果破坏
function c10024317.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：判断卡片是否属于「炼装」系列，且为灵摆怪兽，且在额外卡组表侧表示，且卡名不是「混炼装勇士·汞巫」，且可以加入手牌
function c10024317.thfilter(c)
	return c:IsSetCard(0xe1) and c:IsType(TYPE_PENDULUM) and c:IsFaceup() and not c:IsCode(10024317) and c:IsAbleToHand()
end
-- 检索效果的目标选择与操作信息设置：判断额外卡组中是否存在符合条件的怪兽，并在连锁中注册将1张卡加入手牌的操作
function c10024317.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时的目标检查：判断额外卡组中是否存在至少1张符合条件的表侧表示「炼装」灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c10024317.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：在连锁中注册加入手牌的操作，目标为自己额外卡组的1张卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 检索效果的执行操作：从额外卡组选择1张表侧表示的「炼装」灵摆怪兽加入手牌，并限制本回合在灵摆区域发动同名卡
function c10024317.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从额外卡组选择1张表侧表示的满足条件的「炼装」灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c10024317.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 以效果将选择的怪兽加入持有者的手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
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
		-- 注册锁定玩家发动同名卡作为灵摆卡的效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 禁止发动灵摆卡条件的具体判定：判断欲发动的效果是否属于卡片在灵摆区域发动，且卡号与被加入手牌的怪兽相同
function c10024317.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(e:GetLabel())
end
