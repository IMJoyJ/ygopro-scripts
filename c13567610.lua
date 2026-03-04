--無窮機竜カルノール
-- 效果：
-- 这张卡不能通常召唤。对方是这次决斗中有把手卡或墓地的怪兽的效果发动过的场合可以从手卡·墓地特殊召唤。自己对「无穷机龙 卡诺循环龙」1回合只能有1次特殊召唤。
-- ①：1回合1次，对方把怪兽的效果发动的场合才能发动。这张卡的攻击力上升1000。
-- ②：这张卡从手卡·卡组以外送去墓地的场合发动。这张卡回到卡组。
local s,id,o=GetID()
-- 初始化效果函数
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
	-- 特殊召唤规则：对方是这次决斗中有把手卡或墓地的怪兽的效果发动过的场合可以从手卡·墓地特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- 设置连锁计数器，用于记录对方怪兽效果发动次数
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
	-- 效果①：1回合1次，对方把怪兽的效果发动的场合才能发动。这张卡的攻击力上升1000
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.aucon)
	e2:SetTarget(s.autarget)
	e2:SetOperation(s.auop)
	c:RegisterEffect(e2)
	-- 效果②：这张卡从手卡·卡组以外送去墓地的场合发动。这张卡回到卡组
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.tdcon)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
-- 连锁过滤函数，用于判断是否满足特殊召唤条件
function s.chainfilter(re,tp,cid)
	-- 获取当前连锁的发动位置
	local loc=Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)
	if re:IsActiveType(TYPE_MONSTER) and loc&(LOCATION_HAND|LOCATION_GRAVE)>0 then
		-- 为对方注册标识效果，表示其已发动过怪兽效果
		Duel.RegisterFlagEffect(1-tp,id,0,0,0)
	end
	return not (re:IsActiveType(TYPE_MONSTER) and loc&(LOCATION_HAND|LOCATION_GRAVE)>0)
end
-- 特殊召唤条件函数
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查对方是否已发动过怪兽效果且场上存在召唤空间
	return Duel.GetFlagEffect(tp,id)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 效果①发动条件函数
function s.aucon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 效果①目标选择函数
function s.autarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return rp==1-tp end
end
-- 效果①处理函数
function s.auop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 使该卡攻击力上升1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 效果②发动条件函数
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local loc=e:GetHandler():GetPreviousLocation()
	return loc&(LOCATION_HAND|LOCATION_DECK)==0
end
-- 效果②目标选择函数
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，指定将该卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 效果②处理函数
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将该卡送回卡组并洗牌
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
