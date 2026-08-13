--傀儡儀式－パペット・リチューアル
-- 效果：
-- 自己基本分比对方少2000以上的场合才能发动。从自己墓地选择2只名字带有「机关傀儡」的8星怪兽特殊召唤。「傀儡仪式」在1回合只能发动1张，这张卡发动的回合，自己不能进行战斗阶段。
function c1969506.initial_effect(c)
	-- 自己基本分比对方少2000以上的场合才能发动。从自己墓地选择2只名字带有「机关傀儡」的8星怪兽特殊召唤。「傀儡仪式」在1回合只能发动1张，这张卡发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,1969506+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c1969506.spcon)
	e1:SetCost(c1969506.spcost)
	e1:SetTarget(c1969506.sptg)
	e1:SetOperation(c1969506.spop)
	c:RegisterEffect(e1)
end
-- 该函数为「傀儡仪式」的发动条件判定函数：当己方基本分比对方少2000以上时，条件成立，允许发动。
function c1969506.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定己方LP<=对方LP-2000，即己方基本分比对方少2000以上时返回true。
	return Duel.GetLP(tp)<=Duel.GetLP(1-tp)-2000
end
-- 该函数为「傀儡仪式」的发动代价处理：非主要阶段2时才能发动；发动后给己方附加“不能进入战斗阶段”的永续效果，直到回合结束。
function c1969506.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段（chk==0）时，若当前为主要阶段2则不能发动，因为此时已无法再进入战斗阶段，无法支付“不能进行战斗阶段”的代价。
	if chk==0 then return Duel.GetCurrentPhase()~=PHASE_MAIN2 end
	-- 从自己墓地选择2只名字带有「机关傀儡」的8星怪兽特殊召唤。这张卡发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能进入战斗阶段”的效果e1注册给己方玩家tp，使其本回合不能进入战斗阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 该函数为特殊召唤对象的筛选条件：卡名含有「机关傀儡」字段、等级为8、且可被当前效果特殊召唤的怪兽。
function c1969506.filter(c,e,tp)
	return c:IsSetCard(0x1083) and c:IsLevel(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 该函数为「傀儡仪式」的发动目标选择与合法性检查：当检查对象chkc时验证其位于己方墓地且符合筛选条件；在合法性检查chk==0时，若己方未受青眼精灵龙效果影响、主要怪兽区空位大于1，且墓地存在至少2只符合条件的「机关傀儡」8星怪兽，则允许发动。
function c1969506.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c1969506.filter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查己方主要怪兽区空位是否大于1，以保证有足够空间特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查墓地中是否存在至少2只满足筛选条件的「机关傀儡」8星怪兽，且可以作为此效果的对象。
		and Duel.IsExistingTarget(c1969506.filter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 向己方玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让己方玩家从自己墓地选择2张符合条件的「机关傀儡」8星怪兽作为特殊召唤的对象，并将其记录为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c1969506.filter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	-- 向系统登记本次效果将进行特殊召唤，对象为g中的2张卡，用于后续效果处理的检测与连锁。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 该函数为「傀儡仪式」效果处理时的特殊召唤执行：取得本次连锁的目标卡，筛选出仍与此效果相关的卡；若目标消失或受青眼精灵龙效果限制且目标数量大于1则不处理；若己方怪兽区空位足够，则将目标卡以表侧表示特殊召唤。
function c1969506.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上主要怪兽区可用的空格数，用于判断是否能放下要特殊召唤的怪兽。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 取得当前连锁中记录的效果对象卡组，即发动时选择的2只墓地怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()==0 or (sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if ft>=sg:GetCount() then
		-- 将选中的怪兽以表侧表示特殊召唤到己方场上（不检查召唤条件、不检查苏生限制）。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
