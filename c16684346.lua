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
	-- 设置可作为额外连接素材的手卡怪兽筛选条件：必须是电子界族怪兽。
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
	-- 设置发动代价：把墓地中的这张卡除外作为发动②效果的cost。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c16684346.tdtg)
	e2:SetOperation(c16684346.tdop)
	c:RegisterEffect(e2)
end
-- 检查手卡怪兽是否已被其他“可作为额外连接素材”的效果占用；若存在除代理马以外的同类效果则返回false，用于避免多个额外素材效果叠加。
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
-- 代理马①效果的Value函数：连接怪兽必须为电子界族；当素材组中存在代理马且没有其他手卡怪兽被同类额外素材效果占用时，允许将手卡电子界族怪兽作为额外连接素材。
function c16684346.matval(e,lc,mg,c,tp)
	if not lc:IsRace(RACE_CYBERSE) then return false,nil end
	return true,not mg or mg:IsContains(e:GetHandler()) and not mg:IsExists(c16684346.exmatcheck,1,nil,lc,tp)
end
-- ②效果的发动条件函数：只在当前回合玩家是效果持有者时满足，即自己结束阶段。
function c16684346.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己，以此限定②效果只能在自己结束阶段发动。
	return Duel.GetTurnPlayer()==tp
end
-- 墓地中可作为②效果对象的连接怪兽的筛选条件：必须是连接怪兽、能够返回额外卡组、且能够成为效果对象。
function c16684346.tdfilter(c,e)
	return c:IsType(TYPE_LINK) and c:IsAbleToExtra() and c:IsCanBeEffectTarget(e)
end
-- 从选出的2只连接怪兽中确认至少包含1只电子界族连接怪兽，对应“包含电子界族连接怪兽”的要求。
function c16684346.fselect(g)
	return g:IsExists(Card.IsRace,1,nil,RACE_CYBERSE)
end
-- ②效果的发动时处理：从自己墓地选择2只满足条件的连接怪兽（其中至少1只为电子界族），将其设为对象并设置返回额外卡组的操作信息。
function c16684346.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己墓地中满足对象条件的连接怪兽，且排除代理马自身，用于检查是否能够发动。
	local g1=Duel.GetMatchingGroup(c16684346.tdfilter,tp,LOCATION_GRAVE,0,e:GetHandler(),e)
	if chk==0 then return g1:CheckSubGroup(c16684346.fselect,2,2) end
	-- 获取自己墓地中所有满足对象条件的连接怪兽（不排除任何卡），用于实际选择对象。
	local g2=Duel.GetMatchingGroup(c16684346.tdfilter,tp,LOCATION_GRAVE,0,nil,e)
	local sg=g2:SelectSubGroup(tp,c16684346.fselect,false,2,2)
	-- 将玩家选中的2只连接怪兽设定为当前连锁的对象。
	Duel.SetTargetCard(sg)
	-- 设置操作信息：将2只对象卡返回额外卡组，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,sg,2,0,0)
end
-- ②效果处理时：取仍与该效果关联的对象卡，将其返回持有者的额外卡组并触发洗牌处理。
function c16684346.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁的对象中筛选出仍然与该效果关联的卡（排除已离场或失效的卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		-- 以效果原因将关联卡返回持有者的额外卡组（并触发相应的洗牌/额外卡组处理）。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
