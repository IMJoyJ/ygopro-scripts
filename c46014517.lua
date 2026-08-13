--百鬼羅刹唯我独尊
-- 效果：
-- 6星怪兽×2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以最多有自己场上的「哥布林」怪兽数量的对方场上的表侧表示怪兽为对象才能发动。自己场上1个超量素材取除，把作为对象的怪兽作为这张卡的超量素材。
-- ②：对方回合，以最多有自己场上的「哥布林」超量怪兽数量的对方场上的卡为对象才能发动。自己场上3个超量素材取除，作为对象的卡送去墓地。
local s,id,o=GetID()
-- 初始化效果：设置超量召唤手续（任意6星怪兽2只以上叠放，最大99张），启用苏生限制，并注册①起动效果和②诱发即时效果。
function s.initial_effect(c)
	-- 为这张卡添加超量召唤手续：可用任意6星怪兽2只以上叠放（最大99张），对应“6星怪兽×2只以上”。
	aux.AddXyzProcedure(c,nil,6,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：以最多有自己场上的「哥布林」怪兽数量的对方场上的表侧表示怪兽为对象才能发动。自己场上1个超量素材取除，把作为对象的怪兽作为这张卡的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"吸收超量素材"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.mttg)
	e1:SetOperation(s.mtop)
	c:RegisterEffect(e1)
	-- ②：对方回合，以最多有自己场上的「哥布林」超量怪兽数量的对方场上的卡为对象才能发动。自己场上3个超量素材取除，作为对象的卡送去墓地。
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
-- 过滤可作为超量素材的怪兽：表侧表示且可以作为超量素材。
function s.mtfilter(c)
	return c:IsFaceup() and c:IsCanOverlay()
end
-- 过滤自己场上的「哥布林」怪兽：表侧表示且卡名含有「哥布林」字段（0xac）。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xac)
end
-- ①效果的发动条件与取对象：统计自己场上「哥布林」怪兽数作为可选对象数上限，要求此卡为XYZ怪兽、自己场上能去除1个超量素材、且对方场上有至少1只可作为超量素材的表侧表示怪兽；满足则从对方场上选择1~ct只符合条件的表侧表示怪兽为对象。
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 统计自己场上表侧表示「哥布林」怪兽的数量，作为可选对象数量上限ct。
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.mtfilter(chkc) end
	if chk==0 then return ct>0 and e:GetHandler():IsType(TYPE_XYZ)
		-- 检查自己场上能否以效果取除1个超量素材作为发动代价。
		and Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT)
		-- 检查对方场上是否存在至少1只可作为超量素材的表侧表示怪兽（作为发动条件），且可选对象存在。
		and Duel.IsExistingTarget(s.mtfilter,tp,0,LOCATION_MZONE,1,e:GetHandler()) end
	-- 给玩家显示“请选择要作为超量素材的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 让玩家从对方场上选择1~ct只满足条件的表侧表示怪兽作为效果对象。
	Duel.SelectTarget(tp,s.mtfilter,tp,0,LOCATION_MZONE,1,ct,e:GetHandler())
end
-- 处理时过滤对象：必须是怪兽、与该效果仍有关联且不免疫此效果。
function s.mtopfilter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e)
end
-- ①效果处理：先取除自己场上1个超量素材；若此卡仍在场，则获取连锁对象并过滤，将每个对象怪兽原有的超量素材按规则送去墓地，最后把对象怪兽叠放在此卡下作为超量素材。
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 实际取除自己场上1个超量素材；若取除失败则终止处理。
	if Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_EFFECT)==0 then return end
	if c:IsRelateToEffect(e) then
		-- 获取发动时选择的对象卡组。
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local tg=g:Filter(s.mtopfilter,nil,e)
		-- 遍历所有对象怪兽，分别处理其原有超量素材。
		for tc in aux.Next(tg) do
			local og=tc:GetOverlayGroup()
			if og:GetCount()>0 then
				-- 将对象怪兽自身的超量素材按规则送去墓地（因为该怪兽被叠放时其素材会失去）。这里使用REASON_RULE表示非效果造成的送去墓地。
				Duel.SendtoGrave(og,REASON_RULE)
			end
		end
		-- 将过滤后的对象怪兽叠放在这张卡下面作为超量素材。
		Duel.Overlay(c,tg)
	end
end
-- ②效果的发动条件：只在对方回合可以发动。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方的玩家（1-tp），实现“对方回合”条件。
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤自己场上的「哥布林」超量怪兽：表侧表示、字段0xac且为超量怪兽。
function s.cfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0xac) and c:IsType(TYPE_XYZ)
end
-- ②效果的发动条件与取对象：统计自己场上「哥布林」超量怪兽数作为可选对象数上限，要求能取除自己场上3个超量素材且对方场上有可送去墓地的卡；满足则从对方场上选择1~ct张可送去墓地的卡为对象，并设置送去墓地的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 统计自己场上表侧表示「哥布林」超量怪兽的数量，作为可选对象数量上限ct。
	local ct=Duel.GetMatchingGroupCount(s.cfilter2,tp,LOCATION_MZONE,0,nil)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsAbleToGrave() end
	-- 发动条件检查：自己场上有「哥布林」超量怪兽且能用效果取除3个超量素材。
	if chk==0 then return ct>0 and Duel.CheckRemoveOverlayCard(tp,1,0,3,REASON_EFFECT)
		-- 检查对方场上是否存在至少1张可以送去墓地的卡（作为发动条件）。
		and Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给玩家显示“请选择要送去墓地的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从对方场上选择1~ct张可送去墓地的卡作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 将当前连锁的操作信息设为“送去墓地”，对象为已选卡组g，数量为g的数量，供相关卡/效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- ②效果处理：先取除自己场上3个超量素材；若成功则获取连锁对象并过滤仍与该效果关联的卡，然后将它们送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际取除自己场上3个超量素材；若取除失败则终止处理。
	if Duel.RemoveOverlayCard(tp,1,0,3,3,REASON_EFFECT)==0 then return end
	-- 获取发动时选择的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将过滤后的对象卡全部送去墓地。
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end
