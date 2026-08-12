--レベル・リチューナー
-- 效果：
-- 自己场上表侧表示存在的1只怪兽的等级下降最多2星。
function c86223870.initial_effect(c)
	-- 自己场上表侧表示存在的1只怪兽的等级下降最多2星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c86223870.target)
	e1:SetOperation(c86223870.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示且等级在2星以上的怪兽
function c86223870.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(2)
end
-- 效果发动的靶向处理，用于选择效果对象
function c86223870.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c86223870.filter(chkc) end
	-- 检查自己场上是否存在至少1只符合条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c86223870.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送提示信息，要求选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c86223870.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使选择的怪兽等级下降1星或2星
function c86223870.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local lv=tc:GetLevel()
		local dlv=1
		if lv==1 then return
		elseif lv>2 then
			-- 让玩家选择等级下降1星或2星
			dlv=Duel.SelectOption(tp,aux.Stringid(86223870,0),aux.Stringid(86223870,1))+1  --"等级下降１星/等级下降２星"
		end
		-- 等级下降最多2星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-dlv)
		tc:RegisterEffect(e1)
	end
end
