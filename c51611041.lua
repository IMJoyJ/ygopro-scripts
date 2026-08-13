--模拘撮星人 エピゴネン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把自己场上1只效果怪兽解放才能发动。这张卡从手卡特殊召唤。那之后，把持有和解放的怪兽的原本的种族·属性相同种族·属性的1只「后继者衍生物」（1星·攻/守0）在自己场上特殊召唤。
function c51611041.initial_effect(c)
	-- 对应效果原文：『这个卡名的效果1回合只能使用1次。①：把自己场上1只效果怪兽解放才能发动。这张卡从手卡特殊召唤。那之后，把持有和解放的怪兽的原本的种族·属性相同种族·属性的1只「后继者衍生物」（1星·攻/守0）在自己场上特殊召唤。』
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,51611041)
	e1:SetCost(c51611041.spcost)
	e1:SetTarget(c51611041.sptg)
	e1:SetOperation(c51611041.spop)
	c:RegisterEffect(e1)
end
-- 筛选可解放的怪兽：必须是表侧表示的效果怪兽，且解放后我方怪兽区仍有至少2个可用区域，同时该怪兽的原本种族·属性能够用于特殊召唤「后继者衍生物」。
function c51611041.costfilter(c,tp)
	-- 判断解放对象为表侧表示的效果怪兽，且解放该怪兽后我方怪兽区仍有至少2个可用区域（用于特召此卡和衍生物）。
	return c:IsType(TYPE_EFFECT) and c:IsFaceup() and Duel.GetMZoneCount(tp,c)>=2
		-- 追加检查玩家能否把1只与解放怪兽原本种族·属性相同、卡号为51611042的「后继者衍生物」（1星·攻/守0）以衍生物形式特殊召唤到自己场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,51611042,0,TYPES_TOKEN_MONSTER,0,0,1,c:GetOriginalRace(),c:GetOriginalAttribute())
end
-- 代价处理函数：发动时从自己场上选择并解放1只满足条件的表侧效果怪兽作为发动代价，同时将该怪兽的原本种族和属性保存到效果e的标签中，供后续生成衍生物时使用。
function c51611041.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：确认自己场上是否存在至少1只可解放且满足costfilter条件的怪兽；若不存在则效果不能发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c51611041.costfilter,1,nil,tp) end
	-- 给玩家显示“请选择要解放的卡”的提示信息，要求选择用于解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从自己场上选择1只满足解放条件的怪兽，取得该卡对象。
	local rc=Duel.SelectReleaseGroup(tp,c51611041.costfilter,1,1,nil,tp):GetFirst()
	e:SetLabel(rc:GetOriginalRace(),rc:GetOriginalAttribute())
	-- 将选中的怪兽作为效果发动代价解放（REASON_COST，不因免疫效果而失败）。
	Duel.Release(rc,REASON_COST)
end
-- 效果发动前的目标合法性判定：确认此卡能够被特殊召唤，并且玩家本回合剩余的特殊召唤次数至少还有2次。
function c51611041.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断玩家本回合能否再进行2次特殊召唤（为之后特召此卡与衍生物各1次）。
		and Duel.IsPlayerCanSpecialSummonCount(tp,2) end
	-- 将“特殊召唤”登记到本连锁的操作信息，对象为这张卡，预计数量记2（本次效果包含此卡与衍生物共2次特殊召唤）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),2,0,0)
	-- 将“衍生物特殊召唤”登记到本连锁的操作信息，预定生成1只「后继者衍生物」。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
-- 效果处理：先尝试把此卡从手卡特殊召唤；成功后若场上仍有怪兽区空位且玩家能特召对应种族属性的衍生物，则中断效果，生成1只「后继者衍生物」，使其种族和属性变为与解放怪兽原本种族·属性相同，再将其特殊召唤。
function c51611041.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local race,attr=e:GetLabel()
	-- 判断此卡仍与发动效果相关，且此卡已成功从手卡表侧攻击表示特殊召唤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		-- 检查我方场上怪兽区是否还有至少1个可用区域，用于特召衍生物。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家能否将卡号51611042、1星·攻/守0、种族/属性与解放怪兽原本种族·属性相同的「后继者衍生物」特殊召唤。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,51611042,0,TYPES_TOKEN_MONSTER,0,0,1,race,attr) then
		-- 中断当前效果处理，使接下来衍生物的特殊召唤与之前此卡的特殊召唤视为不同时处理，避免错过时点。
		Duel.BreakEffect()
		-- 创建一只卡号为51611042的「后继者衍生物」Token，控制者为发动玩家。
		local token=Duel.CreateToken(tp,51611042)
		-- 对应效果原文：『持有和解放的怪兽的原本的种族·属性相同种族·属性的1只「后继者衍生物」』
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(race)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		token:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e2:SetValue(attr)
		token:RegisterEffect(e2)
		-- 将已设置好种族·属性的「后继者衍生物」Token以表侧攻击表示特殊召唤到发动玩家场上。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
