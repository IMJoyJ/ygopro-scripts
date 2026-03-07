--ゴーストリック・フェスティバル
-- 效果：
-- 连接怪兽以外的「鬼计」怪兽1只
-- 这张卡连接召唤的场合，自己场上的里侧表示的「鬼计」怪兽也能作为连接素材。这个卡名的②的效果1回合只能使用1次。
-- ①：只要场地区域有「鬼计」卡存在，自己的「鬼计」怪兽可以直接攻击。
-- ②：对方怪兽的攻击宣言时，把这张卡解放才能发动。从卡组把1只「鬼计」怪兽里侧守备表示特殊召唤。
function c35871958.initial_effect(c)
	-- 添加连接召唤手续，要求使用1张满足条件的怪兽作为连接素材
	local e0=aux.AddLinkProcedure(c,c35871958.matfilter,1,1)
	e0:SetProperty(e0:GetProperty()|EFFECT_FLAG_SET_AVAILABLE)
	c:EnableReviveLimit()
	-- 只要场地区域有「鬼计」卡存在，自己的「鬼计」怪兽可以直接攻击
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(c35871958.dacon)
	e1:SetTarget(c35871958.datg)
	c:RegisterEffect(e1)
	-- 对方怪兽的攻击宣言时，把这张卡解放才能发动。从卡组把1只「鬼计」怪兽里侧守备表示特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35871958,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,35871958)
	e2:SetCondition(c35871958.spcon)
	e2:SetCost(c35871958.spcost)
	e2:SetTarget(c35871958.sptg)
	e2:SetOperation(c35871958.spop)
	c:RegisterEffect(e2)
end
-- 连接素材过滤器，筛选「鬼计」卡且不是连接怪兽
function c35871958.matfilter(c)
	return c:IsLinkSetCard(0x8d) and not c:IsLinkType(TYPE_LINK)
end
-- 场地区域「鬼计」卡过滤器，筛选里侧表示的「鬼计」卡
function c35871958.dacfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 判断场地区域是否存在「鬼计」卡
function c35871958.dacon(e)
	-- 检查场地区域是否存在至少1张里侧表示的「鬼计」卡
	return Duel.IsExistingMatchingCard(c35871958.dacfilter,e:GetHandlerPlayer(),LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 设置直接攻击目标为「鬼计」怪兽
function c35871958.datg(e,c)
	return c:IsSetCard(0x8d)
end
-- 攻击宣言时的发动条件，确保是对方回合
function c35871958.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return tp~=Duel.GetTurnPlayer()
end
-- 发动时的费用，解放自身
function c35871958.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以解放自身为代价发动效果
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 特殊召唤过滤器，筛选「鬼计」怪兽并可里侧守备表示特殊召唤
function c35871958.spfilter(c,e,tp)
	return c:IsSetCard(0x8d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 设置发动时的处理条件，检查是否有怪兽区空位并确认卡组存在满足条件的怪兽
function c35871958.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有怪兽区空位
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查卡组是否存在满足条件的「鬼计」怪兽
		and Duel.IsExistingMatchingCard(c35871958.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将特殊召唤1只「鬼计」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 发动效果的处理程序，选择并特殊召唤1只「鬼计」怪兽
function c35871958.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有怪兽区空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件的「鬼计」怪兽
	local g=Duel.SelectMatchingCard(tp,c35871958.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以里侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方确认特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
