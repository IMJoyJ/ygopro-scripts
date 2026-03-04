--ユニオン・ライダー
-- 效果：
-- 得到对方场上1张处于怪兽状态的同盟怪兽的控制权，装备在这张卡身上。这张卡至多只能以这种方式装备1只同盟怪兽。装备在这张卡身上的同盟怪兽不能以自身效果回复成怪兽状态。
function c11743119.initial_effect(c)
	-- 效果原文内容：得到对方场上1张处于怪兽状态的同盟怪兽的控制权，装备在这张卡身上。
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
-- 规则层面作用：判断是否可以发动装备效果，确保当前没有已装备的同盟怪兽。
function c11743119.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=e:GetLabelObject()
	return ec==nil or ec:GetFlagEffect(11743119)==0
end
-- 规则层面作用：筛选符合条件的同盟怪兽（可改变控制权）。
function c11743119.filter(c)
	return c:IsType(TYPE_UNION) and c:IsAbleToChangeControler()
end
-- 效果原文内容：得到对方场上1张处于怪兽状态的同盟怪兽的控制权，装备在这张卡身上。
function c11743119.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c11743119.filter(chkc) end
	-- 规则层面作用：检查玩家在魔陷区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 规则层面作用：确认对方场上是否存在符合条件的同盟怪兽。
		and Duel.IsExistingTarget(c11743119.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 规则层面作用：向玩家发送提示信息，提示选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 规则层面作用：选择对方场上的一个同盟怪兽作为装备目标。
	local g=Duel.SelectTarget(tp,c11743119.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 规则层面作用：设置装备对象限制函数。
function c11743119.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果原文内容：装备在这张卡身上的同盟怪兽不能以自身效果回复成怪兽状态。
function c11743119.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面作用：获取当前连锁效果的目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 规则层面作用：尝试将目标怪兽装备给自身，若失败则返回。
		if not Duel.Equip(tp,tc,c,false) then return end
		tc:RegisterFlagEffect(11743119,RESET_EVENT+RESETS_STANDARD,0,0)
		e:SetLabelObject(tc)
		-- 效果原文内容：装备在这张卡身上的同盟怪兽不能以自身效果回复成怪兽状态。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c11743119.eqlimit)
		tc:RegisterEffect(e1)
	end
end
