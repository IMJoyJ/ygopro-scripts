--鉄獣式強襲機動兵装改“BucephalusⅡ”
-- 效果：
-- 兽族·兽战士族·鸟兽族怪兽3只以上
-- 自己墓地的「铁兽」魔法·陷阱卡是2张以下的场合，这张卡不能从额外卡组特殊召唤。这个卡名的③的效果1回合只能使用1次。
-- ①：在自己对怪兽的特殊召唤成功时，对方不能把效果发动。
-- ②：自己或对方的怪兽的攻击宣言时才能发动。这张卡以及对方场上的卡全部除外。
-- ③：这张卡被送去墓地的场合才能发动。从额外卡组把1只兽族·兽战士族·鸟兽族怪兽送去墓地。
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 连接召唤：兽族·兽战士族·鸟兽族怪兽3只以上
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST),3,99,s.spchk)
	-- 自己墓地的「铁兽」魔法·陷阱卡是2张以下的场合，这张卡不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- ①：在自己对怪兽的特殊召唤成功时，对方不能把效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.limcon)
	e2:SetOperation(s.limop)
	c:RegisterEffect(e2)
	-- 特召成功时，限制对方玩家直到连锁结束前都不能发动任何卡的效果
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetOperation(s.limop2)
	c:RegisterEffect(e3)
	-- ②：自己或对方的怪兽的攻击宣言时才能发动。这张卡以及对方场上的卡全部除外。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)
	-- ③：这张卡被送去墓地的场合才能发动。从额外卡组把1只兽族·兽战士族·鸟兽族怪兽送去墓地。
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
-- 过滤我方墓地中的「铁兽」魔法·陷阱卡
function s.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x14d)
end
-- 连接召唤检查条件：我方墓地的「铁兽」魔法·陷阱卡在3张以上
function s.spchk(g,lc,tp)
	-- 检查我方墓地是否存在3张以上的「铁兽」魔法·陷阱
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,3,nil)
end
-- 特殊召唤条件限制：我方墓地存在3张以上的「铁兽」魔法·陷阱
function s.splimit(e,se,sp,st,pos,tp)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
		-- 检查我方墓地是否存在3张以上的「铁兽」魔法·陷阱
		or Duel.IsExistingMatchingCard(s.cfilter,sp,LOCATION_GRAVE,0,3,nil)
end
-- 限制连锁条件：我方有怪兽特殊召唤成功
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,e:GetHandler(),tp)
end
-- 特殊召唤成功时限制对方的效果发动
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前连锁数是否为0
	if Duel.GetCurrentChain()==0 then
		-- 限制对方连锁直到这回合的连锁全部结束
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	-- 若特召不是连锁1，则记录需要限制连锁的标记
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 连锁处理时建立事件监听以在此后进行连锁限制
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		-- 注册在发生连锁时重置Flag的效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册在效果处理中断时重置Flag的效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 重置临时防连锁标记
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id)
	e:Reset()
end
-- 连锁结束后执行连锁限制，若标记存在则将后续连锁锁定
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(id)~=0 then
		-- 限制对方连锁直到连锁结束
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	e:GetHandler():ResetFlagEffect(id)
end
-- 限制效果：禁止对方发动任何卡的效果
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- 除外效果的准备阶段：检查自身与对方场上是否存在可除外卡
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove()
		-- 检查对方场上是否存在可以除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取本卡与对方场上的全部卡片组合
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)+c
	-- 声明将本卡及对方场上所有卡片除外的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- 除外效果的实际操作
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上的全部卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if c:IsRelateToEffect(e) then g:AddCard(c) end
	-- 将本卡及对方场上所有卡片全部除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
-- 过滤额外卡组中的兽族·兽战士族·鸟兽族怪兽
function s.filter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsAbleToGrave()
end
-- 送墓效果的目标声明
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 声明从额外卡组将怪兽送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
-- 送墓效果的实际操作
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从额外卡组中选择1只兽族·兽战士族·鸟兽族怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 将选中的怪兽送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
