--ピュアリィ
-- 效果：
-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己卡组上面把3张卡翻开。可以从那之中选1张「纯爱妖精」魔法·陷阱卡加入手卡。剩下的卡用喜欢的顺序回到卡组下面。
-- ②：1回合1次，自己主要阶段才能发动。手卡1张「纯爱妖精」速攻魔法卡给对方观看，把有那个卡名记述的1只超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤，把给人观看的卡作为那只超量怪兽的超量素材。
local s,id,o=GetID()
-- 注册卡片的3个效果：①通常召唤·特殊召唤时发动的效果，②特殊召唤时发动的效果，③自己主要阶段时发动的效果
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己卡组上面把3张卡翻开。可以从那之中选1张「纯爱妖精」魔法·陷阱卡加入手卡。剩下的卡用喜欢的顺序回到卡组下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己主要阶段才能发动。手卡1张「纯爱妖精」速攻魔法卡给对方观看，把有那个卡名记述的1只超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤，把给人观看的卡作为那只超量怪兽的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 效果①的发动时的处理函数，用于判断是否满足发动条件
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 判断自己卡组是否至少有3张卡
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return false end
		-- 获取自己卡组最上方的3张卡
		local g=Duel.GetDecktopGroup(tp,3)
		return g:FilterCount(Card.IsAbleToHand,nil)>0
	end
	-- 设置连锁的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
end
-- 效果①中用于筛选「纯爱妖精」魔法·陷阱卡的过滤函数
function s.tdfilter(c)
	return c:IsAbleToHand() and c:IsSetCard(0x18c) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果①的处理函数，执行翻开卡组、选择卡加入手牌、排序并放回卡组的操作
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 确认目标玩家卡组最上方的3张卡
	Duel.ConfirmDecktop(p,3)
	-- 获取目标玩家卡组最上方的3张卡
	local g=Duel.GetDecktopGroup(p,3)
	if not g or #g<1 then return end
	local ct=#g
	g=g:Filter(s.tdfilter,nil)
	-- 判断是否有符合条件的魔法·陷阱卡且玩家选择是否使用效果
	if #g>0 and Duel.SelectYesNo(p,aux.Stringid(id,2)) then  --"是否选1张「纯爱妖精」魔法·陷阱卡加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(p,1,1,nil)
		-- 禁用后续操作的洗牌检测
		Duel.DisableShuffleCheck()
		-- 将选择的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认玩家选择的卡
		Duel.ConfirmCards(1-p,sg)
		-- 洗切玩家的手牌
		Duel.ShuffleHand(p)
		ct=ct-1
	end
	if ct<=1 then return end
	-- 让玩家对卡组最上方的剩余卡进行排序
	Duel.SortDecktop(p,p,ct)
	for i=1,ct do
		-- 获取玩家卡组最上方的1张卡
		local mg=Duel.GetDecktopGroup(p,1)
		-- 将卡移动到卡组最下方
		Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
	end
end
-- 效果②中用于筛选可特殊召唤的超量怪兽的过滤函数
function s.sptgexfilter(c,e,tp,code)
	local sc=e:GetHandler()
	-- 判断目标怪兽是否记载有指定卡号、是否可特殊召唤为超量怪兽
	return aux.IsCodeListed(c,code) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 判断目标怪兽是否为超量怪兽、是否可作为此卡的超量素材、场上是否有足够空位
		and c:IsType(TYPE_XYZ) and sc:IsCanBeXyzMaterial(c) and Duel.GetLocationCountFromEx(tp,tp,sc,c)>0
end
-- 效果②中用于筛选可作为超量素材的速攻魔法卡的过滤函数
function s.sptgfilter(c,e,tp)
	return not c:IsPublic() and c:IsType(TYPE_QUICKPLAY) and c:IsSetCard(0x18c) and c:IsCanOverlay()
		-- 判断是否存在符合条件的超量怪兽
		and Duel.IsExistingMatchingCard(s.sptgexfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetCode())
end
-- 效果②的发动时的处理函数，用于判断是否满足发动条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断此卡是否满足超量召唤的素材要求
	if chk==0 then return aux.MustMaterialCheck(e:GetHandler(),tp,EFFECT_MUST_BE_XMATERIAL)
		-- 判断手牌中是否存在符合条件的速攻魔法卡
		and Duel.IsExistingMatchingCard(s.sptgfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁的操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的处理函数，执行选择速攻魔法卡、确认、特殊召唤超量怪兽、叠放素材的操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否满足超量召唤的素材要求
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if not c:IsRelateToChain() or c:IsImmuneToEffect(e) or c:IsFacedown() or c:IsControler(1-tp) then return end
	-- 提示玩家选择给对方确认的速攻魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择玩家手牌中符合条件的速攻魔法卡
	local g=Duel.SelectMatchingCard(tp,s.sptgfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g<1 then return end
	-- 向对方确认玩家选择的速攻魔法卡
	Duel.ConfirmCards(1-tp,g)
	local sc=g:GetFirst()
	-- 提示玩家选择要特殊召唤的超量怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的超量怪兽
	local sg=Duel.SelectMatchingCard(tp,s.sptgexfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,sc:GetCode())
	local tc=sg:GetFirst()
	tc:SetMaterial(Group.FromCards(c))
	-- 将此卡作为超量素材叠放
	Duel.Overlay(tc,Group.FromCards(c))
	-- 将目标怪兽以超量召唤方式特殊召唤
	Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()
	-- 如果速攻魔法卡未被无效且可叠放，则将该卡叠放至目标怪兽上
	if not sc:IsImmuneToEffect(e) and sc:IsCanOverlay() then Duel.Overlay(tc,g) end
end
