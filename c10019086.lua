--鉄獣式強襲機動兵装改“BucephalusⅡ”
-- 效果：
-- 兽族·兽战士族·鸟兽族怪兽3只以上
-- 自己墓地的「铁兽」魔法·陷阱卡是2张以下的场合，这张卡不能从额外卡组特殊召唤。这个卡名的③的效果1回合只能使用1次。
-- ①：在自己对怪兽的特殊召唤成功时，对方不能把效果发动。
-- ②：自己或对方的怪兽的攻击宣言时才能发动。这张卡以及对方场上的卡全部除外。
-- ③：这张卡被送去墓地的场合才能发动。从额外卡组把1只兽族·兽战士族·鸟兽族怪兽送去墓地。
local s,id,o=GetID()
-- 定义一个函数，用于初始化卡片的效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为当前卡添加连接召唤手续，要求3个兽族/兽战士族/鸟兽族的怪兽作为素材，并使用s.spchk函数进行检查。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST),3,99,s.spchk)
	-- 创建一个效果，设置其类型为单次生效，代码为特殊召唤条件，属性为不可无效和不可复制，值为s.splimit。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- 创建一个效果，设置其类型为场上持续效果，代码为特殊召唤成功事件，范围为怪兽区，条件为s.limcon，操作为s.limop。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.limcon)
	e2:SetOperation(s.limop)
	c:RegisterEffect(e2)
	-- 创建一个效果，设置其类型为场上持续效果，代码为连锁结束事件，范围为怪兽区，操作为s.limop2。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetOperation(s.limop2)
	c:RegisterEffect(e3)
	-- 创建一个效果，设置其分类为除外，类型为场地触发效果，代码为攻击宣言事件，范围为怪兽区，目标为s.rmtg，操作为s.rmop。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)
	-- 创建一个效果，设置其分类为送去墓地，类型为单次触发效果，代码为送入墓地事件，限制次数为1（id），属性为延迟生效，目标为s.tgtg，操作为s.tgop。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOGRAVE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,id)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetTarget(s.tgtg)
	e5:SetOperation(s.tgop)
	c:RegisterEffect(e5)
end
-- 定义一个函数s.cfilter，用于判断卡片是否为魔法/陷阱卡且属于0x14d系列。
function s.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x14d)
end
-- 定义一个函数s.spchk，用于检查墓地是否存在满足s.cfilter条件的卡牌。
function s.spchk(g,lc,tp)
	-- 返回墓地中存在满足s.cfilter条件卡的数量是否大于等于3。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,3,nil)
end
-- 定义一个函数s.splimit，用于判断当前卡是否可以特殊召唤。如果不在额外怪兽区或者墓地存在满足s.cfilter条件的卡牌则返回true。
function s.splimit(e,se,sp,st,pos,tp)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
		-- 判断墓地是否存在满足s.cfilter条件的卡牌
		or Duel.IsExistingMatchingCard(s.cfilter,sp,LOCATION_GRAVE,0,3,nil)
end
-- 定义一个函数s.limcon，用于检查是否有玩家的怪兽被特殊召唤。
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,e:GetHandler(),tp)
end
-- 定义一个函数s.limop，根据当前连锁的处理情况设置连锁限制或注册效果。
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果当前是初始连锁（链数为0），则使用s.chainlm函数设置连锁限制直到连锁结束。
	if Duel.GetCurrentChain()==0 then
		-- 设置连锁限制
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	-- 否则，如果当前是第一环连锁（链数为1），则注册一个旗效果。
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 创建一个效果，设置其类型为场地持续效果，代码为连锁开始事件，操作为s.resetop。并将其注册到玩家tp。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		-- 注册效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 定义一个函数s.resetop，用于重置旗效果。
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id)
	e:Reset()
end
-- 定义一个函数s.limop2，如果当前卡有flag effect则设置连锁限制，并重置flag effect。
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(id)~=0 then
		-- 设置连锁限制
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	e:GetHandler():ResetFlagEffect(id)
end
-- 定义一个函数s.chainlm，用于判断是否允许对方发动效果。
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- 定义一个函数s.rmtg，用于选择要除外的卡片。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove()
		-- 检查是否存在可被移除的卡牌
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有卡牌并添加到目标组中
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)+c
	-- 设置操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- 定义一个函数s.rmop，用于将选定的卡片除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有卡牌
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if c:IsRelateToEffect(e) then g:AddCard(c) end
	-- 移除卡片
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
-- 定义一个函数s.filter，用于判断卡片是否为兽族/兽战士族/鸟兽族且可以送入墓地。
function s.filter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsAbleToGrave()
end
-- 定义一个函数s.tgtg，用于选择要送入墓地的卡片。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足s.filter条件的卡牌
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
-- 定义一个函数s.tgop，用于将选定的卡片送入墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡牌
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 将选定的卡片送入墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
