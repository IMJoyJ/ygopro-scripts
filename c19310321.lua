--紋章獣ツインヘッド・イーグル
-- 效果：
-- 把墓地的这张卡从游戏中除外，选择自己场上1只没有超量素材的超量怪兽和自己墓地2只名字带有「纹章兽」的怪兽才能发动。选择的墓地的怪兽在选择的超量怪兽下面重叠作为超量素材。「纹章兽 双头鹰」的效果1回合只能使用1次。
function c19310321.initial_effect(c)
	-- 效果原文内容：把墓地的这张卡从游戏中除外，选择自己场上1只没有超量素材的超量怪兽和自己墓地2只名字带有「纹章兽」的怪兽才能发动。选择的墓地的怪兽在选择的超量怪兽下面重叠作为超量素材。「纹章兽 双头鹰」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19310321,0))  --"素材补充"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,19310321)
	-- 将此卡从游戏中除外作为费用
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c19310321.target)
	e1:SetOperation(c19310321.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的超量怪兽且没有超量素材
function c19310321.filter1(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayCount()==0
end
-- 过滤条件：墓地名字带有「纹章兽」的怪兽且可以被叠放
function c19310321.filter2(c)
	return c:IsSetCard(0x76) and c:IsCanOverlay()
end
-- 效果处理时的条件判断：确认场上存在1只符合条件的超量怪兽和墓地存在2只符合条件的怪兽
function c19310321.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 确认场上存在1只符合条件的超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c19310321.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 确认墓地存在2只符合条件的怪兽
		and Duel.IsExistingTarget(c19310321.filter2,tp,LOCATION_GRAVE,0,2,e:GetHandler()) end
	-- 提示玩家选择一只没有超量素材的超量怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(19310321,1))  --"请选择一只没有素材的超量怪兽"
	-- 选择场上符合条件的1只超量怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c19310321.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 提示玩家选择作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择墓地符合条件的2只怪兽作为效果对象
	local g2=Duel.SelectTarget(tp,c19310321.filter2,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置效果处理信息：将2张卡从墓地离开
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g2,2,0,0)
end
-- 过滤条件：与效果相关且可以被叠放的卡
function c19310321.ovfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsCanOverlay()
end
-- 效果处理函数：将选中的墓地怪兽叠放至场上目标超量怪兽下方
function c19310321.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	-- 获取连锁中被选择的卡片组，并筛选出与效果相关的可叠放卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c19310321.ovfilter,tc,e)
	if g:GetCount()>0 then
		-- 将筛选出的卡片叠放至目标怪兽下方
		Duel.Overlay(tc,g)
	end
end
