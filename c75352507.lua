--蕾禍ノ玄神憑月
-- 效果：
-- 昆虫族·植物族·爬虫类族怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己墓地把最多2只怪兽除外，以那个数量的对方场上的魔法·陷阱卡为对象才能发动。那些卡破坏。
-- ②：这张卡在墓地存在的场合，以自己场上1只昆虫族·植物族·爬虫类族怪兽为对象才能发动。那只怪兽回到卡组最下面，这张卡特殊召唤。这个回合，自己不是昆虫族·植物族·爬虫类族怪兽不能特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- 添加连接召唤手续：昆虫族·植物族·爬虫类族怪兽2只以上。
	aux.AddLinkProcedure(c,s.lkfilter,2,99)
	c:EnableReviveLimit()
	-- ①：从自己墓地把最多2只怪兽除外，以那个数量的对方场上的魔法·陷阱卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"魔陷破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己场上1只昆虫族·植物族·爬虫类族怪兽为对象才能发动。那只怪兽回到卡组最下面，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"墓地特殊召唤"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 连接素材的过滤条件：昆虫族、植物族或爬虫类族怪兽。
function s.lkfilter(c)
	return c:IsLinkRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE)
end
-- 墓地除外cost的过滤条件：怪兽卡且可以作为cost除外。
function s.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果①的发动代价（cost）处理函数，设置标志以在target中进行除外处理。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 效果①的发动准备（target）处理函数，选择要除外的怪兽并选择对应数量的对方场上的魔法·陷阱卡作为对象。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 检查自己墓地是否存在至少1只可除外的怪兽，且对方场上是否存在至少1张魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 获取对方场上可作为对象的魔法·陷阱卡数量。
	local rt=Duel.GetTargetCount(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	if rt>2 then rt=2 end
	-- 玩家选择1到rt张（最多2张）自己墓地的怪兽。
	local rg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,rt,nil)
	-- 将选择的怪兽表侧表示除外，并返回实际除外的数量。
	local cg=Duel.Remove(rg,POS_FACEUP,REASON_COST)
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择与除外数量相同（cg张）的对方场上的魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_ONFIELD,cg,cg,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置效果处理信息：破坏g中的cg张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,cg,0,0)
end
-- 效果①的效果处理（operation）函数，破坏作为对象的卡。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的卡片组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local rg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if #rg>0 then
		-- 破坏仍存在于场上的对象卡。
		Duel.Destroy(rg,REASON_EFFECT)
	end
end
-- 效果②回到卡组的对象过滤条件：自己场上表侧表示的昆虫族·植物族·爬虫类族怪兽，且该卡离开后能让出怪兽区域空格，且能回到卡组。
function s.tdfilter(c,tp)
	-- 检查卡片是否为表侧表示的昆虫族/植物族/爬虫类族怪兽，且其离开后有可用的怪兽区域，且可以回到卡组。
	return c:IsFaceup() and c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE) and Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToDeck()
end
-- 效果②的发动准备（target）处理函数，选择自己场上1只满足条件的怪兽作为对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tdfilter(chkc,tp) end
	-- 检查自己场上是否存在可作为对象的怪兽，且墓地的这张卡是否可以特殊召唤。
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	-- 提示玩家选择要回到卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己场上1只满足条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置效果处理信息：将选择的对象怪兽送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	-- 设置效果处理信息：将墓地的这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的效果处理（operation）函数，将对象怪兽回到卡组最下面，特殊召唤这张卡，并适用特殊召唤限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍适用效果，若是，则将其送回持有者卡组最下面并判断是否成功。
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
		-- 检查怪兽区域是否有空位，且墓地的这张卡是否仍适用效果。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
		-- 将这张卡在自己场上表侧表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己不是昆虫族·植物族·爬虫类族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该特殊召唤限制效果给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制只能特殊召唤昆虫族·植物族·爬虫类族怪兽。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE)
end
