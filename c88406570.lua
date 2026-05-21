--剛鬼デストロイ・オーガ
-- 效果：
-- 「刚鬼」怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡所连接区的怪兽在1回合各有1次不会被战斗破坏。
-- ②：自己主要阶段才能发动。对方从自身墓地选最多2只怪兽特殊召唤。那之后，自己从自己墓地选最多有特殊召唤的怪兽数量的连接怪兽以外的「刚鬼」怪兽在这张卡所连接区特殊召唤。这个效果的发动后，直到回合结束时自己不是「刚鬼」怪兽不能特殊召唤。
function c88406570.initial_effect(c)
	-- 为这张卡添加连接召唤手续：需要2只以上的「刚鬼」怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xfc),2)
	c:EnableReviveLimit()
	-- ①：这张卡所连接区的怪兽在1回合各有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c88406570.indtg)
	e1:SetValue(c88406570.indct)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。对方从自身墓地选最多2只怪兽特殊召唤。那之后，自己从自己墓地选最多有特殊召唤的怪兽数量的连接怪兽以外的「刚鬼」怪兽在这张卡所连接区特殊召唤。这个效果的发动后，直到回合结束时自己不是「刚鬼」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88406570,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,88406570)
	e2:SetTarget(c88406570.sptg)
	e2:SetOperation(c88406570.spop)
	c:RegisterEffect(e2)
end
-- 过滤处于这张卡所连接区的怪兽
function c88406570.indtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- 设置战斗破坏的抗性次数为1次
function c88406570.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		return 1
	else return 0 end
end
-- 过滤对方墓地中可以特殊召唤的怪兽
function c88406570.spfilter1(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤自己墓地中可以特殊召唤到指定连接区域的、连接怪兽以外的「刚鬼」怪兽
function c88406570.spfilter2(c,e,tp,zone)
	return c:IsSetCard(0xfc) and not c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 效果②的发动准备与合法性检测，并设置特殊召唤的操作信息
function c88406570.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local zone=e:GetHandler():GetLinkedZone()
		-- 检查这张卡是否存在可用的所连接区，且对方场上有可用的怪兽区域
		return zone~=0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE,1-tp)>0
			-- 检查对方墓地是否存在至少1只可以特殊召唤的怪兽
			and Duel.IsExistingMatchingCard(c88406570.spfilter1,1-tp,LOCATION_GRAVE,0,1,nil,e,1-tp)
			-- 检查自己墓地是否存在至少1只可以特殊召唤到这张卡所连接区的、连接怪兽以外的「刚鬼」怪兽
			and Duel.IsExistingMatchingCard(c88406570.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone)
	end
	-- 设置连锁处理中的操作信息：双方玩家从墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,PLAYER_ALL,LOCATION_GRAVE)
end
-- 效果②的执行逻辑：对方先从墓地特殊召唤最多2只怪兽，随后自己从墓地特殊召唤对应数量的「刚鬼」怪兽到所连接区，并适用特殊召唤限制
function c88406570.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE,1-tp)
	if ft>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(1-tp,59822133) then ft=1 end
		if ft>1 then ft=2 end
		-- 提示对方玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让对方玩家从其墓地选择最多2只（且不超过其怪兽区域空位数）可以特殊召唤的怪兽
		local g1=Duel.SelectMatchingCard(1-tp,c88406570.spfilter1,1-tp,LOCATION_GRAVE,0,1,ft,nil,e,1-tp)
		if g1:GetCount()>0 then
			-- 将对方选择的怪兽在对方场上表侧表示特殊召唤，并记录成功特殊召唤的数量
			local ct=Duel.SpecialSummon(g1,0,1-tp,1-tp,false,false,POS_FACEUP)
			local zone=c:GetLinkedZone(tp)
			-- 计算自己可用于特殊召唤的所连接区空格数与对方特殊召唤数量的较小值，作为自己特殊召唤的最大数量
			ct=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)),ct)
			if zone~=0 and ct>0 and c:IsRelateToEffect(e) then
				-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
				if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
				-- 提示自己选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 让自己从墓地选择最多有对方特殊召唤数量的、连接怪兽以外的「刚鬼」怪兽
				local g2=Duel.SelectMatchingCard(tp,c88406570.spfilter2,tp,LOCATION_GRAVE,0,1,ct,nil,e,tp,zone)
				if g2:GetCount()>0 then
					-- 中断当前效果处理，使后续的特殊召唤与前一步特殊召唤不视为同时处理
					Duel.BreakEffect()
					-- 将选中的「刚鬼」怪兽在自己场上的所连接区表侧表示特殊召唤
					Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP,zone)
				end
			end
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是「刚鬼」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c88406570.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该特殊召唤限制效果给发动效果的玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制自己不能特殊召唤「刚鬼」以外的怪兽
function c88406570.splimit(e,c)
	return not c:IsSetCard(0xfc)
end
