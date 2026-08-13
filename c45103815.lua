--召喚師ライズベルト
-- 效果：
-- ←2 【灵摆】 2→
-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的等级上升1星。
-- 【怪兽描述】
-- 非常关心爱护妹妹塞姆贝尔，温和亲切的哥哥莱斯贝尔特。刚过中午的午后他跟妹妹一起读魔术书的时间是每日惯例，见到那俩人和睦的情景让周围人们也自然而然被治愈心灵。
function c45103815.initial_effect(c)
	-- 为这张卡注册灵摆怪兽通用的属性与效果（灵摆召唤、灵摆区域发动等）。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c45103815.lvtg)
	e2:SetOperation(c45103815.lvop)
	c:RegisterEffect(e2)
end
-- 选择对象的过滤函数：要求怪兽表侧表示且等级大于0，用于限定可选择的对象。
function c45103815.filter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 效果的目标选择处理：连锁确认时校验指定卡是否满足条件；发动时检查是否存在符合条件的怪兽，存在则提示玩家并选择对象。
function c45103815.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c45103815.filter(chkc) end
	-- 发动时点检查：场上是否存在至少1只满足条件的表侧表示怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c45103815.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送选择对象的提示消息，提示文字为“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从双方怪兽区域选择1只符合条件的表侧表示怪兽，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,c45103815.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理函数：取得对象后，若对象仍与效果关联且保持表侧表示，则对其附加等级上升1星的持续效果，该效果在通常离场等标准重置条件下失效。
function c45103815.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的等级上升1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
