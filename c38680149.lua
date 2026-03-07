--トラスト・マインド
-- 效果：
-- 把自己场上存在的1只2星以上的怪兽解放发动。从自己墓地把1只持有解放怪兽一半以下的等级的调整加入手卡。
function c38680149.initial_effect(c)
	-- 效果发动条件：将自己场上存在的1只2星以上的怪兽解放发动。从自己墓地把1只持有解放怪兽一半以下的等级的调整加入手卡。
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
-- 设置cost标签为100，表示已支付费用
function c38680149.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤函数1：检查场上是否存在满足条件的怪兽（等级大于0且墓地存在符合条件的调整）
function c38680149.filter1(c,e,tp)
	local lv=math.floor(c:GetLevel()/2)
	-- 检查场上是否存在满足条件的怪兽（等级大于0且墓地存在符合条件的调整）
	return lv>0 and Duel.IsExistingTarget(c38680149.filter2,tp,LOCATION_GRAVE,0,1,nil,lv)
end
-- 过滤函数2：检查墓地中的调整是否满足等级要求且可加入手牌
function c38680149.filter2(c,lv)
	return c:IsLevelBelow(lv) and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
-- 设置效果目标：选择墓地中的调整作为目标，确保其等级不超过解放怪兽的一半
function c38680149.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c38680149.filter2(chkc,e:GetLabel()) end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查场上是否存在满足条件的怪兽（等级大于0且墓地存在符合条件的调整）
		return Duel.CheckReleaseGroup(tp,c38680149.filter1,1,nil,e,tp)
	end
	-- 从场上选择1只满足条件的怪兽进行解放
	local rg=Duel.SelectReleaseGroup(tp,c38680149.filter1,1,1,nil,e,tp)
	local lv=math.floor(rg:GetFirst():GetLevel()/2)
	e:SetLabel(lv)
	-- 以REASON_COST原因解放选中的怪兽
	Duel.Release(rg,REASON_COST)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从墓地选择1只满足等级要求的调整作为目标
	local g=Duel.SelectTarget(tp,c38680149.filter2,tp,LOCATION_GRAVE,0,1,1,nil,lv)
	-- 设置操作信息，表示将调整加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将选中的调整加入手牌并确认对方查看
function c38680149.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认查看该卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
