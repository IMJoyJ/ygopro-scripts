--ドラグニティ－ジャベリン
-- 效果：
-- 这张卡在怪兽卡区域上被破坏的场合，可以不送去墓地当作装备魔法卡使用给自己场上表侧表示存在的1只名字带有「龙骑兵团」的鸟兽族怪兽装备。
function c80549379.initial_effect(c)
	-- 这张卡在怪兽卡区域上被破坏的场合，可以不送去墓地当作装备魔法卡使用给自己场上表侧表示存在的1只名字带有「龙骑兵团」的鸟兽族怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c80549379.repcon)
	e1:SetOperation(c80549379.repop)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的名字带有「龙骑兵团」的鸟兽族怪兽
function c80549379.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x29) and c:IsRace(RACE_WINDBEAST)
end
-- 判断此卡是否在怪兽区域被破坏，且自己场上是否存在可装备的「龙骑兵团」鸟兽族怪兽
function c80549379.repcon(e)
	local c=e:GetHandler()
	local tp=c:GetControler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
		-- 检查自己场上是否存在至少1只除自身以外满足条件的「龙骑兵团」鸟兽族怪兽
		and Duel.IsExistingMatchingCard(c80549379.filter,tp,LOCATION_MZONE,0,1,c)
end
-- 执行代替送墓并作为装备卡装备给选定怪兽的操作，并设置装备限制
function c80549379.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择自己场上1只表侧表示的名字带有「龙骑兵团」的鸟兽族怪兽
	local g=Duel.SelectMatchingCard(tp,c80549379.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	local tc=g:GetFirst()
	-- 将自身作为装备卡装备给选中的怪兽
	if Duel.Equip(tp,c,tc,false) then
		-- 当作装备魔法卡使用...装备
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c80549379.eqlimit)
		e1:SetLabelObject(tc)
		c:RegisterEffect(e1)
	end
end
-- 限制该卡只能装备给选定的目标怪兽
function c80549379.eqlimit(e,c)
	return c==e:GetLabelObject()
end
