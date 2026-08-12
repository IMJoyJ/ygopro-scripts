--スフィンクス・アンドロジュネス
-- 效果：
-- 这张卡不能通常召唤。自己场上的「斯芬克斯·安德鲁」和「斯芬克斯·迪蕾雅」同时被破坏时，支付500基本分才能从手卡或者卡组特殊召唤。这张卡特殊召唤成功时，可以支付500基本分，直到结束阶段结束时这张卡的攻击力上升3000。
function c87997872.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己场上的「斯芬克斯·安德鲁」和「斯芬克斯·迪蕾雅」同时被破坏时，支付500基本分才能从手卡或者卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87997872,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_HAND+LOCATION_DECK)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c87997872.spcon)
	e2:SetCost(c87997872.cost)
	e2:SetTarget(c87997872.sptg)
	e2:SetOperation(c87997872.spop)
	c:RegisterEffect(e2)
	-- 这张卡特殊召唤成功时，可以支付500基本分，直到结束阶段结束时这张卡的攻击力上升3000。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(87997872,1))  --"攻击上升"
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCost(c87997872.cost)
	e4:SetOperation(c87997872.atkop)
	c:RegisterEffect(e4)
end
-- 过滤条件：检查卡片是否是指定卡号、由自己控制且因破坏而离场
function c87997872.cfilter(c,tp,code)
	return c:IsCode(code) and c:IsPreviousControler(tp) and c:IsReason(REASON_DESTROY)
end
-- 特殊召唤效果的发动条件：自己场上的「斯芬克斯·安德鲁」和「斯芬克斯·迪蕾雅」同时被破坏
function c87997872.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c87997872.cfilter,1,nil,tp,15013468)
		and eg:IsExists(c87997872.cfilter,1,nil,tp,51402177)
end
-- 支付500基本分的发动代价（Cost）函数
function c87997872.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 扣除玩家500基本分
	Duel.PayLPCost(tp,500)
end
-- 特殊召唤效果的发动准备（Target）函数，检查怪兽区域是否有空位以及自身是否能特殊召唤
function c87997872.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) end
	if c:IsLocation(LOCATION_DECK) then
		-- 如果此卡在卡组中，则向对方玩家展示并确认这张卡
		Duel.ConfirmCards(1-tp,c)
	end
	-- 设置当前处理的连锁的操作信息，表示该效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,c:GetLocation())
end
-- 特殊召唤效果的处理（Operation）函数，将自身特殊召唤并完成正规召唤程序
function c87997872.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将自身以表侧表示特殊召唤，并判断是否特殊召唤成功
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- 攻击力上升效果的处理（Operation）函数，使自身攻击力上升3000点直到结束阶段
function c87997872.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 直到结束阶段结束时这张卡的攻击力上升3000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(3000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
