--同姓同名同盟条約
-- 效果：
-- 自己场上有衍生物以外的同名怪兽表侧表示2只以上存在的场合才能发动。那些同名怪兽的数量的以下效果适用。
-- ●2只：对方场上存在的1张魔法·陷阱卡破坏。
-- ●3只：对方场上存在的魔法·陷阱卡全部破坏。
function c13685271.initial_effect(c)
	-- 自己场上有衍生物以外的同名怪兽表侧表示2只以上存在的场合才能发动。那些同名怪兽的数量的以下效果适用。●2只：对方场上存在的1张魔法·陷阱卡破坏。●3只：对方场上存在的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x11e0)
	e1:SetCondition(c13685271.condition)
	e1:SetTarget(c13685271.target)
	e1:SetOperation(c13685271.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：为“衍生物以外的表侧表示怪兽”，用于检查自己场上的同名怪兽候选。
function c13685271.cfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN)
end
-- 计算给定怪兽集合中同名怪兽的最大数量（如存在3只同名则返回3），用于决定适用2只还是3只效果。
function c13685271.get_count(g)
	if g:GetCount()==0 then return 0 end
	local ret=0
	repeat
		local tc=g:GetFirst()
		g:RemoveCard(tc)
		local ct1=g:GetCount()
		g:Remove(Card.IsCode,nil,tc:GetCode())
		local ct2=g:GetCount()
		local c=ct1-ct2+1
		if c>ret then ret=c end
	until g:GetCount()==0 or g:GetCount()<=ret
	return ret
end
-- 发动条件判断：获取自己场上表侧且非衍生物的怪兽，计算同名怪兽最大数量并存入效果标签，仅在数量为2或3时允许发动。
function c13685271.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己场上全部表侧且非衍生物怪兽的集合，作为判断同名怪兽数量的素材。
	local g=Duel.GetMatchingGroup(c13685271.cfilter,tp,LOCATION_MZONE,0,nil)
	local ct=c13685271.get_count(g)
	e:SetLabel(ct)
	return ct==2 or ct==3
end
-- 定义筛选函数：对方场上存在的魔法·陷阱卡，作为可能被破坏的目标。
function c13685271.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动时的目标检测：确认对方场上有魔法·陷阱卡，并根据发动时判定的同名怪兽数量（2或3）设置对应的破坏操作信息。
function c13685271.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：对方场上必须至少有1张魔法·陷阱卡，否则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c13685271.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 取得对方场上全部魔法·陷阱卡的集合，用于登记破坏数量及供后续处理。
	local g=Duel.GetMatchingGroup(c13685271.filter,tp,0,LOCATION_ONFIELD,nil)
	if e:GetLabel()==2 then
		-- 设置操作信息：当同名怪兽数量为2时，登记破坏对方场上1张魔法·陷阱卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：当同名怪兽数量为3时，登记破坏对方场上全部魔法·陷阱卡（数量取当前卡组数）。
	else Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0) end
end
-- 效果处理时重新统计自己场上的同名怪兽最大数量；若为2则选择破坏1张，若为3则破坏全部。
function c13685271.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次取得自己场上表侧且非衍生物怪兽集合，以当前数量判断对应的破坏效果。
	local g=Duel.GetMatchingGroup(c13685271.cfilter,tp,LOCATION_MZONE,0,nil)
	local ct=c13685271.get_count(g)
	if ct==2 then
		-- 显示“请选择要破坏的卡”的选择提示，引导玩家选择一张卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从对方场上的魔法·陷阱卡中选择1张作为破坏对象（处理时选择，不取对象）。
		local g=Duel.SelectMatchingCard(tp,c13685271.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
		-- 将选择的那张魔法·陷阱卡以效果破坏。
		Duel.Destroy(g,REASON_EFFECT)
	elseif ct==3 then
		-- 当同名怪兽数量为3时，取得对方场上全部魔法·陷阱卡的集合。
		local g=Duel.GetMatchingGroup(c13685271.filter,tp,0,LOCATION_ONFIELD,nil)
		-- 将对方场上的魔法·陷阱卡全部以效果破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
