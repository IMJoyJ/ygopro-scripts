--希望皇オノマトピア
-- 效果：
-- 这个卡名在规则上也当作「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」卡使用。这个卡名的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从手卡把「希望皇 拟声乌托邦」以外的以下怪兽各最多1只守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
-- ●「刷拉拉」怪兽
-- ●「我我我」怪兽
-- ●「隆隆隆」怪兽
-- ●「怒怒怒」怪兽
function c8512558.initial_effect(c)
	-- ①：自己主要阶段才能发动。从手卡把「希望皇 拟声乌托邦」以外的以下怪兽各最多1只守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。●「刷拉拉」怪兽●「我我我」怪兽●「隆隆隆」怪兽●「怒怒怒」怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8512558,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,8512558)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c8512558.sptg)
	e1:SetOperation(c8512558.spop)
	c:RegisterEffect(e1)
end
c8512558.combination2={}
-- 创建用于检查2张卡是否分别属于「刷拉拉」和「我我我」字段的函数数组
c8512558.combination2[1]=aux.CreateChecks(Card.IsSetCard,{0x54,0x59})
-- 创建用于检查2张卡是否分别属于「刷拉拉」和「隆隆隆」字段的函数数组
c8512558.combination2[2]=aux.CreateChecks(Card.IsSetCard,{0x54,0x82})
-- 创建用于检查2张卡是否分别属于「刷拉拉」和「怒怒怒」字段的函数数组
c8512558.combination2[3]=aux.CreateChecks(Card.IsSetCard,{0x54,0x8f})
-- 创建用于检查2张卡是否分别属于「我我我」和「隆隆隆」字段的函数数组
c8512558.combination2[4]=aux.CreateChecks(Card.IsSetCard,{0x59,0x82})
-- 创建用于检查2张卡是否分别属于「我我我」和「怒怒怒」字段的函数数组
c8512558.combination2[5]=aux.CreateChecks(Card.IsSetCard,{0x59,0x8f})
-- 创建用于检查2张卡是否分别属于「隆隆隆」和「怒怒怒」字段的函数数组
c8512558.combination2[6]=aux.CreateChecks(Card.IsSetCard,{0x82,0x8f})
c8512558.combination3={}
-- 创建用于检查3张卡是否分别属于「我我我」、「隆隆隆」和「怒怒怒」字段的函数数组
c8512558.combination3[1]=aux.CreateChecks(Card.IsSetCard,{0x59,0x82,0x8f})
-- 创建用于检查3张卡是否分别属于「刷拉拉」、「隆隆隆」和「怒怒怒」字段的函数数组
c8512558.combination3[2]=aux.CreateChecks(Card.IsSetCard,{0x54,0x82,0x8f})
-- 创建用于检查3张卡是否分别属于「刷拉拉」、「我我我」和「怒怒怒」字段的函数数组
c8512558.combination3[3]=aux.CreateChecks(Card.IsSetCard,{0x54,0x59,0x8f})
-- 创建用于检查3张卡是否分别属于「刷拉拉」、「我我我」和「隆隆隆」字段的函数数组
c8512558.combination3[4]=aux.CreateChecks(Card.IsSetCard,{0x54,0x59,0x82})
-- 创建用于检查4张卡是否分别属于「刷拉拉」、「我我我」、「隆隆隆」和「怒怒怒」字段的函数数组
c8512558.combination4=aux.CreateChecks(Card.IsSetCard,{0x54,0x59,0x82,0x8f})
-- 过滤手牌中属于「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」字段，且卡名不是「希望皇 拟声乌托邦」并可以特殊召唤的怪兽
function c8512558.spfilter(c,e,tp)
	return c:IsSetCard(0x54,0x59,0x82,0x8f) and not c:IsCode(8512558) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检测函数
function c8512558.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1张满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c8512558.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	-- 设置连锁处理的操作信息，表示将从手牌特殊召唤至少1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 定义怪兽组检查函数，确保选中的怪兽在「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」中各最多属于1个不同的字段分类
function c8512558.gcheck(g)
	if #g==1 then
		return true
	elseif #g==2 then
		return g:CheckSubGroupEach(c8512558.combination2[1])
			or g:CheckSubGroupEach(c8512558.combination2[2])
			or g:CheckSubGroupEach(c8512558.combination2[3])
			or g:CheckSubGroupEach(c8512558.combination2[4])
			or g:CheckSubGroupEach(c8512558.combination2[5])
			or g:CheckSubGroupEach(c8512558.combination2[6])
	elseif #g==3 then
		return g:CheckSubGroupEach(c8512558.combination3[1])
			or g:CheckSubGroupEach(c8512558.combination3[2])
			or g:CheckSubGroupEach(c8512558.combination3[3])
			or g:CheckSubGroupEach(c8512558.combination3[4])
	elseif #g==4 then
		return g:CheckSubGroupEach(c8512558.combination4)
	end
end
-- 效果①的效果处理函数，执行特殊召唤并施加额外卡组特殊召唤限制
function c8512558.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取手牌中所有满足特殊召唤条件的怪兽
	local g=Duel.GetMatchingGroup(c8512558.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>0 and #g>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:SelectSubGroup(tp,c8512558.gcheck,false,1,math.min(4,ft))
		-- 将选中的怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c8512558.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，限制玩家不能从额外卡组特殊召唤超量怪兽以外的怪兽
	Duel.RegisterEffect(e1,tp)
end
-- 限制过滤函数，用于判定被限制特殊召唤的卡是否为额外卡组的非超量怪兽
function c8512558.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
