--鉄獣式強襲機動兵装改“BucephalusⅡ”
-- 效果：
-- 兽族·兽战士族·鸟兽族怪兽3只以上
-- 自己墓地的「铁兽」魔法·陷阱卡是2张以下的场合，这张卡不能从额外卡组特殊召唤。这个卡名的③的效果1回合只能使用1次。
-- ①：在自己对怪兽的特殊召唤成功时，对方不能把效果发动。
-- ②：自己或对方的怪兽的攻击宣言时才能发动。这张卡以及对方场上的卡全部除外。
-- ③：这张卡被送去墓地的场合才能发动。从额外卡组把1只兽族·兽战士族·鸟兽族怪兽送去墓地。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用至少3张且至多99张满足种族为兽族·兽战士族·鸟兽族的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST),3,99,s.spchk)
	-- 自己墓地的「铁兽」魔法·陷阱卡是2张以下的场合，这张卡不能从额外卡组特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- 在自己对怪兽的特殊召唤成功时，对方不能把效果发动
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.limcon)
	e2:SetOperation(s.limop)
	c:RegisterEffect(e2)
	-- 连锁结束时，解除对方不能发动效果的限制
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetOperation(s.limop2)
	c:RegisterEffect(e3)
	-- 自己或对方的怪兽的攻击宣言时才能发动。这张卡以及对方场上的卡全部除外
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)
	-- 这张卡被送去墓地的场合才能发动。从额外卡组把1只兽族·兽战士族·鸟兽族怪兽送去墓地
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
-- 过滤函数，用于判断是否为「铁兽」魔法·陷阱卡
function s.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x14d)
end
-- 连接召唤检查函数，判断是否满足特殊召唤条件
function s.spchk(g,lc,tp)
	-- 检查自己墓地是否存在至少3张「铁兽」魔法·陷阱卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,3,nil)
end
-- 特殊召唤限制函数，判断是否可以特殊召唤
function s.splimit(e,se,sp,st,pos,tp)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
		-- 如果满足条件则允许特殊召唤
		or Duel.IsExistingMatchingCard(s.cfilter,sp,LOCATION_GRAVE,0,3,nil)
end
-- 连锁成功时的条件函数，判断是否为己方召唤的怪兽
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,e:GetHandler(),tp)
end
-- 连锁成功时的操作函数，设置连锁限制
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 当前连锁为0时，设置连锁限制
	if Duel.GetCurrentChain()==0 then
		-- 设置连锁限制直到连锁结束
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	-- 当前连锁为1时，注册连锁重置效果
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 注册连锁中效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		-- 注册连锁中效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册连锁中断效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 连锁重置操作函数
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id)
	e:Reset()
end
-- 连锁结束时的操作函数
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(id)~=0 then
		-- 设置连锁限制直到连锁结束
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	e:GetHandler():ResetFlagEffect(id)
end
-- 连锁限制函数，仅允许自己发动效果
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- 攻击宣言时的除外效果目标函数
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove()
		-- 检查是否满足除外条件
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有卡的集合
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)+c
	-- 设置操作信息为除外效果
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- 攻击宣言时的除外效果操作函数
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有卡的集合
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if c:IsRelateToEffect(e) then g:AddCard(c) end
	-- 将目标卡除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
-- 过滤函数，用于判断是否为兽族·兽战士族·鸟兽族怪兽
function s.filter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsAbleToGrave()
end
-- 墓地效果的目标函数
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足墓地效果发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息为送去墓地效果
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
-- 墓地效果的操作函数
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择卡牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择满足条件的卡牌
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 将卡牌送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
