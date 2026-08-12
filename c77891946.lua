--エクソシスター・バディス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：支付800基本分才能发动。从卡组选1只「救祓少女」怪兽，再从卡组选1只在那只怪兽有卡名记述的「救祓少女」怪兽。那2只怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到卡组。这张卡的发动后，直到回合结束时自己不是「救祓少女」怪兽不能从额外卡组特殊召唤。
function c77891946.initial_effect(c)
	-- ①：支付800基本分才能发动。从卡组选1只「救祓少女」怪兽，再从卡组选1只在那只怪兽有卡名记述的「救祓少女」怪兽。那2只怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到卡组。这张卡的发动后，直到回合结束时自己不是「救祓少女」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,77891946+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c77891946.cost)
	e1:SetTarget(c77891946.target)
	e1:SetOperation(c77891946.activate)
	c:RegisterEffect(e1)
end
-- 定义发动的代价（Cost）函数，检查并支付800点基本分
function c77891946.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，检查玩家是否能支付800点基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 扣除玩家800点基本分作为发动代价
	Duel.PayLPCost(tp,800)
end
-- 过滤第一只从卡组特殊召唤的「救祓少女」怪兽，要求卡组中必须存在另一只在其卡名记述的「救祓少女」怪兽
function c77891946.spfilter1(c,e,tp)
	return c:IsSetCard(0x172) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查卡组中是否存在至少1张满足spfilter2条件的卡（即记述了当前卡卡名的另一只「救祓少女」怪兽）
		and Duel.IsExistingMatchingCard(c77891946.spfilter2,tp,LOCATION_DECK,0,1,c,e,tp,c)
end
-- 过滤第二只从卡组特殊召唤的「救祓少女」怪兽，要求其卡名被第一只选定的怪兽所记述
function c77891946.spfilter2(c,e,tp,ec)
	return c:IsSetCard(0x172) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查第一只选定的怪兽的效果文本中是否记述了当前卡的卡名
		and aux.IsCodeListed(ec,c:GetCode())
end
-- 定义效果的目标（Target）函数，检查怪兽区域空位数、卡组中是否存在符合条件的怪兽，并设置特殊召唤的操作信息
function c77891946.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，检查自己场上的主要怪兽区域空位数是否大于1
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查卡组中是否存在至少1张满足spfilter1条件的「救祓少女」怪兽
		and Duel.IsExistingMatchingCard(c77891946.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) end
	-- 设置特殊召唤的操作信息，表示将从卡组特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,LOCATION_DECK)
end
-- 定义效果的处理（Operation）函数，执行特殊召唤、注册结束阶段回到卡组以及额外卡组特殊召唤限制的效果
function c77891946.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 给玩家发送“请选择要特殊召唤的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足spfilter1条件的「救祓少女」怪兽
	local g1=Duel.SelectMatchingCard(tp,c77891946.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g1==0 then return end
	-- 给玩家发送“请选择要特殊召唤的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只在其卡名被第一只选定怪兽记述的「救祓少女」怪兽
	local g2=Duel.SelectMatchingCard(tp,c77891946.spfilter2,tp,LOCATION_DECK,0,1,1,g1,e,tp,g1:GetFirst())
	g1:Merge(g2)
	local tc=g1:GetFirst()
	local fid=c:GetFieldID()
	while tc do
		-- 将目标怪兽以表侧表示进行特殊召唤的准备步骤
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(77891946,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		tc=g1:GetNext()
	end
	-- 完成所有准备步骤中怪兽的特殊召唤
	Duel.SpecialSummonComplete()
	g1:KeepAlive()
	-- 这个效果特殊召唤的怪兽在结束阶段回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(g1)
	e1:SetCondition(c77891946.tdcon)
	e1:SetOperation(c77891946.tdop)
	-- 注册在结束阶段将特殊召唤的怪兽送回卡组的延迟效果
	Duel.RegisterEffect(e1,tp)
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己不是「救祓少女」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c77891946.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制玩家不能从额外卡组特殊召唤「救祓少女」以外怪兽的效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤带有当前效果标识（fid）的卡片，用于在结束阶段将其送回卡组
function c77891946.tdfilter(c,fid)
	return c:GetFlagEffectLabel(77891946)==fid
end
-- 检查被特殊召唤的怪兽是否还存在于场上，若不存在则重置该延迟效果
function c77891946.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c77891946.tdfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else
		return true
	end
end
-- 结束阶段时的具体操作：将依然存在于场上的被特殊召唤的怪兽送回卡组
function c77891946.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c77891946.tdfilter,nil,e:GetLabel())
	-- 将目标怪兽送回持有者卡组并洗牌
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 限制不能从额外卡组特殊召唤「救祓少女」以外的怪兽
function c77891946.splimit(e,c)
	return not c:IsSetCard(0x172) and c:IsLocation(LOCATION_EXTRA)
end
