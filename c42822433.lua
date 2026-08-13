--星騎士 アルテア
-- 效果：
-- 这个卡名在规则上也当作「星圣」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤的场合，以最多有自己场上的光·暗属性超量怪兽数量的场上的卡为对象才能发动。那些卡破坏。
-- ②：自己场上有「星骑士 牛郎星」以外的「星骑士」、「星圣」怪兽特殊召唤的场合才能发动。这张卡从墓地特殊召唤。这个回合，自己不用超量怪兽不能攻击宣言。
function c42822433.initial_effect(c)
	-- 这个卡名在规则上也当作「星圣」卡使用。这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·反转召唤·特殊召唤的场合，以最多有自己场上的光·暗属性超量怪兽数量的场上的卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,42822433)
	e1:SetTarget(c42822433.destg)
	e1:SetOperation(c42822433.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	c42822433.star_knight_summon_effect=e1
	-- ②：自己场上有「星骑士 牛郎星」以外的「星骑士」、「星圣」怪兽特殊召唤的场合才能发动。这张卡从墓地特殊召唤。这个回合，自己不用超量怪兽不能攻击宣言。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,42822434)
	e4:SetCondition(c42822433.spcon)
	e4:SetTarget(c42822433.sptg)
	e4:SetOperation(c42822433.spop)
	c:RegisterEffect(e4)
end
-- 判断卡是否为表侧表示且属性为光属性或暗属性，且种族为超量怪兽，用于统计自己场上的光·暗属性超量怪兽数量。
function c42822433.ckfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsType(TYPE_XYZ)
end
-- 效果①的发动条件与取对象处理：统计自己场上的光·暗属性超量怪兽数量作为可选对象数量上限；若场上存在可被破坏的卡且数量上限大于0则满足发动条件，然后由玩家选择1至上限数量的场上卡牌，并设置破坏效果的操作信息。
function c42822433.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 统计自己场上表侧表示的光、暗属性超量怪兽数量，作为此效果可选取对象的数量上限。
	local ct=Duel.GetMatchingGroupCount(c42822433.ckfilter,tp,LOCATION_MZONE,0,nil)
	if chkc then return chkc:IsOnField() end
	-- 在效果发动阶段（chk==0）检查：若自己场上有光·暗属性超量怪兽且场上存在1张以上的卡可作为对象，则允许发动。
	if chk==0 then return ct>0 and Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 弹出选择提示，提示文案为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1到ct张卡作为效果对象（ct为光·暗超量怪兽数量上限），并将所选卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	-- 设置本连锁处理中将要进行的破坏操作信息，对象为选中的g，数量为g的卡数，类别为破坏，以便其他卡（如星尘龙）响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 效果①的实际处理：取得处理时仍与自己有联系的对象卡，若对象不空则将这些卡全部破坏。
function c42822433.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象中，在当前处理时仍与该连锁相关的卡组（若对象离开场上或变成里侧等则不再包含）。
	local g=Duel.GetTargetsRelateToChain()
	if #g==0 then return end
	-- 以效果原因将选中的对象卡破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 判断卡是否是表侧表示且为自己控制的卡，且卡名不是“星骑士 牛郎星”本身，但属于“星骑士”或“星圣”系列；用于②的触发条件中检测是否存在满足条件的其他怪兽被特殊召唤。
function c42822433.cfilter(c,tp)
	return not c:IsCode(42822433) and c:IsFaceup() and c:IsControler(tp)
		and c:IsSetCard(0x9c,0x53)
end
-- ②的诱发条件：当这次特殊召唤成功的怪兽组中存在至少1张满足cfilter条件的卡（即除本卡以外的表侧表示、控制权为已方、属于星骑士或星圣系列的怪兽），则满足发动条件。
function c42822433.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c42822433.cfilter,1,nil,tp)
end
-- ②的发动条件与目标设定：确认自己场上有空余的怪兽区，且墓地的这张卡可以被特殊召唤；满足则设置发动操作信息为特殊召唤本卡。
function c42822433.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段（chk==0）检查自己场上是否有空余的怪兽区，作为从墓地特殊召唤的前提。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本连锁处理的特殊召唤操作信息，特殊召唤的对象为这张卡（当前墓地中的效果持有者），数量为1，供其他卡响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②的处理：若这张卡仍与效果相关，则将其从墓地以表侧表示特殊召唤；随后对自己场上的非超量怪兽赋予不能攻击宣言的限制效果，持续到回合结束。
function c42822433.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将墓地中的这张卡以表侧攻击表示特殊召唤到自己场上（不检查苏生限制，无特殊召唤方式）。返回值是成功召唤的数量。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己不用超量怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c42822433.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将刚创建的攻击限制效果注册给当前玩家（tp），使该效果在本回合内适用于其场上的怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 攻击限制效果的自定义目标判定：若怪兽不是超量怪兽则受此效果影响，即不能进行攻击宣言；超量怪兽不受限制。
function c42822433.atktg(e,c)
	return not c:IsType(TYPE_XYZ)
end
