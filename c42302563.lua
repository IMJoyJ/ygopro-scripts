--獄花の大燿聖ストリチア
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡只要在中央的主要怪兽区域存在，原本攻击力变成3000。
-- ②：自己·对方的主要阶段才能发动。从自己的手卡·墓地把1只6星以下的「耀圣」怪兽特殊召唤。那之后，可以让场上的全部4星以上的怪兽的等级直到回合结束时下降3星。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 定义卡片的初始化效果：登记同调召唤手续与苏生限制，注册①在中央主要怪兽区使原本攻击力变为3000的永续效果，以及注册②在主要阶段从手卡·墓地特殊召唤「耀圣」怪兽、可选降星并附加额外卡组自肃的诱发即时效果。
function s.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整怪兽和1只以上调整以外的怪兽作为同调素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡只要在中央的主要怪兽区域存在，原本攻击力变成3000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetCondition(s.atkcon)
	e1:SetValue(3000)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己·对方的主要阶段才能发动。从自己的手卡·墓地把1只6星以下的「耀圣」怪兽特殊召唤。那之后，可以让场上的全部4星以上的怪兽的等级直到回合结束时下降3星。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的适用条件：判定这张卡是否位于中央的主要怪兽区域（主怪兽区第3格），只有在该位置时攻击力变化效果适用。
function s.atkcon(e)
	return e:GetHandler():GetSequence()==2
end
-- ②效果的发动条件：当前处于主要阶段（自己或对方的主要阶段均可发动）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段，以实现“自己·对方的主要阶段才能发动”的发动时机限制。
	return Duel.IsMainPhase()
end
-- 定义可特殊召唤的怪兽条件：必须是「耀圣」系列且等级6星以下，并且能够被当前效果特殊召唤（满足苏生限制等）。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1d8) and c:IsLevelBelow(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动时目标选择与合法性判定：确认自己场上有空位，且手卡·墓地存在符合条件的「耀圣」怪兽；若满足，则登记后续将进行特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）首先检查自己场上是否有可用的主要怪兽区域空位，作为能否发动效果的必要条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动时还须确认手卡·墓地至少存在1只满足s.spfilter条件的「耀圣」怪兽，作为能否发动效果的必要条件。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向决斗系统登记本次效果将进行1次从手卡·墓地进行的特殊召唤，便于其他卡（如星尘龙、王家长眠之谷等）进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 定义降星对象：场上表侧表示且等级为4星以上的怪兽。
function s.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(4)
end
-- ②效果处理中执行特殊召唤的部分：选1只符合条件的「耀圣」怪兽特殊召唤；若特殊召唤成功，则询问玩家是否让场上全部4星以上怪兽等级下降3；若选择是，则对这些怪兽施加等级-3的效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时再次确认自己场上仍有可用主要怪兽区域，防止因连锁导致空位发生变化。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 显示选择提示信息，引导玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡·墓地选择1只满足s.spfilter且不受王家长眠之谷影响的「耀圣」怪兽作为特殊召唤对象。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 将选择的怪兽表侧表示特殊召唤到自己场上，并判定是否特殊召唤成功；成功后才进行后续降星处理。
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 立即刷新场地状态，使刚特殊召唤的怪兽及场上信息更新，保证后续等级筛选和效果处理准确。
			Duel.AdjustAll()
			-- 检查双方场上是否存在表侧表示且4星以上的怪兽，若存在则询问玩家是否执行降星。
			if Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
				-- 向玩家弹出是/否选择，确认是否发动“那之后”的降星效果；选择是才执行降星。
				and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否下降等级？"
				-- 中断当前效果处理，使降星处理变为独立结算（避免与特殊召唤视为同一时点，造成错时点）。
				Duel.BreakEffect()
				-- 取得双方场上全部表侧表示且等级4星以上的怪兽作为降星对象组。
				local lg=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
				-- 遍历降星对象组，对其中每只怪兽逐一施加等级下降效果。
				for lc in aux.Next(lg) do
					-- 那之后，可以让场上的全部4星以上的怪兽的等级直到回合结束时下降3星。
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_UPDATE_LEVEL)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					e1:SetValue(-3)
					lc:RegisterEffect(e1)
				end
			end
		end
	end
	-- 这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将额外卡组特殊召唤自肃效果注册到当前玩家tp，使其在本回合结束前不能从额外卡组特殊召唤非同步怪兽。
	Duel.RegisterEffect(e2,tp)
end
-- 自肃效果的过滤条件：从额外卡组进行特殊召唤的怪兽若不是同步怪兽，则禁止该特殊召唤。
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
