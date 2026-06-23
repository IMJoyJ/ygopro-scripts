--六花精スノードロップ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只植物族怪兽解放才能发动。这张卡和1只植物族怪兽从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是植物族怪兽不能特殊召唤。
-- ②：以自己场上1只植物族怪兽为对象才能发动。自己场上的全部植物族怪兽的等级直到回合结束时变成和作为对象的怪兽的等级相同。
function c33491462.initial_effect(c)
	-- ①：把自己场上1只植物族怪兽解放才能发动。这张卡和1只植物族怪兽从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是植物族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33491462,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,33491462)
	e1:SetCost(c33491462.spcost)
	e1:SetTarget(c33491462.sptg)
	e1:SetOperation(c33491462.spop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只植物族怪兽为对象才能发动。自己场上的全部植物族怪兽的等级直到回合结束时变成和作为对象的怪兽的等级相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33491462,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,33491463)
	e2:SetTarget(c33491462.lvtg)
	e2:SetOperation(c33491462.lvop)
	c:RegisterEffect(e2)
end
-- 用于判断是否可以解放的过滤函数，检查目标怪兽是否满足解放条件（包括是否在场上、是否为植物族或拥有特定效果且控制权在对方）
function c33491462.rfilter(c,tp)
	-- 检查目标怪兽是否满足解放条件（是否在场上、是否为植物族或拥有特定效果且控制权在对方）
	return Duel.GetMZoneCount(tp,c)>1 and (c:IsControler(tp) or c:IsFaceup())
		and (c:IsRace(RACE_PLANT) or c:IsHasEffect(76869711,tp) and c:IsControler(1-tp))
end
-- 效果发动时的费用处理，检查是否可以解放满足条件的怪兽
function c33491462.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以解放满足条件的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c33491462.rfilter,1,nil,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c33491462.rfilter,1,1,nil,tp)
	-- 执行解放操作
	Duel.Release(g,REASON_COST)
end
-- 用于判断手牌中是否有满足条件的植物族怪兽可以特殊召唤
function c33491462.spfilter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理，检查是否满足发动条件（包括是否受青眼精灵龙影响、是否可以特殊召唤、手牌中是否有植物族怪兽）
function c33491462.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查手牌中是否存在满足条件的植物族怪兽
		and Duel.IsExistingMatchingCard(c33491462.spfilter,tp,LOCATION_HAND,0,1,c,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤2张卡（自己和1只植物族怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
-- 效果发动时的处理，检查是否满足发动条件（包括是否受青眼精灵龙影响、是否可以特殊召唤、手牌中是否有植物族怪兽）
function c33491462.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的植物族怪兽进行特殊召唤
		local g=Duel.SelectMatchingCard(tp,c33491462.spfilter,tp,LOCATION_HAND,0,1,1,c,e,tp)
		if g:GetCount()>0 then
			g:AddCard(c)
			-- 将选中的卡特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- ①：把自己场上1只植物族怪兽解放才能发动。这张卡和1只植物族怪兽从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是植物族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c33491462.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册一个永续效果，使自己不能特殊召唤非植物族怪兽
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数，禁止召唤非植物族怪兽
function c33491462.splimit(e,c)
	return not c:IsRace(RACE_PLANT)
end
-- 用于判断是否为植物族且正面表示的怪兽
function c33491462.lvfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT) and c:IsLevelAbove(1)
end
-- 用于判断是否为植物族且正面表示的怪兽，并且场上存在其他等级不同的植物族怪兽
function c33491462.lvfilter1(c,tp)
	-- 检查场上是否存在其他等级不同的植物族怪兽
	return c33491462.lvfilter(c) and Duel.IsExistingMatchingCard(c33491462.lvfilter2,tp,LOCATION_MZONE,0,1,c,c:GetLevel())
end
-- 用于判断是否为植物族且正面表示的怪兽，并且等级与指定等级不同
function c33491462.lvfilter2(c,lv)
	return c33491462.lvfilter(c) and not c:IsLevel(lv)
end
-- 效果发动时的处理，检查是否满足发动条件（是否可以选取目标怪兽）
function c33491462.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c33491462.lvfilter1(chkc,tp) end
	-- 检查是否可以选取目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c33491462.lvfilter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c33491462.lvfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 效果发动时的处理，将目标怪兽的等级应用到所有场上植物族怪兽
function c33491462.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	local lv=tc:GetLevel()
	-- 获取场上所有满足条件的植物族怪兽
	local g=Duel.GetMatchingGroup(c33491462.lvfilter,tp,LOCATION_MZONE,0,nil)
	local lc=g:GetFirst()
	while lc do
		-- 为每个目标怪兽设置等级变化效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		lc:RegisterEffect(e1)
		lc=g:GetNext()
	end
end
