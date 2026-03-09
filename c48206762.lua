--契約の履行
-- 效果：
-- 支付800基本分。从自己墓地选择1只仪式怪兽在自己场上特殊召唤，并装备上这张卡。这张卡破坏时，装备怪兽从游戏中除外。
function c48206762.initial_effect(c)
	-- 效果原文：支付800基本分。从自己墓地选择1只仪式怪兽在自己场上特殊召唤，并装备上这张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c48206762.cost)
	e1:SetTarget(c48206762.target)
	e1:SetOperation(c48206762.operation)
	c:RegisterEffect(e1)
	-- 这张卡破坏时，装备怪兽从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c48206762.rmop)
	c:RegisterEffect(e2)
end
-- 检查玩家是否能支付800点基本分
function c48206762.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付800点基本分
	if chk==0 then return Duel.CheckLPCost(tp,800)
	-- 让玩家支付800点基本分
	else Duel.PayLPCost(tp,800)	end
end
-- 判断卡片是否为仪式怪兽且可以特殊召唤
function c48206762.filter(c,e,tp)
	return bit.band(c:GetType(),0x81)==0x81 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标为己方墓地的仪式怪兽
function c48206762.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c48206762.filter(chkc,e,tp) end
	-- 判断场上是否有空位可特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断己方墓地是否存在符合条件的仪式怪兽
		and Duel.IsExistingTarget(c48206762.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c48206762.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息为装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备对象限制函数，确保只能装备给该卡
function c48206762.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 执行效果：将目标怪兽特殊召唤并装备此卡
function c48206762.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		-- 将此卡装备给已特殊召唤的怪兽
		Duel.Equip(tp,c,tc)
		-- 设置装备对象限制效果，防止被其他卡装备
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c48206762.eqlimit)
		c:RegisterEffect(e1)
	end
end
-- 当此卡因破坏离场时，将装备的怪兽从游戏中除外
function c48206762.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if c:IsReason(REASON_DESTROY) and tc and tc:IsLocation(LOCATION_MZONE) then
		-- 将目标怪兽从游戏中除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
