--魔法名－「大いなる獣」
-- 效果：
-- ①：以除外的自己的「召唤兽」怪兽任意数量为对象才能发动（同名卡最多1张）。那些怪兽守备表示特殊召唤。
function c47457347.initial_effect(c)
	-- 效果原文内容：①：以除外的自己的「召唤兽」怪兽任意数量为对象才能发动（同名卡最多1张）。那些怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c47457347.target)
	e1:SetOperation(c47457347.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断除外区的怪兽是否满足被特殊召唤的条件
function c47457347.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xf4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 处理效果的目标选择阶段，判断目标是否合法
function c47457347.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c47457347.filter(chkc,e,tp) end
	-- 检查玩家场上是否有足够的怪兽区域来特殊召唤怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家除外区是否存在满足条件的「召唤兽」怪兽
		and Duel.IsExistingTarget(c47457347.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取玩家除外区中所有满足条件的「召唤兽」怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(c47457347.filter,tp,LOCATION_REMOVED,0,nil,e,tp):Filter(Card.IsCanBeEffectTarget,nil,e)
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从符合条件的卡片组中选择满足条件（同名卡最多1张）的子集
	local tg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
	-- 设置当前效果的目标卡片为所选的卡片组
	Duel.SetTargetCard(tg)
	-- 设置操作信息，表示本次连锁将处理特殊召唤效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,tg:GetCount(),0,0)
end
-- 效果发动时的处理函数，用于执行特殊召唤操作
function c47457347.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 从当前连锁中获取已设定的目标卡片，并筛选出与该效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft<=0 or g:GetCount()==0 or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if g:GetCount()<=ft then
		-- 将满足条件的卡片组以守备表示的形式特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	else
		-- 向玩家发送提示信息，提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ft,ft,nil)
		-- 将选定的卡片以守备表示的形式特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		g:Sub(sg)
		-- 将未被特殊召唤的剩余卡片送入墓地
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
