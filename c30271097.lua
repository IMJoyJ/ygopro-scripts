--The Fallen ＆ The Virtuous
-- 效果：
-- 这个卡名在规则上也当作「烙印」卡、「教导」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●从额外卡组把有「阿不思的落胤」的卡名记述的1只怪兽送去墓地，以场上1张表侧表示卡为对象才能发动。那张卡破坏。
-- ●自己的场上或墓地有「艾克莉西娅」怪兽存在的场合，以自己或对方的墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
local s,id,o=GetID()
-- 初始化效果注册：将本卡标记为记载有「阿不思的落胤」的卡，并创建①效果；该效果为魔法卡发动效果，可在自由时点发动，取对象，1回合只能发动1次（誓约次数），同时设置目标选择函数s.target与效果处理函数s.activate。
function s.initial_effect(c)
	-- 将「阿不思的落胤」（68468459）的卡号加入本卡的卡名记述列表，使相关检索与筛选能够识别“有「阿不思的落胤」的卡名记述”的卡。
	aux.AddCodeList(c,68468459)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。●从额外卡组把有「阿不思的落胤」的卡名记述的1只怪兽送去墓地，以场上1张表侧表示卡为对象才能发动。那张卡破坏。●自己的场上或墓地有「艾克莉西娅」怪兽存在的场合，以自己或对方的墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义额外卡组送墓代价的过滤函数：对象须为怪兽，卡名记述有「阿不思的落胤」（68468459），并且可作为代价送入墓地。
function s.cfilter(c)
	-- 过滤条件：卡必须是卡名中记载有「阿不思的落胤」的怪兽，且能作为代价送入墓地。
	return aux.IsCodeListed(c,68468459) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 定义「艾克莉西娅」怪兽存在判定函数：判断自己的场上或墓地的怪兽是否属于「艾克莉西娅」（0x1d7）系列，用于确认“自己场上或墓地有「艾克莉西娅」怪兽存在”。
function s.cfilter2(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1d7) and c:IsType(TYPE_MONSTER)
end
-- 定义特殊召唤对象过滤函数：检查对象怪兽能否被当前效果正常特殊召唤（满足召唤条件与苏生限制）。
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标与代价处理：分别检测两个选项的发动条件——选项1需额外卡组有可送墓的「阿不思的落胤」记载怪兽且场上有表侧表示卡可破坏；选项2需自己场上或墓地有「艾克莉西娅」怪兽且自己主要怪兽区有空位、双方墓地有可特殊召唤的怪兽。由玩家选择其中一个选项，并按选择执行对应的代价支付、对象选择，同时更新效果类别与连锁操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==1 then
			return chkc:IsOnField() and chkc:IsFaceup() and chkc~=e:GetHandler()
		elseif e:GetLabel()==2 then
			return chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp)
		end
		return false
	end
	-- 判定选项1的代价部分：存在符合条件的额外卡组怪兽可送入墓地；若尚未进行代价检查则先视为满足条件，避免重复搜索。
	local b1=(Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil) or not e:IsCostChecked())
		-- 判定选项1的对象部分：场上有至少1张表侧表示卡（本卡除外）可作为破坏对象。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
	-- 判定选项2的前置条件：自己场上或墓地存在「艾克莉西娅」怪兽。
	local b2=Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
		-- 判定特殊召唤可行：自己主要怪兽区域有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定选项2的对象：双方墓地存在至少1只可被当前效果特殊召唤的怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	-- 让玩家从两个效果分支中选择要发动的一项（破坏或特殊召唤）。
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"破坏"
			{b2,aux.Stringid(id,2),2})  --"特殊召唤"
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			-- 显示“请选择要送去墓地的卡”的提示，引导玩家选择代价怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 从自己的额外卡组选择1张符合过滤条件的「阿不思的落胤」记载怪兽作为代价。
			local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
			-- 将选择的额外卡组怪兽作为效果发动代价（REASON_COST）送去墓地。
			Duel.SendtoGrave(g,REASON_COST)
		end
		-- 显示“请选择要破坏的卡”的提示，引导玩家选择破坏对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择场上1张表侧表示卡（本卡除外）作为破坏对象，并将其登记为当前连锁的效果对象。
		local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DESTROY)
		end
		-- 登记连锁操作信息：本连锁将进行破坏处理，对象为已选择的g，数量为1，以便其他卡对应。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	elseif op==2 then
		-- 显示“请选择要特殊召唤的卡”的提示，引导玩家选择特殊召唤对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从双方墓地选择1只符合过滤条件的怪兽作为特殊召唤对象，并登记为当前连锁的效果对象。
		local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		end
		-- 登记连锁操作信息：本连锁将进行特殊召唤处理，对象为已选择的g，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
-- 效果处理阶段：取出发动时选择的对象，若对象仍与连锁相关则开始处理——选择破坏选项时破坏对象；选择特殊召唤选项时，在对象不被「王家长眠之谷」等效果禁止特殊召唤的前提下将其特殊召唤到自己场上。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() then return end
	if e:GetLabel()==1 and tc:IsOnField() then
		-- 以效果原因（REASON_EFFECT）将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	-- 若之前选择的是特殊召唤选项，且该对象没有受到“从墓地特殊召唤禁止”类效果（如王家长眠之谷）的影响，则继续特殊召唤处理。
	elseif e:GetLabel()==2 and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽以表侧表示特殊召唤到发动者的场上（特殊召唤合法性已在选择时确认）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
