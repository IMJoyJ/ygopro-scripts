--ミラクル・フリッパー
-- 效果：
-- 「奇迹反转士」在自己场上存在的场合，这张卡不能召唤·反转召唤·特殊召唤。只要这张卡在场上表侧表示存在，对方不能选择其他的表侧表示的怪兽作为攻击对象。这张卡被战斗破坏的场合，这张卡在对方场上特殊召唤。这张卡被魔法·陷阱的效果破坏的场合，把对方场上1只怪兽破坏。
function c131182.initial_effect(c)
	-- 「奇迹反转士」在自己场上存在的场合，这张卡不能召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c131182.excon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	-- 「奇迹反转士」在自己场上存在的场合，这张卡不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(c131182.splimit)
	c:RegisterEffect(e3)
	-- 只要这张卡在场上表侧表示存在，对方不能选择其他的表侧表示的怪兽作为攻击对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetValue(c131182.atlimit)
	c:RegisterEffect(e4)
	-- 这张卡被战斗破坏的场合。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_BATTLE_DESTROYED)
	e5:SetOperation(c131182.battleop)
	c:RegisterEffect(e5)
	-- 这张卡被战斗破坏的场合，这张卡在对方场上特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(131182,0))  --"特殊召唤"
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetRange(0xff)
	e6:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e6:SetCountLimit(1)
	e6:SetCondition(c131182.spcon)
	e6:SetTarget(c131182.sptg)
	e6:SetOperation(c131182.spop)
	c:RegisterEffect(e6)
	-- 这张卡被魔法·陷阱的效果破坏的场合，把对方场上1只怪兽破坏。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(131182,1))  --"对方场上1只怪兽破坏"
	e7:SetCategory(CATEGORY_DESTROY)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_DESTROYED)
	e7:SetCondition(c131182.descon)
	e7:SetTarget(c131182.destg)
	e7:SetOperation(c131182.desop)
	c:RegisterEffect(e7)
end
-- 筛选场上表侧表示且卡名为「奇迹反转士」的卡，用于判断是否存在满足条件的同名卡。
function c131182.exfilter(c)
	return c:IsFaceup() and c:IsCode(131182)
end
-- 判断这张卡的控制者场上是否存在表侧表示的「奇迹反转士」，以此作为召唤限制的条件。
function c131182.excon(e)
	local c=e:GetHandler()
	-- 检查这张卡的控制者场上是否存在至少1张表侧表示的「奇迹反转士」。
	return Duel.IsExistingMatchingCard(c131182.exfilter,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end
-- 特殊召唤条件限制：若目标玩家（tgp）场上有表侧表示的「奇迹反转士」，则不允许将这张卡特殊召唤到该玩家场上。
function c131182.splimit(e,se,sp,st,spos,tgp)
	-- 检查目标玩家场上是否不存在表侧表示的「奇迹反转士」，若不存在则允许特殊召唤。
	return not Duel.IsExistingMatchingCard(c131182.exfilter,tgp,LOCATION_ONFIELD,0,1,nil)
end
-- 攻击对象限制判定：对方不能选择这张卡以外的表侧表示怪兽作为攻击对象，即只能攻击这张卡。
function c131182.atlimit(e,c)
	return c:IsFaceup() and c~=e:GetHandler()
end
-- 这张卡被战斗破坏时给自己打上131182标记，该标记保留到战斗阶段结束时重置，用于记录“被战斗破坏过”。
function c131182.battleop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(131182,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
-- 特殊召唤效果发动条件：检查这张卡是否有被战斗破坏的131182标记，有则允许在战斗阶段结束时发动特殊召唤。
function c131182.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(131182)~=0
end
-- 特殊召唤效果发动时处理：效果发动条件成立，并设置将这张卡特殊召唤的操作信息。
function c131182.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定本次连锁将特殊召唤的对象为这张卡本身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果处理：若这张卡仍与效果相关，则将其表侧表示特殊召唤到对方场上。
function c131182.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到对方（1-tp）的怪兽区。
		Duel.SpecialSummon(e:GetHandler(),0,tp,1-tp,false,false,POS_FACEUP)
	end
end
-- 判定破坏原因是否为魔法·陷阱卡的效果破坏：原因是效果且来源卡为魔法/陷阱时条件成立。
function c131182.descon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果发动时：选择对方场上1只怪兽作为对象，并设置破坏的操作信息。
function c131182.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 弹出“请选择要破坏的卡”的提示，供玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1只怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设定本次连锁将破坏已选择的对象组g中的卡，数量为g的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时，若之前选择的对象仍与效果相关，则将其破坏。
function c131182.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得连锁中第一张对象卡，即之前选择要破坏的对方怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
