--闇竜星－ジョクト
-- 效果：
-- 「暗龙星-椒图」的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把「暗龙星-椒图」以外的1只「龙星」怪兽攻击表示特殊召唤。
-- ②：自己场上没有这张卡以外的怪兽存在的场合，把手卡2张「龙星」卡送去墓地才能发动。从卡组把攻击力0和守备力0的「龙星」怪兽各1只特殊召唤。这个效果特殊召唤的怪兽在结束阶段除外。
function c25935625.initial_effect(c)
	-- 「暗龙星-椒图」的①②的效果1回合只能有1次使用其中任意1个。①：自己场上的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把「暗龙星-椒图」以外的1只「龙星」怪兽攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25935625,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,25935625)
	e1:SetCondition(c25935625.condition)
	e1:SetTarget(c25935625.target)
	e1:SetOperation(c25935625.operation)
	c:RegisterEffect(e1)
	-- ②：自己场上没有这张卡以外的怪兽存在的场合，把手卡2张「龙星」卡送去墓地才能发动。从卡组把攻击力0和守备力0的「龙星」怪兽各1只特殊召唤。这个效果特殊召唤的怪兽在结束阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25935625,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,25935625)
	e2:SetCondition(c25935625.spcon)
	e2:SetCost(c25935625.spcost)
	e2:SetTarget(c25935625.sptg)
	e2:SetOperation(c25935625.spop)
	c:RegisterEffect(e2)
end
-- 判断①效果的发动条件：这张卡被战斗或效果破坏并送去墓地，且破坏前在场上且控制者为发动玩家。
function c25935625.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- 定义①效果特殊召唤的候选怪兽条件：是「龙星」怪兽、不是「暗龙星-椒图」自身、可以表侧攻击表示特殊召唤。
function c25935625.filter(c,e,tp)
	return c:IsSetCard(0x9e) and not c:IsCode(25935625) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- ①效果发动时的合法性检测：自己主要怪兽区有空位，且卡组中存在满足filter条件的「龙星」怪兽。
function c25935625.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有空余区域（大于0）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足filter条件的「龙星」怪兽。
		and Duel.IsExistingMatchingCard(c25935625.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果将进行从卡组特殊召唤1只怪兽（类别：特殊召唤，位置：卡组，数量：1），用于连锁响应判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：若主要怪兽区仍有空位，则从卡组选择1只符合条件的「龙星」怪兽以表侧攻击表示特殊召唤。
function c25935625.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查主要怪兽区空位，若没有空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，要求选择要特殊召唤的卡（用于卡组挑选界面）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1张满足filter条件的「龙星」怪兽（排除「暗龙星-椒图」自身）。
	local g=Duel.SelectMatchingCard(tp,c25935625.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
-- 判断②效果的发动条件：自己场上不存在这张卡以外的怪兽（即自己场上只有「暗龙星-椒图」自身）。
function c25935625.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主要怪兽区的怪兽数量是否恰好为1（只有这张卡自己）。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
end
-- 定义②效果发动代价的卡片条件：手卡中的「龙星」卡且可以送去墓地作为代价。
function c25935625.cfilter(c)
	return c:IsSetCard(0x9e) and c:IsAbleToGraveAsCost()
end
-- ②效果的代价处理：从手卡中选择2张「龙星」卡送去墓地作为发动代价。
function c25935625.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：手卡中是否存在至少2张满足cfilter条件的「龙星」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c25935625.cfilter,tp,LOCATION_HAND,0,2,nil) end
	-- 以代价形式从手卡丢弃2张符合条件的「龙星」卡。
	Duel.DiscardHand(tp,c25935625.cfilter,2,2,REASON_COST)
end
-- 定义攻击力0的「龙星」怪兽的筛选条件，并且要求卡组中存在守备力0的「龙星」怪兽，以确保能同时选出两只。
function c25935625.spfilter1(c,e,tp)
	return c:IsSetCard(0x9e) and c:IsAttack(0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查卡组中是否存在守备力0的「龙星」怪兽（作为第二只特殊召唤的候选）。
		and Duel.IsExistingMatchingCard(c25935625.spfilter2,tp,LOCATION_DECK,0,1,c,e,tp)
end
-- 定义守备力0的「龙星」怪兽的筛选条件：是「龙星」怪兽、守备力为0、可以被特殊召唤。
function c25935625.spfilter2(c,e,tp)
	return c:IsSetCard(0x9e) and c:IsDefense(0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时的合法性检测：自己不受「青眼精灵龙」效果影响（不能同时特殊召唤2只以上怪兽的限制未生效），自己主要怪兽区至少有2个空位，且卡组中存在攻击力0的「龙星」怪兽并能凑齐守备力0的「龙星」怪兽。
function c25935625.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 要求自己主要怪兽区空位数量大于1，因为需要同时特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查卡组中是否存在至少1只满足spfilter1条件的攻击力0「龙星」怪兽。
		and Duel.IsExistingMatchingCard(c25935625.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果将进行从卡组特殊召唤2只怪兽（类别：特殊召唤，数量：2，位置：卡组）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- ②效果处理：先确认不受「青眼精灵龙」影响且主要怪兽区至少2个空位；然后分别选攻击力0和守备力0的「龙星」怪兽各1只，表侧表示特殊召唤，并为这些怪兽登记flag以在结束阶段除外。
function c25935625.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时再次检查主要怪兽区空位是否少于2个，是则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 提示玩家选择第一只特殊召唤的怪兽（攻击力0的「龙星」）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只攻击力0的「龙星」怪兽。
	local g1=Duel.SelectMatchingCard(tp,c25935625.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 提示玩家选择第二只特殊召唤的怪兽（守备力0的「龙星」）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只守备力0的「龙星」怪兽，排除已选择的攻击力0那只。
	local g2=Duel.SelectMatchingCard(tp,c25935625.spfilter2,tp,LOCATION_DECK,0,1,1,g1:GetFirst(),e,tp)
	g1:Merge(g2)
	if g1:GetCount()>0 then
		local fid=e:GetHandler():GetFieldID()
		local tc=g1:GetFirst()
		while tc do
			-- 将一只怪兽加入分步特殊召唤流程（暂缓上场），之后统一完成召唤。
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(25935625,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			tc=g1:GetNext()
		end
		-- 完成分步特殊召唤，使所有积累的怪兽正式特殊召唤上场。
		Duel.SpecialSummonComplete()
		g1:KeepAlive()
		-- 这个效果特殊召唤的怪兽在结束阶段除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(g1)
		e1:SetCondition(c25935625.rmcon)
		e1:SetOperation(c25935625.rmop)
		-- 将结束阶段除外这个持续效果注册到场上，使其在结束阶段对标记过的怪兽生效。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤函数：判断怪兽是否带有本次②效果赋予的特殊召唤标记（fid）。
function c25935625.rmfilter(c,fid)
	return c:GetFlagEffectLabel(25935625)==fid
end
-- 结束阶段除外效果的条件：若还存在带有对应标记的怪兽则执行除外；若已不存在，则清理已无用的效果组并重置该效果。
function c25935625.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c25935625.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段除外的处理：取出仍然带有对应标记的怪兽，将它们全部除外。
function c25935625.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c25935625.rmfilter,nil,e:GetLabel())
	-- 将被标记的怪兽以表侧表示除外，排除原因为效果。
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end
