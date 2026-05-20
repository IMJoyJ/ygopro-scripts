--リブロマンサー・オリジン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组选「书灵师本源」以外的1张「书灵师」魔法·陷阱卡在自己场上盖放。
-- ②：自己场上的「书灵师」仪式怪兽的攻击力上升自身的等级×100。
-- ③：自己场上有仪式怪兽仪式召唤的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
function c84121302.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组选「书灵师本源」以外的1张「书灵师」魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,84121302+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c84121302.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的「书灵师」仪式怪兽的攻击力上升自身的等级×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTarget(c84121302.atktg)
	e2:SetValue(c84121302.atkval)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：自己场上有仪式怪兽仪式召唤的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(84121302,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,84121303)
	e3:SetCondition(c84121302.descon)
	e3:SetTarget(c84121302.destg)
	e3:SetOperation(c84121302.desop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中「书灵师本源」以外的「书灵师」魔法·陷阱卡且可以盖放的卡
function c84121302.setfilter(c)
	return not c:IsCode(84121302) and c:IsSetCard(0x17c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 卡片发动时的效果处理：可以从卡组选1张满足条件的「书灵师」魔法·陷阱卡在自己场上盖放
function c84121302.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足盖放条件的「书灵师」魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c84121302.setfilter,tp,LOCATION_DECK,0,nil)
	-- 若存在可盖放的卡，则由玩家选择是否发动该效果
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(84121302,0)) then  --"是否选卡在场上盖放？"
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		local sc=g:Select(tp,1,1,nil):GetFirst()
		-- 将选择的卡在自己场上盖放
		Duel.SSet(tp,sc)
	end
end
-- 过滤自己场上的「书灵师」仪式怪兽作为攻击力上升效果的对象
function c84121302.atktg(e,c)
	return c:IsSetCard(0x17c) and c:IsType(TYPE_RITUAL)
end
-- 计算攻击力上升值，数值为自身等级×100
function c84121302.atkval(e,c)
	return c:GetLevel()*100
end
-- 过滤自己场上表侧表示且通过仪式召唤特殊召唤成功的仪式怪兽
function c84121302.spfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL) and c:IsSummonType(SUMMON_TYPE_RITUAL) and c:IsControler(tp)
end
-- 检查是否有自己场上的仪式怪兽仪式召唤成功，作为效果发动的条件
function c84121302.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c84121302.spfilter,1,nil,tp)
end
-- 效果③的靶向与合法性检测，选择对方场上1张魔法·陷阱卡作为对象并确认破坏操作
function c84121302.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 在效果发动阶段，检测对方场上是否存在可以作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置效果处理信息，声明该效果包含破坏1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果③的效果处理：破坏作为对象的卡
function c84121302.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将该对象卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
