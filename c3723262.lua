--ウィザード＠イグニスター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从额外卡组特殊召唤的电子界族怪兽在自己场上存在的场合，以自己墓地1只电子界族·暗属性怪兽为对象才能发动。那只怪兽和手卡的这张卡守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
-- ②：把场上·墓地的这张卡除外，以对方场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
local s,id,o=GetID()
-- 定义卡片的初始化效果函数：创建并注册①效果（手牌起动，取对象自墓地和手卡特殊召唤）和②效果（场上/墓地起动，除外自身变更对方怪兽表示形式）。
function s.initial_effect(c)
	-- ①：从额外卡组特殊召唤的电子界族怪兽在自己场上存在的场合，以自己墓地1只电子界族·暗属性怪兽为对象才能发动。那只怪兽和手卡的这张卡守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把场上·墓地的这张卡除外，以对方场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动代价：将此卡从场上或墓地除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
-- 过滤条件：从额外卡组特殊召唤的、表侧表示的电子界族怪兽（用于①效果发动条件的检查）。
function s.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsFaceup()
		and c:IsRace(RACE_CYBERSE)
end
-- ①效果的发动条件：自己场上存在从额外卡组特殊召唤的电子界族怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足条件的电子界族怪兽，存在则①效果满足发动条件。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的对象过滤：墓地中暗属性·电子界族怪兽，且可以被守备表示特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果发动时的合法性与目标选择：确认不受‘青眼精灵龙’特殊召唤限制、自己有2个以上可用的怪兽区域、手牌此卡可守备表示特召，且墓地存在可选目标；之后选择目标。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 额外检查：自己的怪兽区域空闲格数需大于1，以便同时特殊召唤手牌此卡与墓地对象怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 额外检查：墓地存在1只满足spfilter条件的暗属性电子界族怪兽可作为效果对象。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家弹出选择提示，要求选择要特殊召唤的墓地怪兽（HINTMSG_SPSUMMON）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足spfilter条件的怪兽作为效果对象，同时自动建立与当前连锁的对象关联。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	g:AddCard(c)
	-- 设置连锁处理信息：本次效果预计特殊召唤2只怪兽（手牌此卡与墓地目标），用于后续的时点/限制检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- ①效果处理：确认此卡与目标仍与效果关联且合法后，将两者守备表示特殊召唤；随后给自己附加‘只能特殊召唤电子界族怪兽’的自肃。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果处理时第一个（也是唯一一个）效果对象，即墓地选择的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 处理时复核：此卡与目标仍和效果关联，且目标不受‘王家长眠之谷’效果影响（避免墓地除外替代等干扰）。
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 then
		local g=Group.FromCards(c,tc)
		-- 将手牌此卡和目标怪兽以表侧守备表示特殊召唤到自己的怪兽区域。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- ①效果的自肃部分：‘这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。’ 以及②效果：‘把场上·墓地的这张卡除外，以对方场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。’
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.splimit)
	-- 将‘非电子界族不能特殊召唤’的永续效果注册到场上，持续至结束阶段，作用于自己。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃的判定函数：若特殊召唤的怪兽不是电子界族则禁止特殊召唤。
function s.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE)
end
-- ②效果的对象过滤：选择对方场上可以变更表示形式的怪兽。
function s.posfilter(c)
	return c:IsCanChangePosition()
end
-- ②效果的发动合法性与目标选择：确认对方场上有可变更表示形式的怪兽后，选择1只作为效果对象。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少1只可以变更表示形式的怪兽，作为②效果发动的前提。
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家弹出选择提示，要求选择要变更表示形式的对方怪兽（HINTMSG_POSCHANGE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 从对方场上选择1只满足posfilter条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理信息：本次效果将变更1只怪兽的表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ②效果处理：取得对象，确认仍与效果关联后变更其表示形式。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽的表示形式在攻击表示和守备表示之间互相切换（攻击变守备，守备变攻击）。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
