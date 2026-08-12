--天威龍－サハスラーラ
-- 效果：
-- 幻龙族怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上有效果怪兽以外的表侧表示怪兽存在的场合，对方不能把场上的效果怪兽作为攻击对象，也不能作为效果的对象。
-- ②：以对方场上1只效果怪兽为对象才能发动。在自己场上把1只「天威龙衍生物」（幻龙族·光·4星·攻?/守0）特殊召唤。这衍生物的攻击力变成和作为对象的怪兽的原本攻击力相同。这个效果在对方回合也能发动。
function c38030232.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用2到4个幻龙族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_WYRM),2,4)
	-- 自己场上有效果怪兽以外的表侧表示怪兽存在的场合，对方不能把场上的效果怪兽作为攻击对象，也不能作为效果的对象
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
	-- 设置效果值为aux.tgoval函数，用于判断是否能成为对方效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 以对方场上1只效果怪兽为对象才能发动。在自己场上把1只「天威龙衍生物」（幻龙族·光·4星·攻?/守0）特殊召唤。这衍生物的攻击力变成和作为对象的怪兽的原本攻击力相同。这个效果在对方回合也能发动
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
-- 过滤函数，用于判断是否为表侧表示且不是效果怪兽的怪兽
function c38030232.atfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_EFFECT)
end
-- 条件函数，用于判断自己场上是否存在表侧表示且不是效果怪兽的怪兽
function c38030232.atcon(e)
	-- 检查自己场上是否存在至少1只表侧表示且不是效果怪兽的怪兽
	return Duel.IsExistingMatchingCard(c38030232.atfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于判断是否为表侧表示且是效果怪兽的怪兽
function c38030232.attg(e,c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 过滤函数，用于判断是否为表侧表示且是效果怪兽，并且玩家可以特殊召唤指定的衍生物
function c38030232.tkfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
		-- 检查玩家是否可以特殊召唤指定的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,38030233,0x12c,TYPES_TOKEN_MONSTER,c:GetBaseAttack(),0,4,RACE_WYRM,ATTRIBUTE_LIGHT)
end
-- 设置连锁处理的条件，检查玩家场上是否有空位并存在符合条件的目标怪兽
function c38030232.tktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c38030232.tkfilter(chkc,tp) end
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在符合条件的目标怪兽
		and Duel.IsExistingTarget(c38030232.tkfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 选择符合条件的目标怪兽
	Duel.SelectTarget(tp,c38030232.tkfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置操作信息，表示将特殊召唤1个衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息，表示将特殊召唤1个衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理函数，用于执行特殊召唤衍生物并设置其攻击力
function c38030232.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查玩家场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local atk=tc:GetBaseAttack()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then atk=0 end
	-- 检查玩家是否可以特殊召唤指定的衍生物
	if Duel.IsPlayerCanSpecialSummonMonster(tp,38030233,0x12c,TYPES_TOKEN_MONSTER,atk,0,4,RACE_WYRM,ATTRIBUTE_LIGHT) then
		-- 创建指定编号的衍生物
		local token=Duel.CreateToken(tp,38030233)
		-- 为衍生物设置攻击力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		token:RegisterEffect(e1)
		-- 将衍生物特殊召唤到场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
