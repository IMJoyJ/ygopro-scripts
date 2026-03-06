--招来の対価
-- 效果：
-- 这张卡发动的回合的结束阶段时，这个回合自己从手卡·场上解放的衍生物以外的怪兽数量的以下效果适用。「招来的对价」在1回合只能发动1张。
-- ●1只：从卡组抽1张卡。
-- ●2只：选自己墓地2只怪兽加入手卡。
-- ●3只以上：选场上表侧表示存在的最多3张卡破坏。
function c26285788.initial_effect(c)
	-- 这张卡发动时，将效果注册为魔陷发动，可以自由连锁，发动次数限制为1次
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,26285788+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c26285788.target)
	e1:SetOperation(c26285788.activate)
	c:RegisterEffect(e1)
	if not c26285788.global_check then
		c26285788.global_check=true
		-- 当有怪兽被解放时，记录解放的非衍生物怪兽数量
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge1:SetCode(EVENT_RELEASE)
		ge1:SetOperation(c26285788.addcount)
		-- 将效果注册到全局环境，影响所有玩家
		Duel.RegisterEffect(ge1,0)
	end
end
-- 当有怪兽被解放时，判断是否为怪兽且非衍生物，是则为解放者注册标识效果
function c26285788.addcount(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsType(TYPE_MONSTER) and not tc:IsType(TYPE_TOKEN) then
			local p=tc:GetReasonPlayer()
			-- 为解放者注册一个在结束阶段重置的标识效果，用于记录解放的非衍生物数量
			Duel.RegisterFlagEffect(p,26285789,RESET_PHASE+PHASE_END,0,1)
		end
		tc=eg:GetNext()
	end
end
-- 判断是否为魔陷发动状态
function c26285788.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) end
end
-- 在结束阶段时注册一个持续效果，用于执行后续处理
function c26285788.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在结束阶段时，根据记录的解放数量执行对应效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c26285788.effectcon)
	e1:SetOperation(c26285788.effectop)
	-- 将效果注册给玩家，使其在结束阶段触发
	Duel.RegisterEffect(e1,tp)
end
-- 判断是否已记录过解放的非衍生物数量
function c26285788.effectcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家的标识效果数量，用于判断解放数量
	return Duel.GetFlagEffect(tp,26285789)>0
end
-- 定义过滤条件：怪兽卡且能加入手牌
function c26285788.filter1(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 定义过滤条件：表侧表示的卡
function c26285788.filter2(c)
	return c:IsFaceup()
end
-- 根据记录的解放数量执行对应效果：1只抽一张，2只选2只墓地怪兽加入手牌，3只以上选最多3张卡破坏
function c26285788.effectop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动了此卡
	Duel.Hint(HINT_CARD,0,26285788)
	-- 获取玩家记录的解放数量
	local ct=Duel.GetFlagEffect(tp,26285789)
	if ct==1 then
		-- 让玩家抽一张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	elseif ct==2 then
		-- 获取满足条件的墓地怪兽组
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c26285788.filter1),tp,LOCATION_GRAVE,0,nil)
		if g:GetCount()>1 then
			-- 提示选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local tg=g:Select(tp,2,2,nil)
			-- 将选中的卡加入手牌
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			-- 确认对方查看了加入手牌的卡
			Duel.ConfirmCards(1-tp,tg)
		end
	else
		-- 获取场上表侧表示的卡组
		local g=Duel.GetMatchingGroup(c26285788.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if g:GetCount()>0 then
			-- 提示选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local tg=g:Select(tp,1,3,nil)
			-- 破坏选中的卡
			Duel.Destroy(tg,REASON_EFFECT)
		end
	end
end
