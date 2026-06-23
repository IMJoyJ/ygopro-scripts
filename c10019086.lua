--鉄獣式強襲機動兵装改“BucephalusⅡ”
-- 效果：
-- 兽族·兽战士族·鸟兽族怪兽3只以上
-- 自己墓地的「铁兽」魔法·陷阱卡是2张以下的场合，这张卡不能从额外卡组特殊召唤。这个卡名的③的效果1回合只能使用1次。
-- ①：在自己对怪兽的特殊召唤成功时，对方不能把效果发动。
-- ②：自己或对方的怪兽的攻击宣言时才能发动。这张卡以及对方场上的卡全部除外。
-- ③：这张卡被送去墓地的场合才能发动。从额外卡组把1只兽族·兽战士族·鸟兽族怪兽送去墓地。
local s,id,o=GetID()
-- 初始化这张卡的效果：注册连接召唤手续、特殊召唤限制、特殊召唤成功时对方不能发动效果的永续效果、攻击宣言时将自身和对方场上卡全部除外的诱发即时效果、送去墓地时从额外卡组将兽族/兽战士族/鸟兽族怪兽送去墓地的诱发效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续：使用3只以上的兽族、兽战士族或鸟兽族怪兽作为连接素材
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
	-- ①：在自己对怪兽的特殊召唤成功时，对方不能把效果发动。
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
-- 过滤条件：判断卡片是否为「铁兽」魔法或陷阱卡
function s.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x14d)
end
-- 连接召唤素材检查：判断自己墓地是否存在至少3张「铁兽」魔法·陷阱卡
function s.spchk(g,lc,tp)
	-- 判断自己墓地是否存在至少3张「铁兽」魔法·陷阱卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,3,nil)
end
-- 特殊召唤限制：若这张卡在额外卡组，则需要自己墓地存在至少3张「铁兽」魔法·陷阱卡才能特殊召唤
function s.splimit(e,se,sp,st,pos,tp)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
		-- 判断自己墓地是否存在至少3张「铁兽」魔法·陷阱卡
		or Duel.IsExistingMatchingCard(s.cfilter,sp,LOCATION_GRAVE,0,3,nil)
end
-- 条件检查：判断是否是由自己对怪兽的特殊召唤成功
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,e:GetHandler(),tp)
end
-- 在自己对怪兽特殊召唤成功时锁定连锁：若当前没有处理的连锁，则直接锁定本连锁；若有处理的连锁，则注册在下一条连锁中锁定的辅助效果
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前连锁数是否为0
	if Duel.GetCurrentChain()==0 then
		-- 直到连锁结束为止，限制对方玩家的效果发动
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	-- 如果当前连锁数为1
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		-- ①：在自己对怪兽的特殊召唤成功时，对方不能把效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		-- 在当前连锁中注册当有效果发动时重置标记的效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 在当前连锁中注册效果被中断时重置标记的效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 效果重置：清除卡片的标志效果，并重置自身
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id)
	e:Reset()
end
-- 连锁结束时的处理：若卡片带有指定标记，则限制对方的效果发动直到本轮连锁完全结束，并清除该标记
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(id)~=0 then
		-- 限制对方玩家的效果发动直到连锁结束
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	e:GetHandler():ResetFlagEffect(id)
end
-- 限制发动的条件：判断发起效果发动的玩家是否为本方玩家
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- 除外效果的目标检测：判断自身是否可以除外，且对方场上是否存在可以除外的卡
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove()
		-- 判断对方场上是否存在至少1张可以除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡，并加上这张卡本身，组合成操作卡片组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)+c
	-- 设置操作信息：在连锁中注册除外操作，目标为这张卡以及对方场上的所有卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- 除外效果的执行：将这张卡（若仍在场）以及对方场上的卡全部除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上的所有卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if c:IsRelateToEffect(e) then g:AddCard(c) end
	-- 以效果将目标卡片组以表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
-- 过滤条件：判断卡片是否为兽族、兽战士族或鸟兽族怪兽，且能送去墓地
function s.filter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsAbleToGrave()
end
-- 送墓效果的目标检测：判断额外卡组中是否存在可以送去墓地的兽族、兽战士族或鸟兽族怪兽
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断额外卡组中是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：在连锁中注册送去墓地操作，目标为自己额外卡组的1张卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
-- 送墓效果的执行：让玩家从额外卡组选择1只满足条件的怪兽送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从额外卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 以效果将选中的怪兽送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
