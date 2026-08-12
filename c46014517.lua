--百鬼羅刹唯我独尊
-- 效果：
-- 6星怪兽×2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以最多有自己场上的「哥布林」怪兽数量的对方场上的表侧表示怪兽为对象才能发动。自己场上1个超量素材取除，把作为对象的怪兽作为这张卡的超量素材。
-- ②：对方回合，以最多有自己场上的「哥布林」超量怪兽数量的对方场上的卡为对象才能发动。自己场上3个超量素材取除，作为对象的卡送去墓地。
local s,id,o=GetID()
-- 初始化效果函数，设置XYZ召唤手续、启用复活限制，并注册两个效果
function s.initial_effect(c)
	-- 添加XYZ召唤手续，要求至少2只6星怪兽叠放
	aux.AddXyzProcedure(c,nil,6,2,nil,nil,99)
	c:EnableReviveLimit()
	-- 效果①：吸收超量素材
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"吸收超量素材"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.mttg)
	e1:SetOperation(s.mtop)
	c:RegisterEffect(e1)
	-- 效果②：送去墓地
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+o)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 过滤可以作为超量素材的怪兽
function s.mtfilter(c)
	return c:IsFaceup() and c:IsCanOverlay()
end
-- 过滤场上的哥布林怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xac)
end
-- 效果①的发动条件判断函数
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 计算场上哥布林怪兽数量
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.mtfilter(chkc) end
	if chk==0 then return ct>0 and e:GetHandler():IsType(TYPE_XYZ)
		-- 检查是否能移除1个超量素材
		and Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT)
		-- 检查对方场上是否存在可作为对象的怪兽
		and Duel.IsExistingTarget(s.mtfilter,tp,0,LOCATION_MZONE,1,e:GetHandler()) end
	-- 提示选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择目标怪兽作为超量素材
	Duel.SelectTarget(tp,s.mtfilter,tp,0,LOCATION_MZONE,1,ct,e:GetHandler())
end
-- 过滤可以被处理的怪兽
function s.mtopfilter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e)
end
-- 效果①的处理函数
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 移除1个超量素材
	if Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_EFFECT)==0 then return end
	if c:IsRelateToEffect(e) then
		-- 获取连锁中的目标卡组
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local tg=g:Filter(s.mtopfilter,nil,e)
		-- 遍历目标卡组中的每张卡
		for tc in aux.Next(tg) do
			local og=tc:GetOverlayGroup()
			if og:GetCount()>0 then
				-- 将目标卡的叠放卡送去墓地
				Duel.SendtoGrave(og,REASON_RULE)
			end
		end
		-- 将目标卡叠放至自身
		Duel.Overlay(c,tg)
	end
end
-- 效果②的发动条件判断函数
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤场上的哥布林超量怪兽
function s.cfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0xac) and c:IsType(TYPE_XYZ)
end
-- 效果②的发动条件判断函数
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 计算场上哥布林超量怪兽数量
	local ct=Duel.GetMatchingGroupCount(s.cfilter2,tp,LOCATION_MZONE,0,nil)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsAbleToGrave() end
	-- 检查是否能移除3个超量素材
	if chk==0 then return ct>0 and Duel.CheckRemoveOverlayCard(tp,1,0,3,REASON_EFFECT)
		-- 检查对方场上是否存在可送去墓地的卡
		and Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择目标卡送去墓地
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置操作信息，指定将要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 效果②的处理函数
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 移除3个超量素材
	if Duel.RemoveOverlayCard(tp,1,0,3,3,REASON_EFFECT)==0 then return end
	-- 获取连锁中的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将目标卡送去墓地
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end
