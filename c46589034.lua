--RR－ペイン・レイニアス
-- 效果：
-- 这个卡名的效果1回合只能使用1次，把这张卡作为超量召唤的素材的场合，不是鸟兽族怪兽的超量召唤不能使用。
-- ①：这张卡在手卡存在的场合，以自己场上1只「急袭猛禽」怪兽为对象才能发动。自己受到那只怪兽的攻击力或守备力之内较低方数值的伤害，这张卡特殊召唤。这个效果特殊召唤的这张卡的等级变成和作为对象的怪兽的等级相同。
function c46589034.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，以自己场上1只「急袭猛禽」怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,46589034)
	e1:SetTarget(c46589034.sptg)
	e1:SetOperation(c46589034.spop)
	c:RegisterEffect(e1)
	-- 把这张卡作为超量召唤的素材的场合，不是鸟兽族怪兽的超量召唤不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e2:SetValue(c46589034.xyzlimit)
	c:RegisterEffect(e2)
end
-- 用于筛选满足条件的「急袭猛禽」怪兽，必须正面表示且等级、攻击力、守备力都大于等于1。
function c46589034.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xba) and c:IsLevelAbove(1) and c:IsAttackAbove(1) and c:IsDefenseAbove(1)
end
-- 检查是否满足发动条件：场上存在符合条件的目标怪兽、有空场、自身可特殊召唤、玩家未被效果免疫伤害。
function c46589034.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c46589034.cfilter(chkc) end
	-- 判断场上是否存在符合条件的「急袭猛禽」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c46589034.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断玩家场上是否有足够的怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断玩家是否受到“效果伤害变成0”的影响。
		and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_NO_EFFECT_DAMAGE) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择一个符合条件的「急袭猛禽」怪兽作为对象。
	local g=Duel.SelectTarget(tp,c46589034.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	local atk=tc:GetAttack()
	local def=tc:GetDefense()
	local val=math.min(atk,def)
	-- 设置操作信息：将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息：给予玩家伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,val)
end
-- 处理效果发动后的操作，包括判断目标是否有效、造成伤害、特殊召唤自身并改变等级。
function c46589034.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	local atk=tc:GetAttack()
	local def=tc:GetDefense()
	local val=math.min(atk,def)
	-- 对玩家造成伤害，并确认自身是否还在场上。
	if Duel.Damage(tp,val,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		-- 尝试将自身特殊召唤到场上。
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
			-- 设置效果：使特殊召唤的这张卡等级变为与对象怪兽相同。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(tc:GetLevel())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
		-- 完成特殊召唤流程。
		Duel.SpecialSummonComplete()
	end
end
-- 限制非鸟兽族怪兽不能作为此卡的超量素材。
function c46589034.xyzlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_WINDBEAST)
end
