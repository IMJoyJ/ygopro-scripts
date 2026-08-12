--セイクリッド・カウスト
-- 效果：
-- 这张卡不能作为同调素材。
-- ①：可以以场上1只「星圣」怪兽为对象从以下效果选择1个发动。这个效果1回合可以使用最多2次。
-- ●作为对象的怪兽的等级上升1星。
-- ●作为对象的怪兽的等级下降1星。
function c70908596.initial_effect(c)
	-- ①：可以以场上1只「星圣」怪兽为对象从以下效果选择1个发动。这个效果1回合可以使用最多2次。●作为对象的怪兽的等级上升1星。●作为对象的怪兽的等级下降1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70908596,0))  --"等级变化"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(2)
	e1:SetTarget(c70908596.target)
	e1:SetOperation(c70908596.operation)
	c:RegisterEffect(e1)
	-- 这张卡不能作为同调素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示、等级在1以上且卡名含有「星圣」的怪兽
function c70908596.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x53) and c:IsLevelAbove(1)
end
-- ①号效果的发动准备与对象选择，判断合法目标并让玩家选择等级上升或下降
function c70908596.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c70908596.filter(chkc) end
	-- 在效果发动时，检查场上是否存在至少1只符合条件的「星圣」怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c70908596.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置选择卡片时的提示信息为“请选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择1只符合过滤条件的「星圣」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c70908596.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	local op=0
	-- 如果对象的等级为1，则只能选择“等级上升1星”的选项（防止等级降为0）
	if tc:IsLevel(1) then op=Duel.SelectOption(tp,aux.Stringid(70908596,1))  --"等级上升1星。"
	-- 如果对象的等级大于1，则提供“等级上升1星”和“等级下降1星”两个选项供玩家选择
	else op=Duel.SelectOption(tp,aux.Stringid(70908596,1),aux.Stringid(70908596,2)) end  --"等级上升1星。/等级下降1星。"
	e:SetLabel(op)
end
-- ①号效果的解决函数，获取对象怪兽，并根据玩家的选择对其等级进行增减
function c70908596.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动阶段选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- ●作为对象的怪兽的等级上升1星。●作为对象的怪兽的等级下降1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		if e:GetLabel()==0 then
			e1:SetValue(1)
		else e1:SetValue(-1) end
		tc:RegisterEffect(e1)
	end
end
