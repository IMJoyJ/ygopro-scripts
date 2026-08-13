--紋章獣ツインヘッド・イーグル
-- 效果：
-- 把墓地的这张卡从游戏中除外，选择自己场上1只没有超量素材的超量怪兽和自己墓地2只名字带有「纹章兽」的怪兽才能发动。选择的墓地的怪兽在选择的超量怪兽下面重叠作为超量素材。「纹章兽 双头鹰」的效果1回合只能使用1次。
function c19310321.initial_effect(c)
	-- 把墓地的这张卡从游戏中除外，选择自己场上1只没有超量素材的超量怪兽和自己墓地2只名字带有「纹章兽」的怪兽才能发动。选择的墓地的怪兽在选择的超量怪兽下面重叠作为超量素材。「纹章兽 双头鹰」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19310321,0))  --"素材补充"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,19310321)
	-- 为效果设置发动COST：将墓地的这张卡从游戏中除外作为发动代价。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c19310321.target)
	e1:SetOperation(c19310321.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件：自己场上表侧表示的超量怪兽，且没有超量素材。
function c19310321.filter1(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayCount()==0
end
-- 筛选条件：自己墓地中名字带有「纹章兽」（0x76）的怪兽，且可作为超量素材。
function c19310321.filter2(c)
	return c:IsSetCard(0x76) and c:IsCanOverlay()
end
-- 效果发动目标判定：若chkc不为nil则直接返回false（不进行外部对象检查）；在chk==0时检查是否存在符合条件的超量怪兽和墓地纹章兽，以判断效果可否发动。
function c19310321.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在1只表侧表示且没有超量素材的超量怪兽，若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c19310321.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己墓地是否存在2只名字带有「纹章兽」且可作为超量素材的怪兽（排除此卡自身），若不足则效果不能发动。
		and Duel.IsExistingTarget(c19310321.filter2,tp,LOCATION_GRAVE,0,2,e:GetHandler()) end
	-- 发送选择提示，让玩家从符合条件的怪兽中选择1只没有超量素材的超量怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(19310321,1))  --"请选择一只没有素材的超量怪兽"
	-- 选择自己场上1只满足filter1的超量怪兽作为效果对象。
	local g1=Duel.SelectTarget(tp,c19310321.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 发送选择提示，让玩家选择要作为超量素材的墓地怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择自己墓地2只满足filter2的纹章兽作为效果对象。
	local g2=Duel.SelectTarget(tp,c19310321.filter2,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置操作信息，登记这些墓地怪兽将因本效果离开墓地，数量为2。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g2,2,0,0)
end
-- 处理阶段的筛选条件：检查对象怪兽仍与此效果关联且可以作为超量素材。
function c19310321.ovfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsCanOverlay()
end
-- 效果处理：取出之前选择的超量怪兽，若其已里侧表示、或与效果失去关联、或对此效果免疫则终止；否则从连锁对象中筛选出仍然有效的墓地纹章兽并叠放为超量素材。
function c19310321.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	-- 从当前连锁记录的取对象卡片中，筛选出仍与此效果关联且可作为超量素材的墓地怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c19310321.ovfilter,tc,e)
	if g:GetCount()>0 then
		-- 将选中的墓地怪兽叠放在目标超量怪兽下方，作为其超量素材。
		Duel.Overlay(tc,g)
	end
end
