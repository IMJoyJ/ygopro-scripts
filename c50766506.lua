--忍法 分身の術
-- 效果：
-- ①：把自己场上1只「忍者」怪兽解放才能把这张卡发动。等级合计最多到解放的怪兽的等级以下为止，从卡组选「忍者」怪兽任意数量各以表侧攻击表示或者里侧守备表示特殊召唤。这张卡从场上离开时那些怪兽全部破坏。
function c50766506.initial_effect(c)
	-- ①：把自己场上1只「忍者」怪兽解放才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c50766506.target)
	e1:SetOperation(c50766506.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那些怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c50766506.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查场上是否存在满足条件的「忍者」怪兽用于解放
function c50766506.cfilter(c,e,tp,ft)
	local lv=c:GetLevel()
	return lv>0 and c:IsSetCard(0x2b)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
		-- 检查卡组中是否存在满足等级条件的「忍者」怪兽可用于特殊召唤
		and Duel.IsExistingMatchingCard(c50766506.spfilter,tp,LOCATION_DECK,0,1,nil,lv,e,tp)
end
-- 过滤函数，检查卡组中是否存在满足等级和召唤条件的「忍者」怪兽
function c50766506.spfilter(c,lv,e,tp)
	return c:IsLevelBelow(lv) and c:IsSetCard(0x2b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
end
-- 效果处理时选择1只满足条件的场上「忍者」怪兽进行解放，并设置其等级为后续特殊召唤的上限
function c50766506.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家当前场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 判断是否满足发动条件：场上存在可解放的「忍者」怪兽且有足够怪兽区域
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c50766506.cfilter,1,nil,e,tp,ft) end
	-- 选择1只满足条件的场上「忍者」怪兽进行解放操作
	local rg=Duel.SelectReleaseGroup(tp,c50766506.cfilter,1,1,nil,e,tp,ft)
	e:SetLabel(rg:GetFirst():GetLevel())
	-- 将选中的怪兽从场上解放作为发动代价
	Duel.Release(rg,REASON_COST)
	-- 设置后续特殊召唤操作的信息，用于连锁检测和提示
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 子函数：判断所选怪兽等级总和是否不超过解放怪兽的等级上限
function c50766506.gselect(g,slv)
	return g:GetSum(Card.GetLevel)<=slv
end
-- 效果处理时从卡组中选择满足条件的「忍者」怪兽进行特殊召唤，并确认其位置
function c50766506.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家当前场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local c=e:GetHandler()
	local slv=e:GetLabel()
	-- 从卡组中筛选出满足等级和召唤条件的「忍者」怪兽作为可选对象
	local sg=Duel.GetMatchingGroup(c50766506.spfilter,tp,LOCATION_DECK,0,nil,slv,e,tp)
	if sg:GetCount()==0 then return end
	-- 提示玩家选择要特殊召唤的「忍者」怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local tg=sg:SelectSubGroup(tp,c50766506.gselect,false,1,ft,slv)
	local cg=Group.CreateGroup()
	-- 遍历所选的怪兽进行特殊召唤处理
	for tc in aux.Next(tg) do
		-- 将当前遍历到的怪兽以攻击表示或守备表示特殊召唤到场上
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
		if tc:IsFacedown() then cg:AddCard(tc) end
		c:SetCardTarget(tc)
	end
	-- 完成所有特殊召唤步骤，统一处理召唤后的结算
	Duel.SpecialSummonComplete()
	-- 向对方确认被特殊召唤的怪兽是否为里侧表示
	Duel.ConfirmCards(1-tp,cg)
end
-- 当此卡离开场时，将所有因该效果特殊召唤出的怪兽全部破坏
function c50766506.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetCardTarget():Filter(Card.IsLocation,nil,LOCATION_MZONE)
	-- 将目标怪兽进行破坏处理
	Duel.Destroy(g,REASON_EFFECT)
end
