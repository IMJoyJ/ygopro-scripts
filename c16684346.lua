--プロキシー・ホース
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上的这张卡作为电子界族怪兽的连接素材的场合，手卡的电子界族怪兽也能有最多1只作为连接素材。
-- ②：自己结束阶段把墓地的这张卡除外，以包含电子界族连接怪兽的自己墓地2只连接怪兽为对象才能发动。那些怪兽回到额外卡组。
function c16684346.initial_effect(c)
	-- ①：把自己场上的这张卡作为电子界族怪兽的连接素材的场合，手卡的电子界族怪兽也能有最多1只作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16684346,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND,0)
	-- 设置效果目标为手卡中种族为电子界的怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_CYBERSE))
	e1:SetCountLimit(1,16684346)
	e1:SetValue(c16684346.matval)
	c:RegisterEffect(e1)
	-- ②：自己结束阶段把墓地的这张卡除外，以包含电子界族连接怪兽的自己墓地2只连接怪兽为对象才能发动。那些怪兽回到额外卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16684346,1))
	e2:SetCategory(CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,16684347)
	e2:SetCondition(c16684346.tdcon)
	-- 将此卡从墓地除外作为发动cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c16684346.tdtg)
	e2:SetOperation(c16684346.tdop)
	c:RegisterEffect(e2)
end
-- 检查手卡中是否有其他卡具有额外连接素材效果且该效果与当前连接怪兽相关
function c16684346.exmatcheck(c,lc,tp)
	if not c:IsLocation(LOCATION_HAND) then return false end
	local le={c:IsHasEffect(EFFECT_EXTRA_LINK_MATERIAL,tp)}
	for _,te in pairs(le) do
		local f=te:GetValue()
		local related,valid=f(te,lc,nil,c,tp)
		if related and not te:GetHandler():IsCode(16684346) then return false end
	end
	return true
end
-- 判断是否可以将手卡中的电子界族怪兽作为连接素材
function c16684346.matval(e,lc,mg,c,tp)
	if not lc:IsRace(RACE_CYBERSE) then return false,nil end
	return true,not mg or mg:IsContains(e:GetHandler()) and not mg:IsExists(c16684346.exmatcheck,1,nil,lc,tp)
end
-- 判断是否为自己的结束阶段
function c16684346.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 过滤墓地中可以回到额外卡组的连接怪兽
function c16684346.tdfilter(c,e)
	return c:IsType(TYPE_LINK) and c:IsAbleToExtra() and c:IsCanBeEffectTarget(e)
end
-- 检查选中的怪兽组中是否包含电子界族怪兽
function c16684346.fselect(g)
	return g:IsExists(Card.IsRace,1,nil,RACE_CYBERSE)
end
-- 设置发动时的目标怪兽组并设置操作信息
function c16684346.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取墓地中所有可回到额外卡组的连接怪兽
	local g1=Duel.GetMatchingGroup(c16684346.tdfilter,tp,LOCATION_GRAVE,0,e:GetHandler(),e)
	if chk==0 then return g1:CheckSubGroup(c16684346.fselect,2,2) end
	-- 获取墓地中所有可回到额外卡组的连接怪兽用于选择
	local g2=Duel.GetMatchingGroup(c16684346.tdfilter,tp,LOCATION_GRAVE,0,nil,e)
	local sg=g2:SelectSubGroup(tp,c16684346.fselect,false,2,2)
	-- 设置连锁处理的目标卡片组
	Duel.SetTargetCard(sg)
	-- 设置操作信息为将目标怪兽送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,sg,2,0,0)
end
-- 执行将目标怪兽送回额外卡组的操作
function c16684346.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设置的目标卡片组并筛选出与效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		-- 将符合条件的怪兽送回额外卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
