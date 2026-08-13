--天威龍－サハスラーラ
-- 效果：
-- 幻龙族怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上有效果怪兽以外的表侧表示怪兽存在的场合，对方不能把场上的效果怪兽作为攻击对象，也不能作为效果的对象。
-- ②：以对方场上1只效果怪兽为对象才能发动。在自己场上把1只「天威龙衍生物」（幻龙族·光·4星·攻?/守0）特殊召唤。这衍生物的攻击力变成和作为对象的怪兽的原本攻击力相同。这个效果在对方回合也能发动。
function c38030232.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：以2～4只幻龙族怪兽为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_WYRM),2,4)
	-- ①：自己场上有效果怪兽以外的表侧表示怪兽存在的场合，对方不能把场上的效果怪兽作为攻击对象，也不能作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(c38030232.atcon)
	e1:SetValue(c38030232.attg)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c38030232.attg)
	-- 设置“不能成为效果对象”的效果值为aux.tgoval：使对方发动的效果不能以场上的表侧表示效果怪兽为对象（满足①条件时）。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：以对方场上1只效果怪兽为对象才能发动。在自己场上把1只「天威龙衍生物」（幻龙族·光·4星·攻?/守0）特殊召唤。这衍生物的攻击力变成和作为对象的怪兽的原本攻击力相同。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(38030232,0))
	e3:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,38030232)
	e3:SetTarget(c38030232.tktg)
	e3:SetOperation(c38030232.tkop)
	c:RegisterEffect(e3)
end
-- 过滤条件：判断怪兽是否为表侧表示且不是效果怪兽，即“效果怪兽以外的表侧表示怪兽”。
function c38030232.atfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_EFFECT)
end
-- ①效果的发动条件：这张卡的控制者自己场上存在至少1只表侧表示的效果怪兽以外的怪兽。
function c38030232.atcon(e)
	-- 实际检索/判定：以这张卡的控制者视角查看其怪兽区，存在至少1只满足atfilter的非效果表侧怪兽。
	return Duel.IsExistingMatchingCard(c38030232.atfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 用于效果的值/对象的过滤：判定对象怪兽是表侧表示的效果怪兽。
function c38030232.attg(e,c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- ②的取对象过滤：选择对方场上表侧表示的效果怪兽，同时确认玩家能够以该怪兽原本攻击力为攻击力生成并特殊召唤「天威龙衍生物」。
function c38030232.tkfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
		-- 检查玩家tp能否把参数为（卡号38030233、幻龙族、光、4星、攻击力为对象怪兽原本攻击力、守备力0）的衍生物特殊召唤到场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,38030233,0x12c,TYPES_TOKEN_MONSTER,c:GetBaseAttack(),0,4,RACE_WYRM,ATTRIBUTE_LIGHT)
end
-- ②的发动条件与取对象处理：若为选择对象时（chkc）则校验所选卡是否合法；若为发动时（chk==0）则确认自己怪兽区有空位且对方场上有可成为对象的表侧效果怪兽。
function c38030232.tktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c38030232.tkfilter(chkc,tp) end
	-- 发动合法性检查：自己场上的主要怪兽区存在空位，用于后续特殊召唤衍生物。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动合法性检查：对方怪兽区存在至少1张满足tkfilter且能被当前效果取为对象的表侧效果怪兽。
		and Duel.IsExistingTarget(c38030232.tkfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 从对方怪兽区选择1只满足tkfilter的表侧效果怪兽作为对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,c38030232.tkfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 登记操作信息：本次连锁包含衍生物生成（CATEGORY_TOKEN），预计生成1只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 登记操作信息：本次连锁包含特殊召唤（CATEGORY_SPECIAL_SUMMON），预计特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ②的解决处理：取得对象怪兽的原本攻击力；若对象怪兽已不关联或里侧表示则攻击力按0处理；在能特殊召唤的前提下生成「天威龙衍生物」并赋予其对应攻击力，然后特殊召唤。
function c38030232.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁中登记的对象卡（即②发动时选择的对方场上1只效果怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 处理时再次确认自己场上仍有可用的怪兽区；若无空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local atk=tc:GetBaseAttack()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then atk=0 end
	-- 再次检查玩家能否以计算出的atk为攻击力特殊召唤「天威龙衍生物」（卡号38030233，幻龙族·光·4星·守0）。
	if Duel.IsPlayerCanSpecialSummonMonster(tp,38030233,0x12c,TYPES_TOKEN_MONSTER,atk,0,4,RACE_WYRM,ATTRIBUTE_LIGHT) then
		-- 生成「天威龙衍生物」的Token（卡号38030233），但尚未放置到场上。
		local token=Duel.CreateToken(tp,38030233)
		-- 这衍生物的攻击力变成和作为对象的怪兽的原本攻击力相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		token:RegisterEffect(e1)
		-- 将生成的「天威龙衍生物」以表侧表示特殊召唤到tp自己场上（Token没有召唤条件与苏生限制，通常直接成功）。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
