--青い涙の乙女
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有连接怪兽存在，对方把怪兽特殊召唤的场合，以那之内的1只为对象才能发动。那只怪兽破坏，给与对方那个原本攻击力一半数值的伤害。
-- ②：这张卡在墓地存在的状态，自己或对方受到效果伤害的场合，把这张卡除外，以自己的墓地·除外状态的1张通常魔法卡为对象才能发动。那张卡在自己场上盖放。那张卡在这个回合不能发动。
local s,id,o=GetID()
-- 初始化卡片的全部效果：注册墓地标记、①破坏效果与合并延迟事件、②盖放效果。
function s.initial_effect(c)
	-- 为这张卡注册“已在墓地”标记，用于②效果在墓地发动时正确判定“这张卡在墓地存在的状态”。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：自己场上有连接怪兽存在，对方把怪兽特殊召唤的场合，以那之内的1只为对象才能发动。那只怪兽破坏，给与对方那个原本攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏效果"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- 注册合并延迟事件：将同一连锁中发生的对方特殊召唤成功事件合并为一个自定义事件(id)，待连锁结束后统一触发①效果，避免重复发动。
	aux.RegisterMergedDelayedEvent(c,id,EVENT_SPSUMMON_SUCCESS)
	-- ②：这张卡在墓地存在的状态，自己或对方受到效果伤害的场合，把这张卡除外，以自己的墓地·除外状态的1张通常魔法卡为对象才能发动。那张卡在自己场上盖放。那张卡在这个回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放效果"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetLabelObject(e0)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.setcon)
	-- 设置②效果的发动代价为“把这张卡除外”。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数：判断该怪兽的召唤玩家为对方，即对方把怪兽特殊召唤。
function s.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp)
end
-- 定义过滤函数：判断怪兽为表侧表示的连接怪兽，用于满足“自己场上有连接怪兽存在”。
function s.cfilter2(c)
	return c:IsType(TYPE_LINK) and c:IsFaceup()
end
-- ①效果的发动条件：本特殊召唤的集合中有对方召唤的怪兽，且自己场上有表侧连接怪兽。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体判定：eg中存在满足对方召唤的怪兽，且自己场上存在至少1只表侧连接怪兽。
	return eg:IsExists(s.cfilter,1,nil,tp) and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义选择对象的过滤函数：对象在怪兽区域且能够被当前效果取对象。
function s.filter(c,e)
	return c:IsLocation(LOCATION_MZONE) and c:IsCanBeEffectTarget(e)
end
-- ①效果发动时处理：从这次特殊召唤的怪兽中选1只为对象，并登记破坏与伤害的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.filter(chkc,e) end
	if chk==0 then return eg:IsExists(s.filter,1,nil,e) end
	-- 向操作者显示选择提示，提示文字为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local g=eg:FilterSelect(tp,s.filter,1,1,nil,e)
	-- 将选择的怪兽设为当前连锁效果的对象。
	Duel.SetTargetCard(g)
	local tc=g:GetFirst()
	local dam=math.max(math.floor(tc:GetTextAttack()/2),0)
	-- 登记本次操作将破坏该对象（1张）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	if tc:IsFaceup() and dam>0 then
		-- 若对象为表侧且攻击力一半大于0，登记将对对方造成该数值伤害的操作。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
	end
end
-- ①效果处理：取对象并破坏；破坏成功时给与对方该怪兽原本攻击力一半数值的伤害。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时当前连锁保存的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判定对象卡仍与效果相关且为怪兽，并执行破坏；破坏成功返回非0时继续。
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local atk=math.floor(tc:GetTextAttack()/2)
		if atk>0 then
			-- 给与对方玩家atk点效果伤害。
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件：受到的伤害是效果伤害，且该伤害不是由本卡②效果盖放的那张通常魔法卡所引发的，防止循环发动。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return bit.band(r,REASON_EFFECT)~=0 and (se==nil or e:GetHandler():GetReasonEffect()~=se)
end
-- 定义选择对象的过滤函数：对象为表侧状态的通常魔法卡，且能被盖放。
function s.setfilter(c)
	return c:IsFaceupEx() and c:GetType()==TYPE_SPELL and c:IsSSetable()
end
-- ②效果发动时处理：选择自己墓地·除外状态的1张通常魔法卡作为对象，并登记离开墓地的操作信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.setfilter(chkc) end
	-- 检查自己墓地·除外状态中是否存在能够作为对象的通常魔法卡。
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 向操作者显示选择提示，提示文字为“请选择要盖放的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己墓地·除外状态中选择1张通常魔法卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 若对象位于墓地，则登记该卡将离开墓地的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,g:GetCount(),0,0)
	end
end
-- ②效果处理：将对象通常魔法卡盖放到自己场上，并让它本回合不能发动。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象（被选中的通常魔法卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将那张通常魔法卡在自己的魔法与陷阱区盖放。
		Duel.SSet(tp,tc)
		-- 那张卡在这个回合不能发动。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
