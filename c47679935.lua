--暴走魔法陣
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「召唤师 阿莱斯特」加入手卡。
-- ②：只要这张卡在场地区域存在，包含把融合怪兽融合召唤效果的效果由自己发动的场合，那个发动不会被无效化，在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
function c47679935.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「召唤师 阿莱斯特」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,47679935+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c47679935.activate)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在场地区域存在，包含把融合怪兽融合召唤效果的效果由自己发动的场合，那个发动不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_INACTIVATE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetValue(c47679935.efilter)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在场地区域存在，包含把融合怪兽融合召唤效果的效果由自己发动的场合，那个发动不会被无效化，在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(c47679935.limcon)
	e3:SetOperation(c47679935.limop)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在场地区域存在，包含把融合怪兽融合召唤效果的效果由自己发动的场合，那个发动不会被无效化，在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCode(EVENT_CHAIN_END)
	e5:SetOperation(c47679935.limop2)
	c:RegisterEffect(e5)
end
-- 过滤函数，返回满足条件的「召唤师 阿莱斯特」卡片组
function c47679935.thfilter(c)
	return c:IsCode(86120751) and c:IsAbleToHand()
end
-- 检索满足条件的「召唤师 阿莱斯特」卡片组，并询问玩家是否发动效果
function c47679935.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「召唤师 阿莱斯特」卡片组
	local g=Duel.GetMatchingGroup(c47679935.thfilter,tp,LOCATION_DECK,0,nil)
	-- 判断是否有满足条件的卡片并询问玩家是否发动效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(47679935,0)) then  --"是否从卡组把「召唤师 阿莱斯特」加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡片送入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 确认对方查看了送入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 判断连锁效果是否为融合召唤效果
function c47679935.efilter(e,ct)
	local p=e:GetHandlerPlayer()
	-- 获取当前连锁的效果和发动玩家
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:IsHasCategory(CATEGORY_FUSION_SUMMON)
end
-- 过滤函数，返回满足条件的融合召唤怪兽
function c47679935.limfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_FUSION)
		and c:GetSpecialSummonInfo(SUMMON_INFO_REASON_EFFECT):IsHasCategory(CATEGORY_FUSION_SUMMON)
end
-- 判断是否有融合召唤成功的怪兽
function c47679935.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47679935.limfilter,1,nil,tp)
end
-- 处理融合召唤成功后的连锁限制设置
function c47679935.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前连锁序号是否为0
	if Duel.GetCurrentChain()==0 then
		-- 设置连锁限制直到连锁结束
		Duel.SetChainLimitTillChainEnd(c47679935.chainlm)
	-- 判断当前连锁序号是否为1
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(47679935,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 注册用于重置标记的连锁效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(c47679935.resetop)
		-- 将效果e1注册给玩家tp
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 将效果e2注册给玩家tp
		Duel.RegisterEffect(e2,tp)
	end
end
-- 重置flag标记并清除效果
function c47679935.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(47679935)
	e:Reset()
end
-- 处理连锁结束时的连锁限制设置
function c47679935.limop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(47679935)~=0 then
		-- 设置连锁限制直到连锁结束
		Duel.SetChainLimitTillChainEnd(c47679935.chainlm)
	end
	e:GetHandler():ResetFlagEffect(47679935)
end
-- 返回值为true表示当前玩家可以发动效果
function c47679935.chainlm(e,rp,tp)
	return tp==rp
end
