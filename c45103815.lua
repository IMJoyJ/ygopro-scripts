--召喚師ライズベルト
-- 效果：
-- ←2 【灵摆】 2→
-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的等级上升1星。
-- 【怪兽描述】
-- 非常关心爱护妹妹塞姆贝尔，温和亲切的哥哥莱斯贝尔特。刚过中午的午后他跟妹妹一起读魔术书的时间是每日惯例，见到那俩人和睦的情景让周围人们也自然而然被治愈心灵。
function c45103815.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性，使其可以灵摆召唤和发动灵摆卡
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的等级上升1星。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c45103815.lvtg)
	e2:SetOperation(c45103815.lvop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断目标怪兽是否为表侧表示且等级大于0
function c45103815.filter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 效果的发动时点处理函数，用于选择效果的对象
function c45103815.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c45103815.filter(chkc) end
	-- 检查是否满足选择对象的条件，即场上存在符合条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c45103815.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示“请选择效果的对象”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择一个符合条件的场上表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c45103815.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果的处理函数，用于提升目标怪兽的等级
function c45103815.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使目标怪兽的等级上升1星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
