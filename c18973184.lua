--失烙印
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，包含把融合怪兽融合召唤效果的效果由自己发动的场合，那个发动不会被无效化，在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
-- ②：自己把融合怪兽融合召唤的场合才能发动。把1只「阿不思的落胤」或者有那个卡名记述的怪兽从卡组加入手卡。
function c18973184.initial_effect(c)
	-- 记录此卡效果文本上记载着「阿不思的落胤」这张卡名
	aux.AddCodeList(c,68468459)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在魔法与陷阱区域存在，包含把融合怪兽融合召唤效果的效果由自己发动的场合，那个发动不会被无效化
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_INACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(c18973184.efilter)
	c:RegisterEffect(e2)
	-- 在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c18973184.limcon)
	e3:SetOperation(c18973184.limop)
	c:RegisterEffect(e3)
	-- 自己把融合怪兽融合召唤的场合才能发动
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_CHAIN_END)
	e4:SetOperation(c18973184.limop2)
	c:RegisterEffect(e4)
	-- 把1只「阿不思的落胤」或者有那个卡名记述的怪兽从卡组加入手卡
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,18973184)
	e5:SetCondition(c18973184.thcon)
	e5:SetTarget(c18973184.thtg)
	e5:SetOperation(c18973184.thop)
	c:RegisterEffect(e5)
end
-- 过滤函数，判断连锁效果是否为融合召唤效果
function c18973184.efilter(e,ct)
	local p=e:GetHandlerPlayer()
	-- 获取当前连锁的效果和发动玩家
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:IsHasCategory(CATEGORY_FUSION_SUMMON)
end
-- 过滤函数，判断是否为融合召唤的怪兽
function c18973184.limfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_FUSION)
		and c:GetSpecialSummonInfo(SUMMON_INFO_REASON_EFFECT):IsHasCategory(CATEGORY_FUSION_SUMMON)
end
-- 判断是否有融合召唤成功的怪兽
function c18973184.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c18973184.limfilter,1,nil,tp)
end
-- 连锁处理函数，根据连锁序号设置连锁限制
function c18973184.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 当前连锁为0时，设置连锁限制
	if Duel.GetCurrentChain()==0 then
		-- 设置连锁限制直到连锁结束
		Duel.SetChainLimitTillChainEnd(c18973184.chainlm)
	-- 当前连锁为1时，注册标记并设置后续处理
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(18973184,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 注册连锁时触发的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(c18973184.resetop)
		-- 将效果注册给玩家
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 将效果注册给玩家
		Duel.RegisterEffect(e2,tp)
	end
end
-- 重置标记和效果
function c18973184.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(18973184)
	e:Reset()
end
-- 连锁结束时处理连锁限制
function c18973184.limop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(18973184)~=0 then
		-- 设置连锁限制直到连锁结束
		Duel.SetChainLimitTillChainEnd(c18973184.chainlm)
	end
	e:GetHandler():ResetFlagEffect(18973184)
end
-- 连锁限制函数，仅允许自己发动
function c18973184.chainlm(e,rp,tp)
	return tp==rp
end
-- 过滤函数，判断是否为融合召唤的怪兽
function c18973184.cfilter(c,tp)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsSummonPlayer(tp)
end
-- 判断是否有融合召唤成功的怪兽
function c18973184.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c18973184.cfilter,1,nil,tp)
end
-- 检索过滤函数，判断是否为「阿不思的落胤」或其衍生物
function c18973184.thfilter(c)
	-- 判断是否为「阿不思的落胤」或其衍生物且可加入手牌
	return (c:IsCode(68468459) or aux.IsCodeListed(c,68468459) and c:IsType(TYPE_MONSTER)) and c:IsAbleToHand()
end
-- 设置效果处理信息，准备检索卡组
function c18973184.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c18973184.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，准备将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，选择并加入手牌
function c18973184.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c18973184.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
