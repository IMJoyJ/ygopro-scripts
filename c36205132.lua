--空牙団の伝令 フィロ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡把「空牙团的传令 菲勒」以外的1只「空牙团」怪兽特殊召唤。
-- ②：这张卡已在怪兽区域存在的状态，自己场上有这张卡以外的「空牙团」怪兽特殊召唤的场合，以自己墓地1只「空牙团」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合回到持有者卡组最下面。
function c36205132.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己主要阶段才能发动。从手卡把「空牙团的传令 菲勒」以外的1只「空牙团」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36205132,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,36205132)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c36205132.sptg)
	e1:SetOperation(c36205132.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡已在怪兽区域存在的状态，自己场上有这张卡以外的「空牙团」怪兽特殊召唤的场合，以自己墓地1只「空牙团」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合回到持有者卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36205132,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,36205133)
	e2:SetCondition(c36205132.spcon2)
	e2:SetTarget(c36205132.sptg2)
	e2:SetOperation(c36205132.spop2)
	c:RegisterEffect(e2)
end
-- 定义筛选函数：选择持有「空牙团」字段、卡名不是「空牙团的传令 菲勒」且可以被当前效果特殊召唤的怪兽。
function c36205132.spfilter(c,e,tp)
	return c:IsSetCard(0x114) and not c:IsCode(36205132) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动条件判断：当为发动确认时，要求自己主要怪兽区有空位，且手牌中存在满足spfilter条件的「空牙团」怪兽。
function c36205132.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用空格，作为效果①的发动条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌是否存在至少1只满足spfilter条件的「空牙团」怪兽（且不是「空牙团的传令 菲勒」），作为效果①的发动条件之一。
		and Duel.IsExistingMatchingCard(c36205132.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，声明本次效果处理为从手牌特殊召唤1只怪兽，供连锁和时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的处理：若主要怪兽区无空位则中止；否则提示玩家从手牌选择1只满足条件的「空牙团」怪兽，并将其以表侧攻击表示特殊召唤到己方场上。
function c36205132.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己主要怪兽区仍有空格，若没有则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示消息，提示玩家从手牌选择要特殊召唤的「空牙团」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手牌中选出1只满足spfilter条件的「空牙团」怪兽。
	local g=Duel.SelectMatchingCard(tp,c36205132.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的那只怪兽以表侧攻击表示特殊召唤到己方主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义筛选函数：判定怪兽是否为表侧表示、持有「空牙团」字段且由己方控制，用于检测“自己场上有这张卡以外的「空牙团」怪兽特殊召唤”的诱发条件。
function c36205132.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x114) and c:IsControler(tp)
end
-- 效果②的诱发条件判断：本次特殊召唤成功的怪兽中不包含本卡，且存在至少1只是由己方控制的表侧表示「空牙团」怪兽。
function c36205132.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c36205132.cfilter,1,nil,tp)
end
-- 定义墓地对象的筛选函数：墓地中持有「空牙团」字段，且可以以表侧守备表示特殊召唤的怪兽。
function c36205132.spfilter2(c,e,tp)
	return c:IsSetCard(0x114) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的发动时点与取对象处理：取对象时确认对象位于自己墓地且满足spfilter2；发动确认时要求自己主要怪兽区有空位且墓地存在满足条件的「空牙团」怪兽，之后选择对象并设置操作信息。
function c36205132.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c36205132.spfilter2(chkc,e,tp) end
	-- 检查自己主要怪兽区是否有空位，作为效果②能发动的条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足spfilter2且能被取为对象的「空牙团」怪兽，作为效果②的发动条件之一。
		and Duel.IsExistingTarget(c36205132.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示消息，提示玩家从墓地选择要特殊召唤的「空牙团」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己墓地选择1只满足spfilter2条件的「空牙团」怪兽为对象，并自动与本次效果建立联系。
	local g=Duel.SelectTarget(tp,c36205132.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，声明将以特殊召唤这1只对象怪兽的方式处理，供连锁和时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的处理：取得对象怪兽，若对象仍与效果有关联则将其以表侧守备表示特殊召唤，并给那只怪兽附加“离场时回到持有者卡组最下面”的效果；最后完成特殊召唤处理。
function c36205132.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果②发动时选择的墓地对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽是否仍与效果有关联，若是则将其以表侧守备表示特殊召唤，作为连续特殊召唤的一步。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个效果特殊召唤的怪兽从场上离开的场合回到持有者卡组最下面。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECKBOT)
		tc:RegisterEffect(e1)
	end
	-- 完成连续特殊召唤处理，正式将之前通过SpecialSummonStep特殊召唤的怪兽特殊召唤成功。
	Duel.SpecialSummonComplete()
end
