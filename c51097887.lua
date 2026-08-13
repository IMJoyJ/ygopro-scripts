--鉄獣の凶襲
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只兽族·兽战士族·鸟兽族怪兽为对象才能发动。那只怪兽的攻击力以下而种族不同的1只兽族·兽战士族·鸟兽族怪兽从卡组守备表示特殊召唤。这个效果特殊召唤的怪兽的效果直到回合结束时无效化。这个效果的发动后，直到回合结束时自己不是连接怪兽不能从额外卡组特殊召唤。
function c51097887.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只兽族·兽战士族·鸟兽族怪兽为对象才能发动。那只怪兽的攻击力以下而种族不同的1只兽族·兽战士族·鸟兽族怪兽从卡组守备表示特殊召唤。这个效果特殊召唤的怪兽的效果直到回合结束时无效化。这个效果的发动后，直到回合结束时自己不是连接怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,51097887+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c51097887.sptg)
	e1:SetOperation(c51097887.spop)
	c:RegisterEffect(e1)
end
-- 定义对象怪兽的筛选条件：表侧表示且属于兽族·兽战士族·鸟兽族，并且卡组中存在符合条件的特殊召唤候选。
function c51097887.spfilter1(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
		-- 检查卡组中是否存在至少1只满足后续条件的兽族·兽战士族·鸟兽族怪兽（攻击力不高于对象、种族与对象不同、可守备表示特殊召唤）。
		and Duel.IsExistingMatchingCard(c51097887.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetAttack(),c:GetRace())
end
-- 定义从卡组特殊召唤的候选怪兽的筛选条件：属于兽族·兽战士族·鸟兽族，攻击力不高于对象怪兽，种族与对象怪兽不同，且可以被表侧守备表示特殊召唤。
function c51097887.spfilter2(c,e,tp,atk,race)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsAttackBelow(atk) and not c:IsRace(race)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- sptg函数的条件判断部分：当检查已选对象时，确认其合法；当进行发动确认时，检查自己有可用怪兽区且至少存在1只可选对象。
function c51097887.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c51097887.spfilter1(chkc,e,tp) end
	-- 检查自己场上是否存在可用的怪兽区域，确保特殊召唤有足够空格。
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		-- 检查自己场上是否存在至少1只满足对象筛选条件（表侧表示、种族正确、且关联卡组特召）的兽族·兽战士族·鸟兽族怪兽。
		and Duel.IsExistingTarget(c51097887.spfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 显示选择提示，提示玩家选择表侧表示的对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只符合条件的表侧表示怪兽，并将其登记为效果对象。
	Duel.SelectTarget(tp,c51097887.spfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：本效果将从卡组特殊召唤1只怪兽，供连锁处理或相关检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：取得对象并确认条件后，从卡组选择1只符合条件的怪兽以表侧守备表示特殊召唤；对特殊召唤的怪兽附加效果无效化；最后给发动者附加“非连接怪兽不能从额外卡组特殊召唤”的自肃。
function c51097887.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果相关、仍呈表侧表示，且自己场上仍有可用怪兽区域，满足后才继续处理特殊召唤。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 显示选择提示，提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组选择1只符合条件的兽族·兽战士族·鸟兽族怪兽（攻击力不高于对象、种族与对象不同、可表侧守备表示特殊召唤）。
		local g=Duel.SelectMatchingCard(tp,c51097887.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetAttack(),tc:GetRace())
		local tc=g:GetFirst()
		if tc then
			-- 将选择的怪兽以表侧守备表示进行特殊召唤（特殊召唤步骤）。
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			-- 这个效果特殊召唤的怪兽的效果直到回合结束时无效化。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			tc:RegisterEffect(e2)
			-- 完成特殊召唤的收尾处理，使所有特殊召唤步骤实际生效。
			Duel.SpecialSummonComplete()
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是连接怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c51097887.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到场上，作用于发动者，使其直到回合结束不能从额外卡组特殊召唤非连接怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 不能特殊召唤来自额外卡组且不是连接怪兽的怪兽。
function c51097887.splimit(e,c)
	return not c:IsType(TYPE_LINK) and c:IsLocation(LOCATION_EXTRA)
end
