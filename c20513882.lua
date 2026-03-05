--苦渋の黙札
-- 效果：
-- ①：把自己场上1只怪兽解放才能发动。从自己的卡组·墓地选和解放的怪兽是原本卡名不同并是原本的种族·属性·等级相同的1只怪兽加入手卡。
function c20513882.initial_effect(c)
	-- ①：把自己场上1只怪兽解放才能发动。从自己的卡组·墓地选和解放的怪兽是原本卡名不同并是原本的种族·属性·等级相同的1只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetLabel(0)
	e1:SetCost(c20513882.cost)
	e1:SetTarget(c20513882.target)
	e1:SetOperation(c20513882.activate)
	c:RegisterEffect(e1)
end
-- 设置效果标签为100，表示已支付费用
function c20513882.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 检查场上是否存在满足条件的怪兽（等级大于0且卡组或墓地存在符合条件的怪兽）
function c20513882.cfilter(c,tp)
	return c:GetOriginalLevel()>0
		-- 检查卡组或墓地是否存在满足条件的怪兽（等级、种族、属性与解放怪兽相同但卡号不同）
		and Duel.IsExistingMatchingCard(c20513882.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c)
end
-- 过滤条件：怪兽卡、等级、种族、属性与目标怪兽相同、卡号不同、可加入手牌
function c20513882.thfilter(c,tc)
	return c:IsType(TYPE_MONSTER)
		and c:GetOriginalLevel()==tc:GetOriginalLevel()
		and c:GetOriginalRace()==tc:GetOriginalRace()
		and c:GetOriginalAttribute()==tc:GetOriginalAttribute()
		and not c:IsOriginalCodeRule(tc:GetOriginalCodeRule())
		and c:IsAbleToHand()
end
-- 判断是否满足发动条件，若满足则选择并解放场上符合条件的怪兽，设置操作信息
function c20513882.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查场上是否存在满足条件的怪兽用于解放
		return Duel.CheckReleaseGroup(tp,c20513882.cfilter,1,nil,tp)
	end
	-- 选择场上符合条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c20513882.cfilter,1,1,nil,tp)
	e:SetLabelObject(g:GetFirst())
	-- 将选中的怪兽解放作为发动代价
	Duel.Release(g,REASON_COST)
	-- 设置连锁操作信息：将卡组或墓地的怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 发动效果：选择并加入手牌符合条件的怪兽，确认对方查看
function c20513882.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c20513882.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tc)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
