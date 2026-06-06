--鉄獣式強襲機動兵装改“BucephalusⅡ”
-- 效果：
-- 兽族·兽战士族·鸟兽族怪兽3只以上
-- 自己墓地的「铁兽」魔法·陷阱卡是2张以下的场合，这张卡不能从额外卡组特殊召唤。这个卡名的③的效果1回合只能使用1次。
-- ①：在自己对怪兽的特殊召唤成功时，对方不能把效果发动。
-- ②：自己或对方的怪兽的攻击宣言时才能发动。这张卡以及对方场上的卡全部除外。
-- ③：这张卡被送去墓地的场合才能发动。从额外卡组把1只兽族·兽战士族·鸟兽族怪兽送去墓地。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：兽族·兽战士族·鸟兽族怪兽3只以上，且须满足特殊召唤条件
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST),3,99,s.spchk)
	-- 自己墓地的「铁兽」魔法·陷阱卡是2张以下的场合，这张卡不能从额外卡组特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- ①：在自己对怪兽的特殊召唤成功时，对方不能把效果发动
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.limcon)
	e2:SetOperation(s.limop)
	c:RegisterEffect(e2)
	-- ①：在自己对怪兽的特殊召唤成功时，对方不能把效果发动
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetOperation(s.limop2)
	c:RegisterEffect(e3)
	-- ②：自己或对方的怪兽的攻击宣言时才能发动。这张卡以及对方场上的卡全部除外
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)
	-- ③：这张卡被送去墓地的场合才能发动。从额外卡组把1只兽族·兽战士族·鸟兽族怪兽送去墓地
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
-- 过滤条件：判断是否为「铁兽」魔法·陷阱卡
function s.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x14d)
end
-- 检查特殊召唤判定：判断自己墓地是否存在3张以上的「铁兽」魔法·陷阱卡
function s.spchk(g,lc,tp)
	-- 判断自己墓地是否存在3张以上的「铁兽」魔法·陷阱卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,3,nil)
end
-- 从额外卡组特殊召唤的限制条件：判断如果此卡从额外卡组特殊召唤，则自己墓地必须有3张以上的「铁兽」魔法·陷阱卡
function s.splimit(e,se,sp,st,pos,tp)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
		-- 或者自己墓地存在3张以上的「铁兽」魔法·陷阱卡
		or Duel.IsExistingMatchingCard(s.cfilter,sp,LOCATION_GRAVE,0,3,nil)
end
-- 检查是否有除此卡外的怪兽被自己特殊召唤成功
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,e:GetHandler(),tp)
end
-- 特殊召唤成功时对方不能发动效果的限制处理
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否不处于任何连锁中
	if Duel.GetCurrentChain()==0 then
		-- 限制对方不能在直到连锁结束前发动效果
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	-- 判断当前是否是在连锁1中进行了特殊召唤
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		-- ①：在自己对怪兽的特殊召唤成功时，对方不能把效果发动。②：自己或对方的怪兽的攻击宣言时才能发动。这张卡以及对方场上的卡全部除外。③：这张卡被送去墓地的场合才能发动。从额外卡组把1只兽族·兽战士族·鸟兽族怪兽送去墓地
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		-- 在自己回合注册重置标记的效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册在效果处理中途被打断时重置标记的效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 重置标记和效果的处理函数
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id)
	e:Reset()
end
-- 连锁结束时，如果标记存在则限制对方直到该次连锁处理完毕前不能发动效果，并重置标记
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(id)~=0 then
		-- 限制对方不能在直到连锁结束前发动效果
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	e:GetHandler():ResetFlagEffect(id)
end
-- 限制只有自己可以发动效果
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- 攻击宣言除外效果的发动条件与靶指向：检查此卡以及对方场上是否存在可以除外的卡
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove()
		-- 并且对方场上存在至少1张可以除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的全部卡和此卡构成的卡组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)+c
	-- 设置操作信息：包含这些卡在内的卡全部除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- 攻击宣言除外效果的处理：将此卡以及对方场上的卡全部除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上的全部卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if c:IsRelateToEffect(e) then g:AddCard(c) end
	-- 以效果将卡片除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
-- 过滤条件：额外卡组的兽族·兽战士族·鸟兽族怪兽且可以送去墓地
function s.filter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsAbleToGrave()
end
-- 送墓效果的发动条件与靶指向：检查自己额外卡组是否存在满足条件的怪兽，并设定送墓的操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己额外卡组是否存在可送去墓地的兽族·兽战士族·鸟兽族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：从额外卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
-- 送墓效果的处理：从额外卡组选择1只兽族·兽战士族·鸟兽族怪兽送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从额外卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 以效果将选择的卡送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
