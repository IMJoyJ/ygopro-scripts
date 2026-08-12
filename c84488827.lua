--インヴェルズ・ガザス
-- 效果：
-- 把2只名字带有「侵入魔鬼」的怪兽解放对这张卡的上级召唤成功时，从以下效果选择1个发动。
-- ●这张卡以外的场上存在的怪兽全部破坏。
-- ●场上存在的魔法·陷阱卡全部破坏。
function c84488827.initial_effect(c)
	-- 把2只名字带有「侵入魔鬼」的怪兽解放对这张卡的上级召唤成功时，从以下效果选择1个发动。●这张卡以外的场上存在的怪兽全部破坏。●场上存在的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84488827,0))  --"选择1个效果发动"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c84488827.condition)
	e1:SetTarget(c84488827.target)
	e1:SetOperation(c84488827.operation)
	c:RegisterEffect(e1)
	-- 把2只名字带有「侵入魔鬼」的怪兽解放对这张卡的上级召唤成功时
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c84488827.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 检查上级召唤的素材是否满足解放2只「侵入魔鬼」怪兽的条件，并在主效果上设置标记
function c84488827.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,2,nil,0x100a) or g:IsExists(Card.IsCode,1,nil,62729173) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 检查此卡是否为上级召唤成功，且解放的素材满足特定条件
function c84488827.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE) and e:GetLabel()==1
end
-- 过滤场上魔法、陷阱卡的条件函数
function c84488827.sfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动时的对象选择与类型确认，根据场上卡片情况让玩家选择发动“破坏怪兽”或“破坏魔陷”的效果，并设置对应的操作信息
function c84488827.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local op=0
	-- 获取场上除这张卡以外的所有怪兽
	local g1=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 获取场上所有的魔法、陷阱卡
	local g2=Duel.GetMatchingGroup(c84488827.sfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 给玩家发送提示信息，提示选择要发动的效果
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(84488827,0))  --"选择1个效果发动"
	if g1:GetCount()>0 and g2:GetCount()==0 then
		-- 当场上只有怪兽可破坏时，强制选择“这张卡以外的场上存在的怪兽全部破坏”的效果
		op=Duel.SelectOption(tp,aux.Stringid(84488827,1))+1  --"这张卡以外的场上存在的怪兽全部破坏。"
	elseif g1:GetCount()==0 and g2:GetCount()>0 then
		-- 当场上只有魔法·陷阱可破坏时，强制选择“场上存在的魔法·陷阱卡全部破坏”的效果
		op=Duel.SelectOption(tp,aux.Stringid(84488827,2))+2  --"场上存在的魔法·陷阱卡全部破坏。"
	else
		-- 当场上怪兽和魔法·陷阱都存在时，让玩家从两个效果中选择1个
		op=Duel.SelectOption(tp,aux.Stringid(84488827,1),aux.Stringid(84488827,2))+1  --"这张卡以外的场上存在的怪兽全部破坏。/场上存在的魔法·陷阱卡全部破坏。"
	end
	if op==1 and g1:GetCount()>0 then
		-- 设置破坏怪兽的操作信息，用于后续连锁处理
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
	elseif op==2 and g2:GetCount()>0 then
		-- 设置破坏魔法·陷阱卡的操作信息，用于后续连锁处理
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,g2:GetCount(),0,0)
	end
	e:SetLabel(op)
end
-- 效果处理函数，根据玩家选择的分支执行对应的破坏操作
function c84488827.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 获取当前场上除这张卡以外的所有怪兽（排除已离场或不相关的此卡）
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
		-- 因效果破坏选定的所有怪兽
		Duel.Destroy(g,REASON_EFFECT)
	elseif e:GetLabel()==2 then
		-- 获取当前场上的所有魔法、陷阱卡
		local g=Duel.GetMatchingGroup(c84488827.sfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		-- 因效果破坏选定的所有魔法、陷阱卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
