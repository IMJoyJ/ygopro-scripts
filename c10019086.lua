--鉄獣式強襲機動兵装改“BucephalusⅡ”
-- 效果：
-- 兽族·兽战士族·鸟兽族怪兽3只以上
-- 自己墓地的「铁兽」魔法·陷阱卡是2张以下的场合，这张卡不能从额外卡组特殊召唤。这个卡名的③的效果1回合只能使用1次。
-- ①：在自己对怪兽的特殊召唤成功时，对方不能把效果发动。
-- ②：自己或对方的怪兽的攻击宣言时才能发动。这张卡以及对方场上的卡全部除外。
-- ③：这张卡被送去墓地的场合才能发动。从额外卡组把1只兽族·兽战士族·鸟兽族怪兽送去墓地。
local s,id,o=GetID()
-- 效果注册：注册此卡的各项效果及召唤规则，包括连接召唤手续、特殊召唤限制、特殊召唤成功时的连锁限制效果、攻击宣言时的除外效果以及送去墓地时的额外卡组送墓效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续，并设置当从额外卡组特殊召唤时自己墓地的「铁兽」魔法·陷阱卡必须在3张以上的条件限制
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
-- 过滤函数：过滤出属于「铁兽」系列的魔法或陷阱卡
function s.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x14d)
end
-- 素材检查：检查自己墓地中是否存有至少3张「铁兽」魔法或陷阱卡
function s.spchk(g,lc,tp)
	-- 检查自己墓地中是否存有至少3张「铁兽」魔法或陷阱卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,3,nil)
end
-- 特殊召唤限制条件：若此卡在额外卡组以外的地方特殊召唤，或者自己墓地中存有至少3张「铁兽」魔法或陷阱卡时允许特殊召唤
function s.splimit(e,se,sp,st,pos,tp)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
		-- 检查自己墓地中是否存有至少3张「铁兽」魔法或陷阱卡
		or Duel.IsExistingMatchingCard(s.cfilter,sp,LOCATION_GRAVE,0,3,nil)
end
-- 发动条件：检查被特殊召唤的怪兽是否包含由自己特殊召唤的怪兽
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,e:GetHandler(),tp)
end
-- 效果处理：若此时不处于连锁中，则使对方不能连锁特殊召唤成功的效果；若处于连锁1，则为此卡注册标记以在连锁结束时应用限制
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前正在处理的连锁序号是否为0
	if Duel.GetCurrentChain()==0 then
		-- 设定连锁限制，直到当前连锁结束，对方在此期间不能把效果发动
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	-- 检查当前正在处理的连锁序号是否为1
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		-- ①：在自己对怪兽的特殊召唤成功时，对方不能把效果发动。②：自己或对方的怪兽的攻击宣言时才能发动。这张卡以及对方场上的卡全部除外。③：这张卡被送去墓地的场合才能发动。从额外卡组把1只兽族·兽战士族·鸟兽族怪兽送去墓地。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		-- 在玩家效果环境注册限制对方发动的效果，使对方不能发动效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 在玩家效果环境注册另一个限制对方发动的效果以响应打断等情况
		Duel.RegisterEffect(e2,tp)
	end
end
-- 重置效果函数：清除此卡的标记并重置当前连锁中的限制效果
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id)
	e:Reset()
end
-- 效果处理：在连锁结束时，若此卡带有相应标记，则限制对方在此连锁之后不能把效果发动，并重置此标记
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(id)~=0 then
		-- 设定连锁限制，直到当前连锁结束，对方在此期间不能把效果发动
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	e:GetHandler():ResetFlagEffect(id)
end
-- 连锁限制条件：只有该效果的发动者可以继续连锁发动效果
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- 效果目标：检查此卡能否除外，且对方场上是否存在可以除外的卡片，并设置除外卡片的连锁操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove()
		-- 检查对方场上是否存在至少1张可以除外的卡片
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的全部卡片以及此卡自身并放入卡片组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)+c
	-- 设置当前处理的连锁操作信息为将获取的卡片组全部除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- 效果处理：将此卡以及对方场上的所有卡片全部除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上的所有卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if c:IsRelateToEffect(e) then g:AddCard(c) end
	-- 以效果原因将获取的卡片组以表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
-- 过滤函数：过滤出额外卡组中属于兽族、兽战士族或鸟兽族的怪兽且可以送去墓地
function s.filter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsAbleToGrave()
end
-- 效果目标：检查额外卡组中是否存在符合送墓条件的怪兽，并设置送墓的连锁操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置当前处理的连锁操作信息为从额外卡组选择1只怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：从额外卡组选择1只符合条件的兽族、兽战士族或鸟兽族怪兽送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息以选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从额外卡组中选择1只属于兽族、兽战士族或鸟兽族的怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 以效果原因将选择的卡片送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
