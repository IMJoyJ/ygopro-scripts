--宝玉の加護
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己场上1张「宝玉兽」怪兽卡为对象才能发动。那张卡破坏。那之后，把持有那张卡的原本的种族·属性·等级·攻击力·守备力的1只「宝玉兽衍生物」在自己场上特殊召唤。
-- ②：这张卡在墓地存在，自己的魔法与陷阱区域有「宝玉兽」卡被放置的场合，把这张卡除外才能发动（伤害步骤也能发动）。选自己的魔法与陷阱区域1张「宝玉兽」怪兽卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（卡片发动）和②效果（墓地诱发效果）。
function s.initial_effect(c)
	-- ①：以自己场上1张「宝玉兽」怪兽卡为对象才能发动。那张卡破坏。那之后，把持有那张卡的原本的种族·属性·等级·攻击力·守备力的1只「宝玉兽衍生物」在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己的魔法与陷阱区域有「宝玉兽」卡被放置的场合，把这张卡除外才能发动（伤害步骤也能发动）。选自己的魔法与陷阱区域1张「宝玉兽」怪兽卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_MOVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(s.spcon)
	-- 设置发动Cost为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上满足“原本是怪兽的「宝玉兽」卡，且能腾出怪兽区域，并能以其原本数值特殊召唤衍生物”的卡片。
function s.filter(c,tp)
	-- 检查卡片是否为「宝玉兽」卡、原本类型是否为怪兽，且该卡离开场上后自己场上是否有可用的怪兽区域。
	return c:IsSetCard(0x1034) and c:GetOriginalType()&TYPE_MONSTER>0 and Duel.GetMZoneCount(tp,c)>0
		-- 检查玩家是否能以该卡原本的攻击力、守备力、等级、种族、属性特殊召唤「宝玉兽衍生物」。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0x1034,TYPES_TOKEN_MONSTER,c:GetBaseAttack(),c:GetBaseDefense(),c:GetOriginalLevel(),c:GetOriginalRace(),c:GetOriginalAttribute())
end
-- ①效果的发动准备与目标选择函数（Target）。
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.filter(chkc,tp) end
	-- 检查自己场上是否存在可以作为此效果对象的「宝玉兽」卡。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张符合条件的「宝玉兽」卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置连锁处理信息：破坏选中的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁处理信息：特殊召唤1只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
-- ①效果的实际处理函数（Operation）。
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍符合条件，则将其因效果破坏。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0
		-- 检查自己场上是否有可用的怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否仍能以被破坏卡的原本数值特殊召唤「宝玉兽衍生物」。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0x1034,TYPES_TOKEN_MONSTER,tc:GetBaseAttack(),tc:GetBaseDefense(),tc:GetOriginalLevel(),tc:GetOriginalRace(),tc:GetOriginalAttribute()) then
		-- 中断当前效果处理，使后续的特殊召唤与破坏不视为同时处理。
		Duel.BreakEffect()
		-- 在内存中创建「宝玉兽衍生物」卡片。
		local tk=Duel.CreateToken(tp,id+o)
		-- 持有那张卡的原本的种族·属性·等级·攻击力·守备力
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		tk:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		e2:SetValue(tc:GetBaseDefense())
		tk:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CHANGE_LEVEL)
		e3:SetValue(tc:GetOriginalLevel())
		tk:RegisterEffect(e3)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CHANGE_RACE)
		e4:SetValue(tc:GetOriginalRace())
		tk:RegisterEffect(e4)
		local e5=e1:Clone()
		e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e5:SetValue(tc:GetOriginalAttribute())
		tk:RegisterEffect(e5)
		-- 将创建的衍生物以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tk,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤放置在自己魔法与陷阱区域（非场地魔陷格）的表侧表示「宝玉兽」卡。
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsControler(tp) and c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5
end
-- ②效果的发动条件：自己的魔法与陷阱区域有「宝玉兽」卡被放置。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 过滤自己魔法与陷阱区域（非场地魔陷格）中，原本是怪兽且可以特殊召唤的表侧表示「宝玉兽」卡。
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:GetOriginalType()&TYPE_MONSTER>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetSequence()<5
end
-- ②效果的发动准备与可行性检查函数（Target）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔法与陷阱区域是否存在可以特殊召唤的「宝玉兽」怪兽卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp)
		-- 且自己场上必须有可用的怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置连锁处理信息：从魔法与陷阱区域特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
end
-- ②效果的实际处理函数（Operation）。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域，则不处理效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选自己魔法与陷阱区域1张符合条件的「宝玉兽」怪兽卡。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的卡特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
