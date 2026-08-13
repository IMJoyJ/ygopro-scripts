--ペンデュラム・シフト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上最多2只灵摆怪兽为对象才能发动。那些自己的灵摆怪兽在自己的灵摆区域放置。
function c19501924.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上最多2只灵摆怪兽为对象才能发动。那些自己的灵摆怪兽在自己的灵摆区域放置。
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
-- 计算这张卡发动时允许放置的魔法陷阱区zone位，初始为全部魔陷区0xff；根据灵摆区空位数量和魔陷区空位情况排除不可用的zone，返回可发动位置。
function c19501924.zones(e,tp,eg,ep,ev,re,r,rp)
	local zone=0xff
	local ft=0
	-- 检查自己灵摆区左侧(序号0)是否为空，若为空则可用灵摆区空位计数加1。
	local p0=Duel.CheckLocation(tp,LOCATION_PZONE,0)
	-- 检查自己灵摆区右侧(序号1)是否为空，若为空则可用灵摆区空位计数加1。
	local p1=Duel.CheckLocation(tp,LOCATION_PZONE,1)
	if p0 then ft=ft+1 end
	if p1 then ft=ft+1 end
	local b=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE)
	-- 获取自己魔陷区当前可用的空格数量，用于判断发动魔法卡时是否仍有可放置的区域。
	local st=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local b1=not b and ft>0
	local b2=b and ft==1 and st-ft>0
	local b3=b and ft==2
	if b1 or b3 then return zone end
	if b2 and p0 then zone=zone-0x1 end
	if b2 and p1 then zone=zone-0x10 end
	return zone
end
-- 筛选条件是表侧表示且为灵摆怪兽，用于选择可放置到灵摆区的对象。
function c19501924.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 发动时的目标选择与合法性判定：计算灵摆区空位、判断魔法卡发动时所需区域条件，并从自己怪兽区选择1至ft只表侧灵摆怪兽作为对象。
function c19501924.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft=0
	-- 若自己灵摆区左格空闲，则可放置数量ft加1。
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) then ft=ft+1 end
	-- 若自己灵摆区右格空闲，则可放置数量ft加1。
	if Duel.CheckLocation(tp,LOCATION_PZONE,1) then ft=ft+1 end
	local b=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE)
	-- 获取自己魔陷区空位数，用于判断这张魔法卡能否在该状态下发动。
	local st=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local b1=not b and ft>0
	local b2=b and ft==1 and st-ft>0
	local b3=b and ft==2
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19501924.cfilter(chkc) end
	-- 发动条件检查：自己怪兽区存在表侧灵摆怪兽，且满足灵摆区有空位或魔陷区位置足够等条件时才能发动。
	if chk==0 then return Duel.IsExistingTarget(c19501924.cfilter,tp,LOCATION_MZONE,0,1,nil) and (b1 or b2 or b3) end
	-- 发送选择提示“请选择要放置到场上的卡”，用于玩家的选卡界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从自己怪兽区选择1到ft只表侧灵摆怪兽作为效果对象（ft为可用灵摆区数量）。
	Duel.SelectTarget(tp,c19501924.cfilter,tp,LOCATION_MZONE,0,1,ft,nil)
end
-- 处理时筛选对象：仍是表侧表示、与发动效果相关且不免疫此效果的灵摆怪兽。
function c19501924.mfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e)
end
-- 效果处理：将对象灵摆怪兽放置到自己灵摆区；若对象数量超过可用灵摆区空位，则由玩家选择放置哪些，剩余送去墓地。
function c19501924.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=0
	-- 若左灵摆区空位则ft加1，用于决定可放置数量。
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) then ft=ft+1 end
	-- 若右灵摆区空位则ft加1，用于决定可放置数量。
	if Duel.CheckLocation(tp,LOCATION_PZONE,1) then ft=ft+1 end
	-- 从连锁信息中取得发动时选择的对象，并过滤出仍满足条件（表侧、与效果相关、不免疫）的灵摆怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c19501924.mfilter,nil,e)
	if g:GetCount()>0 then
		if g:GetCount()<=ft then
			local tc=g:GetFirst()
			while tc do
				-- 把选中的灵摆怪兽移动到自己灵摆区，以表侧表示放置，并立即适用其效果。
				Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
				tc=g:GetNext()
			end
		else
			-- 发送选择提示，由玩家选择要放置到场上的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
			local sg=g:Select(tp,ft,ft,nil)
			local tc=sg:GetFirst()
			while tc do
				-- 把玩家选择的灵摆怪兽移动到自己灵摆区，表侧表示放置并立即适用效果。
				Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
				tc=sg:GetNext()
			end
			g:Sub(sg)
			-- 将因灵摆区空位不足而未被放置的剩余对象怪兽以规则原因送去墓地。
			Duel.SendtoGrave(g,REASON_RULE)
		end
	end
end
