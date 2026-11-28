--招来の対価
-- 效果：
-- 这张卡发动的回合的结束阶段时，这个回合自己从手卡·场上解放的衍生物以外的怪兽数量的以下效果适用。「招来的对价」在1回合只能发动1张。
-- ●1只：从卡组抽1张卡。
-- ●2只：选自己墓地2只怪兽加入手卡。
-- ●3只以上：选场上表侧表示存在的最多3张卡破坏。
function c26285788.initial_effect(c)
	-- 这张卡发动的回合的结束阶段时，这个回合自己从手卡·场上解放的衍生物以外的怪兽数量的以下效果适用。「招来的对价」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,26285788+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c26285788.target)
	e1:SetOperation(c26285788.activate)
	c:RegisterEffect(e1)
	if not c26285788.global_check then
		c26285788.global_check=true
		-- 这个回合自己从手卡·场上解放的衍生物以外的怪兽数量
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge1:SetCode(EVENT_RELEASE)
		ge1:SetOperation(c26285788.addcount)
		-- 注册全局持续监听效果，记录本回合双方解放的衍生物以外的怪兽数量
		Duel.RegisterEffect(ge1,0)
	end
end
-- 全局解放计数处理：遍历被解放的卡，每有1只非衍生物怪兽就为其操作玩家登记1次本回合解放标记
function c26285788.addcount(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsType(TYPE_MONSTER) and not tc:IsType(TYPE_TOKEN) then
			local p=tc:GetReasonPlayer()
			-- 为执行解放的玩家叠加1个持续至结束阶段的解放计数标识
			Duel.RegisterFlagEffect(p,26285789,RESET_PHASE+PHASE_END,0,1)
		end
		tc=eg:GetNext()
	end
end
-- 发动检查：确认本效果为通常魔法卡的卡片发动
function c26285788.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) end
end
-- 发动处理：注册本回合结束阶段触发的效果适用处理器
function c26285788.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡发动的回合的结束阶段时，这个回合自己从手卡·场上解放的衍生物以外的怪兽数量的以下效果适用。●1只：从卡组抽1张卡。●2只：选自己墓地2只怪兽加入手卡。●3只以上：选场上表侧表示存在的最多3张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c26285788.effectcon)
	e1:SetOperation(c26285788.effectop)
	-- 为发动玩家注册本回合结束阶段执行的持续效果
	Duel.RegisterEffect(e1,tp)
end
-- 结束阶段触发条件：检查本回合自己解放的非衍生物怪兽数量是否大于0
function c26285788.effectcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家本回合累计的解放怪兽计数是否至少为1
	return Duel.GetFlagEffect(tp,26285789)>0
end
-- 墓地回收过滤函数：筛选可加入手卡的怪兽卡
function c26285788.filter1(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 场上破坏过滤函数：筛选表侧表示存在的卡
function c26285788.filter2(c)
	return c:IsFaceup()
end
-- 结束阶段分歧处理：根据本回合解放数量依次执行抽1张卡、回收墓地2只怪兽或破坏场上最多3张表侧卡
function c26285788.effectop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示「招来的对价」的效果发动提示动画
	Duel.Hint(HINT_CARD,0,26285788)
	-- 读取本回合自己解放的非衍生物怪兽总数
	local ct=Duel.GetFlagEffect(tp,26285789)
	if ct==1 then
		-- 解放1只时：让玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	elseif ct==2 then
		-- 解放2只时：获取自己墓地不受王家长眠之谷影响且可加入手卡的所有怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c26285788.filter1),tp,LOCATION_GRAVE,0,nil)
		if g:GetCount()>1 then
			-- 向玩家提示选择墓地中要加入手卡的2只怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local tg=g:Select(tp,2,2,nil)
			-- 将选中的2只怪兽加入手卡
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的2只怪兽
			Duel.ConfirmCards(1-tp,tg)
		end
	else
		-- 解放3只以上时：获取双方场上所有表侧表示的卡
		local g=Duel.GetMatchingGroup(c26285788.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if g:GetCount()>0 then
			-- 向玩家提示选择场上要破坏的最多3张表侧表示的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local tg=g:Select(tp,1,3,nil)
			-- 以效果原因破坏选中的卡
			Duel.Destroy(tg,REASON_EFFECT)
		end
	end
end
