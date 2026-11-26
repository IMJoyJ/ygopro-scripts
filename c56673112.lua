--インペリアル・バウアー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己场上没有其他怪兽存在的场合，把这张卡解放才能发动。从卡组选「王后骑士」「卫兵骑士」「国王骑士」之内2只（同名卡最多1张）。那些怪兽各加入手卡或特殊召唤。
function c56673112.initial_effect(c)
	-- 记录这张卡的卡文本中记述了「王后骑士」「国王骑士」「卫兵骑士」。
	aux.AddCodeList(c,25652259,64788463,90876561)
	-- 这个卡名的效果1回合只能使用1次。①：自己场上没有其他怪兽存在的场合，把这张卡解放才能发动。从卡组选「王后骑士」「卫兵骑士」「国王骑士」之内2只（同名卡最多1张）。那些怪兽各加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56673112,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,56673112)
	e1:SetCondition(c56673112.spcon)
	e1:SetCost(c56673112.spcost)
	e1:SetTarget(c56673112.sptg)
	e1:SetOperation(c56673112.spop)
	c:RegisterEffect(e1)
end
-- ①效果的发动条件：检查自己怪兽区是否只有1只怪兽（即没有其他怪兽）。
function c56673112.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己怪兽区的怪兽数量是否恰好为1。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
end
-- ①效果的发动代价：检查并把这张卡解放作为发动代价。
function c56673112.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡作为发动代价解放。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：检查卡片是否为「国王骑士」「王后骑士」「卫兵骑士」之一，且可加入手卡或在有空位时可特殊召唤。
function c56673112.opfilter(c,e,tp,ft)
	return (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false) and ft>0) and c:IsCode(64788463,25652259,90876561)
end
-- 选卡组合校验函数：检查所选2只怪兽卡名各不相同，且能各自合法地分配到加入手卡或特殊召唤（特招数不超过可用空位）。
function c56673112.opcheck(g,e,tp,ft)
	if g:GetClassCount(Card.GetCode)<2 then return false end
	local thct=g:FilterCount(Card.IsAbleToHand,nil)
	local spct=g:FilterCount(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)
	return thct+math.min(spct,ft)>=2
end
-- ①效果的目标处理函数：计算这张卡离场后的可用怪兽区空位（受青眼精灵龙限制时最多为1），检查卡组是否存在合法的2只组合。
function c56673112.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取这张卡解放离场后自己怪兽区可用的空位数量。
		local ft=Duel.GetMZoneCount(tp,e:GetHandler())
		if ft<0 then ft=0 end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft>0 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 获取卡组中所有符合条件的「王后骑士」「卫兵骑士」「国王骑士」卡片组。
		local g=Duel.GetMatchingGroup(c56673112.opfilter,tp,LOCATION_DECK,0,nil,e,tp,ft)
		return g:CheckSubGroup(c56673112.opcheck,2,2,e,tp,ft)
	end
end
-- ①效果的处理函数：从卡组选出2只同名最多1张的目标怪兽，分配各加入手卡或特殊召唤并执行。
function c56673112.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时获取自己怪兽区当前可用的空位数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<0 then ft=0 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>0 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取卡组中所有符合条件的「王后骑士」「卫兵骑士」「国王骑士」卡片组。
	local g=Duel.GetMatchingGroup(c56673112.opfilter,tp,LOCATION_DECK,0,nil,e,tp,ft)
	-- 发送提示信息，引导玩家选择要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	local sg=g:SelectSubGroup(tp,c56673112.opcheck,false,2,2,e,tp,ft)
	if not sg then return end
	local thsg=Group.CreateGroup()
	local spsg=Group.CreateGroup()
	local thct=sg:FilterCount(Card.IsAbleToHand,nil)
	local spct=sg:FilterCount(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)
	if thct==0 then
		spsg=sg
	elseif spct==0 or ft==0 then
		thsg=sg
	else
		-- 若空位不足2个或玩家选择将其中部分怪兽加入手卡，则进入选择加入手卡的分支。
		if Duel.SelectYesNo(tp,aux.Stringid(56673112,1)) or ft<2 then  --"是否从中把怪兽加入手卡？"
			-- 发送提示信息，引导玩家选择要加入手卡的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			thsg=sg:FilterSelect(tp,Card.IsAbleToHand,1,thct,nil)
			spsg=sg-thsg
		else
			spsg=sg
		end
	end
	if #thsg>0 then
		-- 将分配为加入手卡的怪兽以效果加入自己手卡。
		Duel.SendtoHand(thsg,nil,REASON_EFFECT)
		-- 将加入手卡的怪兽展示给对方确认。
		Duel.ConfirmCards(1-tp,thsg)
	end
	if #spsg>0 then
		-- 将分配为特殊召唤的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(spsg,0,tp,tp,false,false,POS_FACEUP)
	end
end
