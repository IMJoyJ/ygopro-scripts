--ペンデュラム・シフト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上最多2只灵摆怪兽为对象才能发动。那些自己的灵摆怪兽在自己的灵摆区域放置。
function c19501924.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_LIMIT_ZONE)
	e1:SetCountLimit(1,19501924+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c19501924.target)
	e1:SetOperation(c19501924.activate)
	e1:SetValue(c19501924.zones)
	c:RegisterEffect(e1)
end
-- 计算灵摆区域可用位置数量并返回可用区域掩码
function c19501924.zones(e,tp,eg,ep,ev,re,r,rp)
	local zone=0xff
	local ft=0
	-- 检查玩家tp的灵摆区0位置是否可用
	local p0=Duel.CheckLocation(tp,LOCATION_PZONE,0)
	-- 检查玩家tp的灵摆区1位置是否可用
	local p1=Duel.CheckLocation(tp,LOCATION_PZONE,1)
	if p0 then ft=ft+1 end
	if p1 then ft=ft+1 end
	local b=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE)
	-- 获取玩家tp的魔陷区可用位置数量
	local st=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local b1=not b and ft>0
	local b2=b and ft==1 and st-ft>0
	local b3=b and ft==2
	if b1 or b3 then return zone end
	if b2 and p0 then zone=zone-0x1 end
	if b2 and p1 then zone=zone-0x10 end
	return zone
end
-- 筛选满足条件的灵摆怪兽
function c19501924.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 选择目标：以自己场上最多2只灵摆怪兽为对象
function c19501924.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft=0
	-- 若灵摆区0位置可用，则增加可用位置计数
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) then ft=ft+1 end
	-- 若灵摆区1位置可用，则增加可用位置计数
	if Duel.CheckLocation(tp,LOCATION_PZONE,1) then ft=ft+1 end
	local b=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE)
	-- 获取玩家tp的魔陷区可用位置数量
	local st=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local b1=not b and ft>0
	local b2=b and ft==1 and st-ft>0
	local b3=b and ft==2
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19501924.cfilter(chkc) end
	-- 判断是否满足发动条件：存在目标且满足区域限制
	if chk==0 then return Duel.IsExistingTarget(c19501924.cfilter,tp,LOCATION_MZONE,0,1,nil) and (b1 or b2 or b3) end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择目标：从自己场上选择1到ft只灵摆怪兽
	Duel.SelectTarget(tp,c19501924.cfilter,tp,LOCATION_MZONE,0,1,ft,nil)
end
-- 筛选满足条件的卡片组
function c19501924.mfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e)
end
-- 处理效果发动：将目标灵摆怪兽移至灵摆区域
function c19501924.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=0
	-- 若灵摆区0位置可用，则增加可用位置计数
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) then ft=ft+1 end
	-- 若灵摆区1位置可用，则增加可用位置计数
	if Duel.CheckLocation(tp,LOCATION_PZONE,1) then ft=ft+1 end
	-- 获取连锁中目标卡片组并筛选满足条件的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c19501924.mfilter,nil,e)
	if g:GetCount()>0 then
		if g:GetCount()<=ft then
			local tc=g:GetFirst()
			while tc do
				-- 将卡片移至灵摆区域
				Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
				tc=g:GetNext()
			end
		else
			-- 提示玩家选择要放置到场上的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
			local sg=g:Select(tp,ft,ft,nil)
			local tc=sg:GetFirst()
			while tc do
				-- 将卡片移至灵摆区域
				Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
				tc=sg:GetNext()
			end
			g:Sub(sg)
			-- 将超出数量的卡片送去墓地
			Duel.SendtoGrave(g,REASON_RULE)
		end
	end
end
