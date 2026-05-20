--A・ジェネクス・リバイバー
-- 效果：
-- ①：自己的卡的效果把对方的怪兽的效果·魔法·陷阱卡的发动无效的场合才能发动。这张卡从手卡特殊召唤。
function c63211608.initial_effect(c)
	-- 自己的卡的效果把对方的怪兽的效果·魔法·陷阱卡的发动无效的场合才能发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetOperation(c63211608.chop1)
	c:RegisterEffect(e1)
	-- 自己的卡的效果把对方的怪兽的效果·魔法·陷阱卡的发动无效的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_NEGATED)
	e2:SetRange(LOCATION_HAND)
	e2:SetOperation(c63211608.chop2)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
	-- ①：自己的卡的效果把对方的怪兽的效果·魔法·陷阱卡的发动无效的场合才能发动。这张卡从手卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(63211608,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c63211608.sumcon)
	e3:SetTarget(c63211608.sumtg)
	e3:SetOperation(c63211608.sumop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 在有新连锁发动时，将用于记录无效状态的标记重置为0
function c63211608.chop1(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
end
-- 当连锁发动被无效时，若被无效的是对方的发动且无效的原因是己方的卡的效果，则将标记设为1
function c63211608.chop2(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then return end
	-- 获取使该连锁发动无效的效果以及使该连锁发动无效的玩家
	local de,dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_REASON,CHAININFO_DISABLE_PLAYER)
	if dp==tp then
		e:SetLabel(1)
	end
end
-- 检查在当前连锁中是否发生了己方卡片效果将对方卡片发动无效的事件
function c63211608.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()~=0
end
-- 检查自身特殊召唤的可行性，并设置特殊召唤的操作信息
function c63211608.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的实际处理：若自身仍在手卡，则将自身正面表示特殊召唤
function c63211608.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡在自身场上正面表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
