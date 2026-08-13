--六花精スノードロップ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只植物族怪兽解放才能发动。这张卡和1只植物族怪兽从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是植物族怪兽不能特殊召唤。
-- ②：以自己场上1只植物族怪兽为对象才能发动。自己场上的全部植物族怪兽的等级直到回合结束时变成和作为对象的怪兽的等级相同。
function c33491462.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把自己场上1只植物族怪兽解放才能发动。这张卡和1只植物族怪兽从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是植物族怪兽不能特殊召唤。
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
-- 解放候选的过滤函数：该卡被解放后我方须仍有至少2个怪兽区可用；该卡须为可作为解放的植物族怪兽（自己场上的植物族怪兽，或受特定效果影响下可解放的对方表侧植物族怪兽）。
function c33491462.rfilter(c,tp)
	-- 判断解放候选卡c后，我方怪兽区是否仍有至少2个空位（用于特召此卡和另1只植物族），且c的控制者是我方或是表侧表示的怪兽。
	return Duel.GetMZoneCount(tp,c)>1 and (c:IsControler(tp) or c:IsFaceup())
		and (c:IsRace(RACE_PLANT) or c:IsHasEffect(76869711,tp) and c:IsControler(1-tp))
end
-- ①效果的代价函数：确认可解放1只符合条件的植物族怪兽，并选择解放它作为发动代价。
function c33491462.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段（chk==0），确认自己场上是否存在至少1只满足rfilter条件的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c33491462.rfilter,1,nil,tp) end
	-- 向操作者发送“请选择要解放的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 弹出选择界面，让玩家从自己场上选择1张满足rfilter条件的怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c33491462.rfilter,1,1,nil,tp)
	-- 将选中的怪兽以代价（REASON_COST）形式解放送墓。
	Duel.Release(g,REASON_COST)
end
-- 从手卡特殊召唤候选的过滤函数：必须是植物族怪兽，且能够被当前效果正常特殊召唤。
function c33491462.spfilter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件确认：玩家不受青眼精灵龙效果影响（不能同时特召2只以上）、此卡本身可被特殊召唤、且手卡存在至少1只可被特殊召唤的植物族怪兽。
function c33491462.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认手卡存在至少1只满足spfilter的植物族怪兽（排除此卡自身）可被特殊召唤，从而保证有1只可配合此卡从手卡特召。
		and Duel.IsExistingMatchingCard(c33491462.spfilter,tp,LOCATION_HAND,0,1,c,e,tp) end
	-- 登记操作信息：本效果将进行特殊召唤，预计从手卡特殊召唤2只怪兽（具体对象在效果处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
-- ①效果处理：在满足怪兽区空位>1、玩家不受青眼精灵龙影响、此卡仍与效果关联且可特召时，选择手卡1只植物族怪兽与此卡一起表侧表示特殊召唤。
function c33491462.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		-- 向操作者发送“请选择要特殊召唤的卡”的选择提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡选择1只满足spfilter的植物族怪兽作为特殊召唤对象（排除此卡自身）。
		local g=Duel.SelectMatchingCard(tp,c33491462.spfilter,tp,LOCATION_HAND,0,1,1,c,e,tp)
		if g:GetCount()>0 then
			g:AddCard(c)
			-- 将选择的手卡植物族怪兽与此卡一起以表侧表示特殊召唤到自己的怪兽区。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是植物族怪兽不能特殊召唤。②：以自己场上1只植物族怪兽为对象才能发动。自己场上的全部植物族怪兽的等级直到回合结束时变成和作为对象的怪兽的等级相同。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c33491462.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到玩家tp：直到回合结束时，自己不能特殊召唤非植物族怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃条件的判断函数：要特殊召唤的怪兽若不是植物族，则禁止特殊召唤。
function c33491462.splimit(e,c)
	return not c:IsRace(RACE_PLANT)
end
-- ②效果适用的植物族怪兽过滤条件：表侧表示且为植物族且等级≥1。
function c33491462.lvfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT) and c:IsLevelAbove(1)
end
-- ②效果对象的过滤函数：候选怪兽本身是表侧植物族且≥1级，并且自己场上还存在至少1只等级与它不同的其他植物族怪兽（否则改变等级无意义）。
function c33491462.lvfilter1(c,tp)
	-- 此返回语句确认候选怪兽满足基础植物族条件，且场上存在另一只等级不同的植物族怪兽，使等级变更效果有实际作用。
	return c33491462.lvfilter(c) and Duel.IsExistingMatchingCard(c33491462.lvfilter2,tp,LOCATION_MZONE,0,1,c,c:GetLevel())
end
-- 用于查找等级不等于指定等级lv的植物族怪兽，供lvfilter1判断是否存在需要变更等级的其他植物族怪兽。
function c33491462.lvfilter2(c,lv)
	return c33491462.lvfilter(c) and not c:IsLevel(lv)
end
-- ②效果的发动/选择对象阶段：确认存在满足条件的对象，然后让玩家选择1只植物族怪兽作为对象；chkc用于连锁中检查对象卡是否合法。
function c33491462.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c33491462.lvfilter1(chkc,tp) end
	-- 在发动合法性检查时，确认自己场上存在至少1只满足lvfilter1条件的植物族怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c33491462.lvfilter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向操作者发送“请选择效果的对象”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择自己场上1只满足lvfilter1条件的植物族怪兽，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,c33491462.lvfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- ②效果处理：取得对象怪兽的等级，并为我方场上所有满足条件的植物族怪兽赋予“等级变为该等级”的持续效果，直到回合结束；若对象已不合法则中止。
function c33491462.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象怪兽（即所选植物族怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	local lv=tc:GetLevel()
	-- 获取我方场上所有满足lvfilter条件的植物族怪兽（表侧、植物族、等级≥1），这些怪兽的等级都要被改变。
	local g=Duel.GetMatchingGroup(c33491462.lvfilter,tp,LOCATION_MZONE,0,nil)
	local lc=g:GetFirst()
	while lc do
		-- 自己场上的全部植物族怪兽的等级直到回合结束时变成和作为对象的怪兽的等级相同。
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
