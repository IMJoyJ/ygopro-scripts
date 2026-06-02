--星辰竜パーン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡成为融合召唤的素材送去墓地的场合才能发动。从卡组把1张「星辰」魔法·陷阱卡在自己场上盖放。那之后，可以把场上1只怪兽破坏。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的融合怪兽被对方的效果破坏的场合才能发动。这张卡回到卡组最下面，从自己墓地把融合怪兽以外的1只「星辰」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化函数：注册本卡效果①（作为融合素材送入墓地时发动：从卡组盖放1张「星辰」魔陷，之后可选场上1张怪兽破坏）以及效果②（墓地触发效果：场上的表侧表示融合怪兽被对方效果破坏时发动：这张卡返回卡组底，特殊召唤墓地1只融合怪兽以外的「星辰」怪兽）
function s.initial_effect(c)
	-- ①：这张卡成为融合召唤的素材送去墓地的场合才能发动。从卡组把1张「星辰」魔法·陷阱卡在自己场上盖放。那之后，可以把场上1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放魔陷"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的融合怪兽被对方的效果破坏的场合才能发动。这张卡回到卡组最下面，从自己墓地把融合怪兽以外的1只「星辰」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 设置效果①的发动条件：本卡已在墓地且作为融合素材被送入墓地，并且并未因其他卡的效果返回墓地
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION and not c:IsReason(REASON_RETURN)
end
-- 过滤条件：检查卡片是否属于「星辰」系列魔陷且能够在场上盖放
function s.setfilter(c)
	return c:IsSetCard(0x1c9) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果①的发动准备与合法性检查：检查卡组中是否存在符合条件的「星辰」魔陷，并向对方玩家通告发动效果的操作
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时，检查自己卡组中是否有符合条件的「星辰」魔陷可以被盖放
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家显示本效果已选择发动的信息提示
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果①的效果处理：从卡组将1张符合条件的「星辰」魔陷盖放到自己场上。盖放成功时，可选择是否追加破坏场上的1只怪兽
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的魔陷卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张符合条件的「星辰」魔法或陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 如果卡片存在且将其成功盖放到场上
	if tc and Duel.SSet(tp,tc)~=0 then
		-- 获取场上的所有怪兽卡
		local mg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 如果场上存在怪兽且玩家选择同意追加破坏效果
		if #mg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把怪兽破坏？"
			-- 提示玩家选择要破坏的怪兽卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=mg:Select(tp,1,1,nil)
			-- 手动在场上显示选择的怪兽被选为效果对象的动画
			Duel.HintSelection(sg)
			-- 中断效果处理，使后续的破坏操作与之前的盖放操作不视为同时进行
			Duel.BreakEffect()
			-- 以效果原因破坏选择的怪兽
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
-- 过滤条件：被破坏的怪兽在离场前需处于自己控制下，且原本是表侧表示的融合怪兽
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsType(TYPE_FUSION)
end
-- 设置效果②的发动条件：被破坏的对象是被对方效果破坏的己方表侧表示融合怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(s.cfilter,1,e:GetHandler(),tp)
end
-- 过滤条件：在墓地中寻找融合怪兽以外的「星辰」怪兽，且能被特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1c9) and not c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与合法性检查：检查墓地中的本卡是否能返回卡组，且场上有格子，墓地中有可用怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck()
		-- 检查当前场上是否留有可用于特殊召唤的怪兽格子
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除本卡外，墓地中是否存在可特殊召唤的融合怪兽以外的「星辰」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 注册特殊召唤操作信息：从墓地中特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	-- 注册返回卡组操作信息：将本卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
	-- 向对方玩家显示本效果已选择发动的信息提示
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果②的效果处理：将墓地的本卡放回卡组最下方，若成功返回且在卡组，则从墓地特殊召唤1只融合怪兽以外的「星辰」怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若本卡仍在墓地且不受王家长眠之谷的影响，则将其放回卡组最底端，并检查是否成功操作
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0
		and c:IsLocation(LOCATION_DECK) then
		-- 若由于之前的连锁导致己方场上已无特召格子，则不再执行后续处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家在自己的墓地（并受到王家长眠之谷的过滤判定）中选择1只符合条件的融合怪兽以外的「星辰」怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示在自己场上特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
