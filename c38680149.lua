--トラスト・マインド
-- 效果：
-- 把自己场上存在的1只2星以上的怪兽解放发动。从自己墓地把1只持有解放怪兽一半以下的等级的调整加入手卡。
function c38680149.initial_effect(c)
	-- 把自己场上存在的1只2星以上的怪兽解放发动。从自己墓地把1只持有解放怪兽一半以下的等级的调整加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetLabel(0)
	e1:SetCost(c38680149.cost)
	e1:SetTarget(c38680149.target)
	e1:SetOperation(c38680149.activate)
	c:RegisterEffect(e1)
end
-- 代价处理阶段的标记：将标签设为100，表示已进入代价处理流程并允许后续选择解放怪兽；实际解放操作在target中完成。
function c38680149.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 解放怪兽的过滤条件：怪兽等级的一半（向下取整）必须大于0（即原等级至少为2星），且墓地存在1只等级在该数值以下、为调整且可以加入手卡的目标。
function c38680149.filter1(c,e,tp)
	local lv=math.floor(c:GetLevel()/2)
	-- 判定解放怪兽是否满足条件，以及墓地是否存在符合等级限制的调整怪兽可供选择。
	return lv>0 and Duel.IsExistingTarget(c38680149.filter2,tp,LOCATION_GRAVE,0,1,nil,lv)
end
-- 目标卡的过滤条件：等级必须在解放怪兽等级一半以下，是调整怪兽，并且能够加入手卡。
function c38680149.filter2(c,lv)
	return c:IsLevelBelow(lv) and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
-- 发动时的目标处理：确认存在可解放怪兽和可加入手卡的调整；选择解放怪兽，计算等级一半，实际解放，然后选择墓地的调整卡作为效果对象并设置回手处理信息。
function c38680149.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c38680149.filter2(chkc,e:GetLabel()) end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查场上是否存在至少1只满足解放条件的可解放怪兽。
		return Duel.CheckReleaseGroup(tp,c38680149.filter1,1,nil,e,tp)
	end
	-- 从场上选择1只满足解放条件的怪兽作为发动代价。
	local rg=Duel.SelectReleaseGroup(tp,c38680149.filter1,1,1,nil,e,tp)
	local lv=math.floor(rg:GetFirst():GetLevel()/2)
	e:SetLabel(lv)
	-- 将选中的怪兽解放，作为效果的发动代价。
	Duel.Release(rg,REASON_COST)
	-- 向玩家显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从墓地选择1只符合条件的调整怪兽作为效果对象，并将其登记为对象。
	local g=Duel.SelectTarget(tp,c38680149.filter2,tp,LOCATION_GRAVE,0,1,1,nil,lv)
	-- 设置操作信息：本连锁将把对象卡加入手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理阶段：若选中的对象仍与该效果关联，则将其加入手牌，并向对方展示。
function c38680149.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的那张卡。
		Duel.ConfirmCards(1-tp,tc)
	end
end
