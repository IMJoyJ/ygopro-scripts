--模拘撮星人 エピゴネン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把自己场上1只效果怪兽解放才能发动。这张卡从手卡特殊召唤。那之后，把持有和解放的怪兽的原本的种族·属性相同种族·属性的1只「后继者衍生物」（1星·攻/守0）在自己场上特殊召唤。
function c51611041.initial_effect(c)
	-- ①：把自己场上1只效果怪兽解放才能发动。这张卡从手卡特殊召唤。那之后，把持有和解放的怪兽的原本的种族·属性相同种族·属性的1只「后继者衍生物」（1星·攻/守0）在自己场上特殊召唤。
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
-- 检查场上是否满足解放条件的怪兽，包括必须是效果怪兽、正面表示、有足够怪兽区空间且可以特殊召唤衍生物
function c51611041.costfilter(c,tp)
	-- 确保所选怪兽为效果怪兽且正面表示，并且场上剩余怪兽区数量大于等于2
	return c:IsType(TYPE_EFFECT) and c:IsFaceup() and Duel.GetMZoneCount(tp,c)>=2
		-- 检查玩家是否可以特殊召唤指定编号的衍生物（后继者衍生物）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,51611042,0,TYPES_TOKEN_MONSTER,0,0,1,c:GetOriginalRace(),c:GetOriginalAttribute())
end
-- 解放满足条件的1只怪兽作为发动代价
function c51611041.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足解放条件，即是否存在符合条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c51611041.costfilter,1,nil,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从满足条件的卡中选择1张进行解放
	local rc=Duel.SelectReleaseGroup(tp,c51611041.costfilter,1,1,nil,tp):GetFirst()
	e:SetLabel(rc:GetOriginalRace(),rc:GetOriginalAttribute())
	-- 实际执行解放操作，并将该行为视为效果的代价
	Duel.Release(rc,REASON_COST)
end
-- 设置特殊召唤目标及数量，准备发动效果
function c51611041.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确保玩家可以进行2次特殊召唤（包括本体和衍生物）
		and Duel.IsPlayerCanSpecialSummonCount(tp,2) end
	-- 设置连锁操作信息：本次处理将特殊召唤本卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),2,0,0)
	-- 设置连锁操作信息：本次处理将特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
-- 执行效果处理流程，包括特殊召唤本体与衍生物
function c51611041.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local race,attr=e:GetLabel()
	-- 确认本卡存在于场上且成功特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		-- 确保玩家场上存在可用的怪兽区空间
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否可以特殊召唤指定编号的衍生物（后继者衍生物）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,51611042,0,TYPES_TOKEN_MONSTER,0,0,1,race,attr) then
		-- 中断当前效果处理，使后续操作不与当前效果同时处理
		Duel.BreakEffect()
		-- 创建一个指定编号的衍生物（后继者衍生物）
		local token=Duel.CreateToken(tp,51611042)
		-- 为衍生物设置种族属性，使其与被解放怪兽相同
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
		-- 将创建好的衍生物特殊召唤到场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
