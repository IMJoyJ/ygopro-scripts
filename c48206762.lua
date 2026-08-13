--契約の履行
-- 效果：
-- 支付800基本分。从自己墓地选择1只仪式怪兽在自己场上特殊召唤，并装备上这张卡。这张卡破坏时，装备怪兽从游戏中除外。
function c48206762.initial_effect(c)
	-- 支付800基本分。从自己墓地选择1只仪式怪兽在自己场上特殊召唤，并装备上这张卡。
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
-- 发动代价函数：该效果必须通过支付800基本分才能发动，此函数负责代价的检查和支付。
function c48206762.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查玩家能否支付800基本分（chk==0为发动可行性检查阶段）。
	if chk==0 then return Duel.CheckLPCost(tp,800)
	-- 检查通过后实际支付800基本分作为发动代价。
	else Duel.PayLPCost(tp,800)	end
end
-- 筛选自己墓地中满足条件的仪式怪兽（类型为怪兽且为仪式，同时能被效果特殊召唤）。
function c48206762.filter(c,e,tp)
	return bit.band(c:GetType(),0x81)==0x81 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标选择函数：确认自己场上有空位且墓地存在可特殊召唤的仪式怪兽，并选择其中1只作为效果对象；若处理对象已指定则验证其合法性。
function c48206762.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c48206762.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域（特殊召唤所需空位）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只符合条件的仪式怪兽且能成为效果对象。
		and Duel.IsExistingTarget(c48206762.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只仪式怪兽，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c48206762.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本连锁将进行特殊召唤，对象为已选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息：本连锁将把这张卡装备给对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备限制判定：只有最初被特殊召唤的那只仪式怪兽（效果Owner）才能成为这张装备卡的装备对象。
function c48206762.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果处理：将对象怪兽特殊召唤，成功后把这张卡装备给它，并设置对应的装备限制效果。
function c48206762.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁选择的对象怪兽（此卡效果只选1只，即目标仪式怪兽）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 执行特殊召唤；若特殊召唤未成功（返回0），则终止后续的装备处理。
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		-- 特殊召唤成功后，将这张卡作为装备卡装备给对象怪兽。
		Duel.Equip(tp,c,tc)
		-- 并装备上这张卡。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c48206762.eqlimit)
		c:RegisterEffect(e1)
	end
end
-- 离场触发操作：当这张卡被破坏离场时，若其装备怪兽仍在场上，则将该怪兽除外。
function c48206762.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if c:IsReason(REASON_DESTROY) and tc and tc:IsLocation(LOCATION_MZONE) then
		-- 将被装备的仪式怪兽以表侧表示从场上除外（除外原因为效果）。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
