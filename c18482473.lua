--H・E・R・O フラッシュ！
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下选择1个发动。
-- ●这个回合中，自己的「元素英雄」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ●以最多有自己场上的「元素英雄」怪兽数量的对方场上的卡为对象才能发动。那些卡破坏。
-- ●从自己墓地选1只「元素英雄」怪兽加入手卡或特殊召唤。
-- ●这个回合中，「元素英雄」怪兽可以直接攻击。
local s,id,o=GetID()
-- 创建并注册主效果，设置为发动时可选择的连锁效果
function s.initial_effect(c)
	-- ①：可以从以下选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_SPSUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上己方的「元素英雄」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3008)
end
-- 过滤墓地中的「元素英雄」怪兽，判断是否能加入手卡或特殊召唤
function s.thfilter(c,e,tp)
	if not (c:IsSetCard(0x3008) and c:IsType(TYPE_MONSTER)) then return false end
	-- 获取己方场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 处理选择效果的函数，根据选择的选项设置不同的效果分类和目标
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 统计己方场上的「元素英雄」怪兽数量
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 判断是否可以发动第一个效果（贯通伤害）
	local b1=Duel.GetFlagEffect(tp,id)==0 and Duel.IsAbleToEnterBP()
	-- 判断是否可以发动第二个效果（卡片破坏）
	local b2=ct>0 and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	-- 判断是否可以发动第三个效果（墓地回收）
	local b3=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	-- 判断是否可以发动第四个效果（直接攻击）
	local b4=Duel.GetFlagEffect(tp,id+o)==0 and Duel.IsAbleToEnterBP()
	if chk==0 then return b1 or b2 or b3 or b4 end
	-- 让玩家选择发动哪个效果
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"贯通伤害"
			{b2,aux.Stringid(id,2),2},  --"卡片破坏"
			{b3,aux.Stringid(id,3),3},  --"墓地回收"
			{b4,aux.Stringid(id,4),4})  --"直接攻击"
	e:SetLabel(op)
	e:SetCategory(0)
	e:SetProperty(0)
	if op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DESTROY)
			e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		end
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上的目标卡作为破坏对象
		local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct,nil)
		-- 设置操作信息，记录将要破坏的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	elseif op==3 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_SPSUMMON+CATEGORY_GRAVE_ACTION)
		end
		-- 获取墓地中满足条件的「元素英雄」怪兽
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 设置操作信息，记录将要处理的墓地怪兽
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 过滤「元素英雄」怪兽
function s.atkfilter(e,c)
	return c:IsSetCard(0x3008)
end
-- 执行发动效果的具体操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==1 then
		-- 判断是否已发动过第一个效果（贯通伤害）
		if Duel.GetFlagEffect(tp,id)==0 then
			-- ●这个回合中，自己的「元素英雄」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_PIERCE)
			e1:SetTargetRange(LOCATION_MZONE,0)
			e1:SetTarget(s.atkfilter)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 注册贯通伤害效果
			Duel.RegisterEffect(e1,tp)
			-- 注册已发动贯通伤害的标识
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
	elseif e:GetLabel()==2 then
		-- 获取当前连锁的目标卡
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local tg=g:Filter(Card.IsRelateToChain,nil):Filter(Card.IsOnField,nil)
		if tg:GetCount()>0 then
			-- 将目标卡破坏
			Duel.Destroy(tg,REASON_EFFECT)
		end
	elseif e:GetLabel()==3 then
		-- 提示玩家选择要操作的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 从墓地中选择满足条件的「元素英雄」怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 获取己方场上可用的怪兽区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local tc=g:GetFirst()
		if tc then
			local spchk=ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 判断是否选择将卡加入手卡
			if tc:IsAbleToHand() and (not spchk or Duel.SelectOption(tp,1190,1152)==0) then
				-- 将卡加入手卡
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				-- 确认对方看到该卡加入手卡
				Duel.ConfirmCards(1-tp,tc)
			elseif spchk then
				-- 将卡特殊召唤
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	elseif e:GetLabel()==4 then
		-- 判断是否已发动过第四个效果（直接攻击）
		if Duel.GetFlagEffect(tp,id+o)==0 then
			-- ●这个回合中，「元素英雄」怪兽可以直接攻击。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_DIRECT_ATTACK)
			e2:SetTargetRange(LOCATION_MZONE,0)
			e2:SetTarget(s.atkfilter)
			e2:SetReset(RESET_PHASE+PHASE_END)
			-- 注册直接攻击效果
			Duel.RegisterEffect(e2,tp)
			-- 注册已发动直接攻击的标识
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
