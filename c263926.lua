--独法師
-- 效果：
-- 自己场上有怪兽存在的场合，这张卡不能召唤·特殊召唤。
-- ①：这张卡可以从手卡攻击表示特殊召唤。
-- ②：这张卡已在怪兽区域存在的状态，自己场上有这张卡以外的怪兽召唤·反转召唤·特殊召唤的场合发动。这张卡破坏。
function c263926.initial_effect(c)
	-- 自己场上有怪兽存在的场合，这张卡不能召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c263926.sumcon)
	c:RegisterEffect(e1)
	-- 自己场上有怪兽存在的场合，这张卡不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(c263926.sumlimit)
	c:RegisterEffect(e2)
	-- ①：这张卡可以从手卡攻击表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_SPSUM_PARAM+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetTargetRange(POS_FACEUP_ATTACK,0)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c263926.sprcon)
	c:RegisterEffect(e3)
	-- ②：这张卡已在怪兽区域存在的状态，自己场上有这张卡以外的怪兽召唤·反转召唤·特殊召唤的场合发动。这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(263926,0))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c263926.descon)
	e4:SetTarget(c263926.destg)
	e4:SetOperation(c263926.desop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e6)
end
-- 作为“不能召唤”效果的条件，检查这张卡的控制者场上是否存在怪兽；若有怪兽则不能召唤。
function c263926.sumcon(e)
	-- 检查这张卡的控制者自己场上主要怪兽区是否有怪兽存在（数量>0）。
	return Duel.GetFieldGroupCount(e:GetHandler():GetControler(),LOCATION_MZONE,0)>0
end
-- 作为“不能特殊召唤”限制的条件，检查尝试特殊召唤的玩家场上是否有怪兽，若没有怪兽则允许特殊召唤。
function c263926.sumlimit(e,se,sp,st,pos,tp)
	-- 检查sp（尝试特殊召唤的玩家）自己场上主要怪兽区的怪兽数量是否为0（即没有怪兽）。
	return Duel.GetFieldGroupCount(sp,LOCATION_MZONE,0)==0
end
-- 作为“从手卡攻击表示特殊召唤”的规则特殊召唤手续的条件：自己场上没有怪兽，且主要怪兽区有空位。
function c263926.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查tp（这张卡的控制者）自己场上主要怪兽区的怪兽数量是否为0（即自己场上没有怪兽）。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 同时检查tp的主要怪兽区可用空格数大于0（即可特殊召唤的区域存在）。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 作为②效果的条件，检查本次召唤的怪兽中有没有自己场上的这张卡以外的怪兽（即eg中存在控制者为tp的怪兽且不包含此卡）。
function c263926.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- ②效果的发动目标设定：若此卡不在连锁串中则可发动，并将效果处理时破坏的对象设置为这张卡自身。
function c263926.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) end
	-- 将本次连锁的操作信息登记为“破坏”分类，对象为这张卡自身，数量为1，以用于效果处理时确定操作内容。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与效果关联，则将其破坏。
function c263926.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以效果原因破坏这张卡。
		Duel.Destroy(c,REASON_EFFECT)
	end
end
