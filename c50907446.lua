--エルシャドール・アプカローネ
-- 效果：
-- 属性不同的「影依」怪兽×2
-- 这张卡用融合召唤才能从额外卡组特殊召唤。这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，以场上1张表侧表示卡为对象才能发动。那张卡的效果无效。
-- ②：这张卡不会被战斗破坏。
-- ③：这张卡被送去墓地的场合才能发动。从自己的卡组·墓地把1张「影依」卡加入手卡。那之后，选自己1张手卡丢弃。
function c50907446.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合，以场上1张表侧表示卡为对象才能发动。那张卡的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(c50907446.FShaddollCondition)
	e1:SetOperation(c50907446.FShaddollOperation)
	c:RegisterEffect(e1)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetValue(c50907446.splimit)
	c:RegisterEffect(e2)
	-- ①：这张卡特殊召唤的场合，以场上1张表侧表示卡为对象才能发动。那张卡的效果无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(50907446,0))  --"效果无效"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,50907446)
	e3:SetTarget(c50907446.distg)
	e3:SetOperation(c50907446.disop)
	c:RegisterEffect(e3)
	-- ②：这张卡不会被战斗破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ③：这张卡被送去墓地的场合才能发动。从自己的卡组·墓地把1张「影依」卡加入手卡。那之后，选自己1张手卡丢弃。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(50907446,1))  --"加入手卡"
	e5:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,50907447)
	e5:SetTarget(c50907446.thtg)
	e5:SetOperation(c50907446.thop)
	c:RegisterEffect(e5)
end
-- 限制此卡只能通过融合召唤方式特殊召唤
function c50907446.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 检查是否存在可以作为无效化目标的场上表侧表示卡，并提示玩家选择要无效化的卡片
function c50907446.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断连锁中的对象是否为场上的表侧表示卡且满足无效化条件
	if chkc then return chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 检查是否存在可以作为无效化目标的场上表侧表示卡
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示选择要无效化的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家选择一张场上的表侧表示卡作为无效化的目标
	Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
-- 处理无效化目标卡的效果，使其效果无效并注册相关无效化效果
function c50907446.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的第一个目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使与目标卡相关的连锁效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 创建并注册使目标卡无效的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 创建并注册使目标卡效果无效的效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 如果目标卡是陷阱怪兽，则创建并注册使其陷阱怪兽效果无效的效果
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
end
-- 定义检索条件：必须是「影依」卡且可以加入手牌
function c50907446.thfilter(c)
	return c:IsSetCard(0x9d) and c:IsAbleToHand()
end
-- 检查是否存在符合条件的「影依」卡可以检索，并设置操作信息
function c50907446.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在符合条件的「影依」卡可以检索
	if chk==0 then return Duel.IsExistingMatchingCard(c50907446.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置将卡片送入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	-- 设置丢弃手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 执行检索「影依」卡并加入手牌，然后丢弃一张手卡的效果处理
function c50907446.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组和墓地中选择一张符合条件的「影依」卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c50907446.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	-- 如果有选中的卡片则将其送入手牌
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		-- 向对手展示刚加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
		-- 如果玩家成功将卡片加入手牌且手牌数量大于0
		if g:GetFirst():IsLocation(LOCATION_HAND) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 then
			-- 中断当前效果处理流程
			Duel.BreakEffect()
			-- 洗切玩家的手牌
			Duel.ShuffleHand(tp)
			-- 让玩家丢弃一张手牌
			Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD,nil)
		end
	end
end
-- 定义融合素材筛选条件：必须是「影依」系列且能作为融合素材
function c50907446.FShaddollFilter(c,fc)
	return c:IsFusionSetCard(0x9d) and c:IsCanBeFusionMaterial(fc)
end
-- 定义额外融合素材筛选条件：必须是表侧表示、非免疫效果且符合融合素材条件
function c50907446.FShaddollExFilter(c,fc,fe)
	return c:IsFaceup() and not c:IsImmuneToEffect(fe) and c50907446.FShaddollFilter(c,fc)
end
-- 定义第一个融合素材筛选条件：必须是「影依」系列且组合中存在第二个符合条件的素材，且两者属性不同
function c50907446.FShaddollFilter1(c,g)
	return c:IsFusionSetCard(0x9d) and g:IsExists(c50907446.FShaddollFilter2,1,c) and not g:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute())
end
-- 定义第二个融合素材筛选条件：必须是「影依」系列
function c50907446.FShaddollFilter2(c)
	return c:IsFusionSetCard(0x9d)
end
-- 定义融合素材组合筛选条件：检查是否存在满足融合条件的第二张素材卡
function c50907446.FShaddollSpFilter1(c,fc,tp,mg,exg,chkf)
	return mg:IsExists(c50907446.FShaddollSpFilter2,1,c,fc,tp,c,chkf)
		or (exg and exg:IsExists(c50907446.FShaddollSpFilter2,1,c,fc,tp,c,chkf))
end
-- 定义融合素材组合详细筛选条件：验证组合是否合法且满足融合召唤所需条件
function c50907446.FShaddollSpFilter2(c,fc,tp,mc,chkf)
	local sg=Group.FromCards(c,mc)
	-- 排除调弦之魔术师相关的非法组合
	if sg:IsExists(aux.TuneMagicianCheckX,1,nil,sg,EFFECT_TUNE_MAGICIAN_F) then return false end
	-- 检查融合素材是否满足必须成为融合素材的条件
	if not aux.MustMaterialCheck(sg,tp,EFFECT_MUST_BE_FMATERIAL) then return false end
	-- 检查是否有额外的融合条件检查函数且当前组合是否满足
	if aux.FCheckAdditional and not aux.FCheckAdditional(tp,sg,fc)
		-- 检查是否有额外的融合目标检查函数且当前组合是否满足
		or aux.FGoalCheckAdditional and not aux.FGoalCheckAdditional(tp,sg,fc) then return false end
	return ((c50907446.FShaddollFilter1(c,sg) and c50907446.FShaddollFilter2(mc))
		or (c50907446.FShaddollFilter1(mc,sg) and c50907446.FShaddollFilter2(c)))
		-- 检查额外怪兽区域是否有足够的空间进行融合召唤
		and (chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,sg,fc)>0)
end
-- 定义融合召唤条件检查函数：验证融合素材是否满足条件
function c50907446.FShaddollCondition(e,g,gc,chkf)
	-- 检查是否满足必须成为融合素材的基本条件
	if g==nil then return aux.MustMaterialCheck(nil,e:GetHandlerPlayer(),EFFECT_MUST_BE_FMATERIAL) end
	local c=e:GetHandler()
	local mg=g:Filter(c50907446.FShaddollFilter,nil,c)
	local tp=e:GetHandlerPlayer()
	-- 获取当前玩家的场地魔法卡
	local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	local exg=nil
	if fc and fc:IsHasEffect(81788994) and fc:IsCanRemoveCounter(tp,0x16,3,REASON_EFFECT) then
		local fe=fc:IsHasEffect(81788994)
		-- 获取对方场上符合条件的额外融合素材
		exg=Duel.GetMatchingGroup(c50907446.FShaddollExFilter,tp,0,LOCATION_MZONE,mg,c,fe)
	end
	if gc then
		if not mg:IsContains(gc) then return false end
		return c50907446.FShaddollSpFilter1(gc,c,tp,mg,exg,chkf)
	end
	return mg:IsExists(c50907446.FShaddollSpFilter1,1,nil,c,tp,mg,exg,chkf)
end
-- 定义融合召唤操作函数：选择并设置融合素材
function c50907446.FShaddollOperation(e,tp,eg,ep,ev,re,r,rp,gc,chkf)
	local c=e:GetHandler()
	local mg=eg:Filter(c50907446.FShaddollFilter,nil,c)
	-- 获取当前玩家的场地魔法卡
	local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	local exg=nil
	if fc and fc:IsHasEffect(81788994) and fc:IsCanRemoveCounter(tp,0x16,3,REASON_EFFECT) then
		local fe=fc:IsHasEffect(81788994)
		-- 获取对方场上符合条件的额外融合素材
		exg=Duel.GetMatchingGroup(c50907446.FShaddollExFilter,tp,0,LOCATION_MZONE,mg,c,fe)
	end
	local g=nil
	if gc then
		g=Group.FromCards(gc)
		mg:RemoveCard(gc)
	else
		-- 向玩家提示选择融合素材
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)  --"请选择要作为融合素材的卡"
		g=mg:FilterSelect(tp,c50907446.FShaddollSpFilter1,1,1,nil,c,tp,mg,exg,chkf)
		mg:Sub(g)
	end
	if exg and exg:IsExists(c50907446.FShaddollSpFilter2,1,nil,c,tp,g:GetFirst(),chkf)
		-- 询问玩家是否使用对方场上的怪兽作为融合素材
		and (mg:GetCount()==0 or (exg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(81788994,0)))) then  --"是否要把对方场上1只表侧表示怪兽作为融合素材？"
		fc:RemoveCounter(tp,0x16,3,REASON_EFFECT)
		-- 向玩家提示选择融合素材
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)  --"请选择要作为融合素材的卡"
		local sg=exg:FilterSelect(tp,c50907446.FShaddollSpFilter2,1,1,nil,c,tp,g:GetFirst(),chkf)
		g:Merge(sg)
	else
		-- 向玩家提示选择融合素材
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)  --"请选择要作为融合素材的卡"
		local sg=mg:FilterSelect(tp,c50907446.FShaddollSpFilter2,1,1,nil,c,tp,g:GetFirst(),chkf)
		g:Merge(sg)
	end
	-- 设置选定的融合素材
	Duel.SetFusionMaterial(g)
end
