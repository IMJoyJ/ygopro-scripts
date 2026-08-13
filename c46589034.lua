--RR－ペイン・レイニアス
-- 效果：
-- 这个卡名的效果1回合只能使用1次，把这张卡作为超量召唤的素材的场合，不是鸟兽族怪兽的超量召唤不能使用。
-- ①：这张卡在手卡存在的场合，以自己场上1只「急袭猛禽」怪兽为对象才能发动。自己受到那只怪兽的攻击力或守备力之内较低方数值的伤害，这张卡特殊召唤。这个效果特殊召唤的这张卡的等级变成和作为对象的怪兽的等级相同。
function c46589034.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在手卡存在的场合，以自己场上1只「急袭猛禽」怪兽为对象才能发动。自己受到那只怪兽的攻击力或守备力之内较低方数值的伤害，这张卡特殊召唤。这个效果特殊召唤的这张卡的等级变成和作为对象的怪兽的等级相同。
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
-- 过滤函数，用于筛选自己场上表侧表示的「急袭猛禽」怪兽，且其等级、攻击力、守备力均在1以上，以确保能取得对应数值。
function c46589034.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xba) and c:IsLevelAbove(1) and c:IsAttackAbove(1) and c:IsDefenseAbove(1)
end
-- 效果发动时的目标选择与合法性判定函数：检查是否存在满足条件的对象、自己主要怪兽区是否有空位、此卡能否从手牌特殊召唤，以及自己没有受到“效果伤害变成0”的效果影响。
function c46589034.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c46589034.cfilter(chkc) end
	-- 检测自己场上是否存在1只满足cfilter条件的「急袭猛禽」怪兽，作为可以选择的发动对象。
	if chk==0 then return Duel.IsExistingTarget(c46589034.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 确认自己主要怪兽区域存在可用的空格，以便之后特殊召唤此卡。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认自己没有受到“效果伤害变成0”的效果影响，因为此效果需要对自己造成伤害才能特殊召唤。
		and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_NO_EFFECT_DAMAGE) end
	-- 给玩家发出选择对象的提示消息，显示“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只满足条件的「急袭猛禽」怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c46589034.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	local atk=tc:GetAttack()
	local def=tc:GetDefense()
	local val=math.min(atk,def)
	-- 设置本次连锁的操作信息：将特殊召唤此卡的信息登记到连锁中，供后续时点和相关效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置本次连锁的操作信息：将对自己造成伤害的信息登记到连锁中，伤害数值为对象怪兽攻击力/守备力中的较低值。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,val)
end
-- 效果处理函数：取得对象怪兽并确认其仍为表侧表示且与效果关联，计算攻击力/守备力较低值并对自己造成伤害；伤害成功后且此卡仍与效果关联时，将此卡特殊召唤，并赋予其等级变成对象怪兽等级的效果。
function c46589034.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	local atk=tc:GetAttack()
	local def=tc:GetDefense()
	local val=math.min(atk,def)
	-- 对自己造成val点效果伤害；只有实际造成了伤害（没有被免除或变成0）且此卡仍与效果关联，才继续执行特殊召唤处理。
	if Duel.Damage(tp,val,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		-- 以表侧攻击表示将此卡作为特殊召唤的步骤进行召唤；成功后才赋予等级变化效果。
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的这张卡的等级变成和作为对象的怪兽的等级相同。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(tc:GetLevel())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
		-- 结束连续特殊召唤处理，正式完成此卡的特殊召唤。
		Duel.SpecialSummonComplete()
	end
end
-- 超量召唤素材限制的判定函数：如果作为超量素材的怪兽不是鸟兽族怪兽，则此卡不能作为超量素材（返回true表示不能作为素材）。
function c46589034.xyzlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_WINDBEAST)
end
