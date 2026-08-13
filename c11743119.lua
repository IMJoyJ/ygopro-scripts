--ユニオン・ライダー
-- 效果：
-- 得到对方场上1张处于怪兽状态的同盟怪兽的控制权，装备在这张卡身上。这张卡至多只能以这种方式装备1只同盟怪兽。装备在这张卡身上的同盟怪兽不能以自身效果回复成怪兽状态。
function c11743119.initial_effect(c)
	-- 得到对方场上1张处于怪兽状态的同盟怪兽的控制权，装备在这张卡身上。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11743119,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c11743119.eqcon)
	e1:SetTarget(c11743119.eqtg)
	e1:SetOperation(c11743119.eqop)
	c:RegisterEffect(e1)
end
c11743119.has_text_type=TYPE_UNION
-- 发动条件：通过效果对象判断当前没有已装备的同盟怪兽（或已装备的怪兽已离场重置），从而保证这张卡至多只能以这种方式装备1只同盟怪兽。
function c11743119.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=e:GetLabelObject()
	return ec==nil or ec:GetFlagEffect(11743119)==0
end
-- 筛选条件：目标必须是对方怪兽区的同盟怪兽，且可以变更控制权（作为夺取控制权并装备的对象）。
function c11743119.filter(c)
	return c:IsType(TYPE_UNION) and c:IsAbleToChangeControler()
end
-- 目标选择：选目标时确认其位于对方怪兽区且满足同盟/可换控条件；发动时还需确认我方魔陷区有空位且存在至少1个合法目标。
function c11743119.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c11743119.filter(chkc) end
	-- 检查我方魔陷区是否存在可供装备卡放置的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 确认对方怪兽区存在至少1只满足“同盟怪兽且可被夺控”的怪兽。
		and Duel.IsExistingTarget(c11743119.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家弹出选择提示，要求其选择要装备的对方同盟怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 由玩家选择1只对方怪兽作为效果对象，同时将该卡登记为当前连锁的对象，便于后续处理时取回。
	local g=Duel.SelectTarget(tp,c11743119.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 装备限制条件：仅允许该同盟装备卡装备给效果持有者（同盟骑手），保证其只能装备在这张卡身上。
function c11743119.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果处理：取得目标怪兽，若仍表侧且与效果关联，则将其装备给同盟骑手；成功后为该怪兽打上标记、记录为目标对象，并赋予“只能装备给同盟骑手”的限制，完成夺取并装备。
function c11743119.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的效果对象，即被选择的对方同盟怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标同盟怪兽作为装备卡装备给同盟骑手，若装备操作失败则终止后续处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		tc:RegisterFlagEffect(11743119,RESET_EVENT+RESETS_STANDARD,0,0)
		e:SetLabelObject(tc)
		-- 装备在这张卡身上的同盟怪兽不能以自身效果回复成怪兽状态。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c11743119.eqlimit)
		tc:RegisterEffect(e1)
	end
end
