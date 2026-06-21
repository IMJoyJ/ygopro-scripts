--ウィッチクラフト・バイスマスター
-- 效果：
-- 「魔女术」怪兽＋魔法师族怪兽
-- ①：融合怪兽以外的魔法师族怪兽或者魔法卡的效果发动时，可以从以下效果选择1个发动。「魔女术代理师傅」的以下效果1回合各能选择1次。
-- ●选场上1张卡破坏。
-- ●从手卡·卡组把1只6星以下的「魔女术」怪兽特殊召唤。
-- ●从自己墓地选1张「魔女术」魔法·陷阱卡加入手卡。
function c9603252.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，以1只「魔女术」怪兽和1只魔法师族怪兽为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x128),c9603252.matfilter,true)
	-- ①：融合怪兽以外的魔法师族怪兽或者魔法卡的效果发动时，可以从以下效果选择1个发动。「魔女术代理师傅」的以下效果1回合各能选择1次。●选场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9603252,0))  --"场上1张卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,9603252)
	e1:SetCondition(c9603252.condition)
	e1:SetTarget(c9603252.destg)
	e1:SetOperation(c9603252.desop)
	c:RegisterEffect(e1)
	-- ①：融合怪兽以外的魔法师族怪兽或者魔法卡的效果发动时，可以从以下效果选择1个发动。「魔女术代理师傅」的以下效果1回合各能选择1次。●从手卡·卡组把1只6星以下的「魔女术」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9603252,1))  --"从手卡·卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,9603253)
	e2:SetCondition(c9603252.condition)
	e2:SetTarget(c9603252.sptg)
	e2:SetOperation(c9603252.spop)
	c:RegisterEffect(e2)
	-- ①：融合怪兽以外的魔法师族怪兽或者魔法卡的效果发动时，可以从以下效果选择1个发动。「魔女术代理师傅」的以下效果1回合各能选择1次。●从自己墓地选1张「魔女术」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9603252,2))  --"从墓地加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,9603254)
	e3:SetCondition(c9603252.condition)
	e3:SetTarget(c9603252.thtg)
	e3:SetOperation(c9603252.thop)
	c:RegisterEffect(e3)
end
-- 融合素材过滤：检查怪兽是否为魔法师族怪兽
function c9603252.matfilter(c)
	return c:IsRace(RACE_SPELLCASTER)
end
-- 效果发动条件：当前连锁中发动的效果是融合怪兽以外的魔法师族怪兽的效果、或者是魔法卡的效果
function c9603252.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁发生位置所属卡片的种族
	local race=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_RACE)
	return (re:IsActiveType(TYPE_MONSTER) and race&RACE_SPELLCASTER>0 and not re:IsActiveType(TYPE_FUSION))
		or re:IsActiveType(TYPE_SPELL)
end
-- 效果目标：检查场上是否有可以破坏的卡并设置破坏的操作信息
function c9603252.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可以破坏的卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向对方玩家提示已选择发动该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 获取场上的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁处理的操作信息为破坏场上的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果执行：破坏场上1张卡
function c9603252.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上的1张卡
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 为选中的卡片显示选为对象的动画效果
		Duel.HintSelection(g)
		-- 将选中的卡片破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 特殊召唤怪兽过滤：检查怪兽是否为手卡·卡组中6星以下的「魔女术」怪兽且可以特殊召唤
function c9603252.spfilter(c,e,tp)
	return c:IsSetCard(0x128) and c:IsLevelBelow(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标：检查是否可以从手卡·卡组特殊召唤6星以下的「魔女术」怪兽并设置特殊召唤的操作信息
function c9603252.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在符合条件的特殊召唤怪兽
		and Duel.IsExistingMatchingCard(c9603252.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 向对方玩家提示已选择发动该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁处理的操作信息为特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果执行：从手卡·卡组特殊召唤1只6星以下的「魔女术」怪兽
function c9603252.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果怪兽区域没有空位则结束效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡·卡组选择1只满足特殊召唤条件的「魔女术」怪兽
	local g=Duel.SelectMatchingCard(tp,c9603252.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 回收卡片过滤：检查是否为自己墓地的「魔女术」魔法·陷阱卡且可以加入手卡
function c9603252.thfilter(c)
	return c:IsSetCard(0x128) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果目标：检查墓地是否存在可以加入手卡的卡并设置加入手卡的操作信息
function c9603252.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地中是否存在可以加入手卡的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c9603252.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向对方玩家提示已选择发动该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁处理的操作信息为把墓地的卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果执行：从自己墓地选择1张「魔女术」魔法·陷阱卡加入手卡
function c9603252.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己墓地选择1张「魔女术」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c9603252.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 为选中的卡片显示选为对象的动画效果
		Duel.HintSelection(g)
		-- 将选中的卡片送回手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
