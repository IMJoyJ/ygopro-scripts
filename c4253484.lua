--剣闘獣ホプロムス
-- 效果：
-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功的场合，这张卡的原本守备力变成2400。这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组，从卡组把「剑斗兽 重斗」以外的1只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
function c4253484.initial_effect(c)
	-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功的场合，这张卡的原本守备力变成2400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_DEFENSE)
	e1:SetCondition(c4253484.defcon)
	e1:SetValue(2400)
	c:RegisterEffect(e1)
	-- 这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组，从卡组把「剑斗兽 重斗」以外的1只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4253484,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c4253484.spcon)
	e2:SetCost(c4253484.spcost)
	e2:SetTarget(c4253484.sptg)
	e2:SetOperation(c4253484.spop)
	c:RegisterEffect(e2)
end
-- 判断本卡是否带有标识4253484，即是否曾用名字带有「剑斗兽」的怪兽的效果特殊召唤成功。
function c4253484.defcon(e)
	return e:GetHandler():GetFlagEffect(4253484)>0
end
-- 判定本卡本回合是否进行过战斗（战斗阶段结束时满足条件）。
function c4253484.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 发动代价处理：检查自身能否作为代价返回卡组；若能，则将自身返回卡组并洗牌作为发动代价。
function c4253484.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 将本卡以洗牌状态返回持有者卡组，作为发动效果所需支付的代价。
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 检索条件：选择「剑斗兽 重斗」以外的、卡名带有「剑斗兽」的、可以被当前效果特殊召唤的怪兽。
function c4253484.filter(c,e,tp)
	return not c:IsCode(4253484) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标判定：确认自己场上存在可用的主怪兽区空格，且卡组中存在满足条件的剑斗兽怪兽。
function c4253484.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格（此处用>-1是为了允许后续cost自身回卡组后腾出格子）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查卡组中是否存在至少1张满足c4253484.filter条件的剑斗兽怪兽。
		and Duel.IsExistingMatchingCard(c4253484.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向系统登记本次效果将进行1只怪兽从卡组的特殊召唤，供相关卡牌互动判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若场上仍有空格，则从卡组选1只符合条件的剑斗兽特殊召唤，并给特殊召唤成功的怪兽注册一个以原卡号为代码的标识，用于关联该效果确定其特殊召唤来源。
function c4253484.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认场上是否有可用主怪兽区空格，没有则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作者显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1张满足条件的剑斗兽怪兽（「剑斗兽 重斗」以外）。
	local g=Duel.SelectMatchingCard(tp,c4253484.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到操作者场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
