--超重武者ホラガ－E
-- 效果：
-- ①：自己墓地没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤成功的回合，自己不是「超重武者」怪兽不能特殊召唤。
-- ②：自己墓地没有魔法·陷阱卡存在，把这张卡解放对「超重武者」怪兽的上级召唤成功的场合才能发动。这张卡从墓地特殊召唤。
function c64373401.initial_effect(c)
	-- ①：自己墓地没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤成功的回合，自己不是「超重武者」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c64373401.hspcon)
	e1:SetOperation(c64373401.hspop)
	c:RegisterEffect(e1)
	-- ②：自己墓地没有魔法·陷阱卡存在，把这张卡解放对「超重武者」怪兽的上级召唤成功的场合才能发动。这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64373401,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(c64373401.spcon)
	e2:SetTarget(c64373401.sptg)
	e2:SetOperation(c64373401.spop)
	c:RegisterEffect(e2)
end
-- 过滤墓地中的魔法、陷阱卡
function c64373401.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 手卡特殊召唤规则的条件：怪兽区域有空位且自己墓地没有魔法·陷阱卡存在
function c64373401.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在魔法·陷阱卡
		and not Duel.IsExistingMatchingCard(c64373401.filter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 手卡特殊召唤成功时，注册一个直到回合结束前限制自己特殊召唤非「超重武者」怪兽的誓约效果
function c64373401.hspop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个方法特殊召唤成功的回合，自己不是「超重武者」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c64373401.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤非「超重武者」怪兽的限制效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤非「超重武者」怪兽
function c64373401.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x9a)
end
-- 效果②的发动条件：此卡在墓地，作为「超重武者」怪兽上级召唤的解放，且自己墓地没有魔法·陷阱卡存在
function c64373401.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_SUMMON and c:GetReasonCard():IsSetCard(0x9a)
		-- 检查自己墓地是否存在魔法·陷阱卡
		and not Duel.IsExistingMatchingCard(c64373401.filter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 效果②的发动准备：检查怪兽区域是否有空位，以及此卡是否可以特殊召唤
function c64373401.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息为“将自身特殊召唤”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：若此卡仍存在于墓地，则将其在自己场上表侧表示特殊召唤
function c64373401.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
