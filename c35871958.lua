--ゴーストリック・フェスティバル
-- 效果：
-- 连接怪兽以外的「鬼计」怪兽1只
-- 这张卡连接召唤的场合，自己场上的里侧表示的「鬼计」怪兽也能作为连接素材。这个卡名的②的效果1回合只能使用1次。
-- ①：只要场地区域有「鬼计」卡存在，自己的「鬼计」怪兽可以直接攻击。
-- ②：对方怪兽的攻击宣言时，把这张卡解放才能发动。从卡组把1只「鬼计」怪兽里侧守备表示特殊召唤。
function c35871958.initial_effect(c)
	-- 为该卡添加连接召唤手续：可用1只满足matfilter条件的怪兽作为连接素材，即连接怪兽以外的「鬼计」怪兽；配合下一行设置的EFFECT_FLAG_SET_AVAILABLE，里侧表示的「鬼计」怪兽也能作为连接素材。
	local e0=aux.AddLinkProcedure(c,c35871958.matfilter,1,1)
	e0:SetProperty(e0:GetProperty()|EFFECT_FLAG_SET_AVAILABLE)
	c:EnableReviveLimit()
	-- ①：只要场地区域有「鬼计」卡存在，自己的「鬼计」怪兽可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(c35871958.dacon)
	e1:SetTarget(c35871958.datg)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：对方怪兽的攻击宣言时，把这张卡解放才能发动。从卡组把1只「鬼计」怪兽里侧守备表示特殊召唤。
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
-- 定义连接素材过滤条件：该怪兽作为连接素材时视为「鬼计」怪兽，且其原本类型不是连接怪兽（IsLinkType按原本类型判定，避免魔陷区的怪兽卡用当前类型误导）。
function c35871958.matfilter(c)
	return c:IsLinkSetCard(0x8d) and not c:IsLinkType(TYPE_LINK)
end
-- 定义过滤函数：用于判断场地区域是否存在表侧表示的「鬼计」卡，条件为卡片表侧表示且属于「鬼计」系列。
function c35871958.dacfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 直接攻击效果的发动条件：检查效果持有者视角下，双方场地区域合计是否存在至少1张满足dacfilter的卡，即表侧表示的「鬼计」卡。
function c35871958.dacon(e)
	-- 调用Duel.IsExistingMatchingCard，在双方场地区域（自己与对方的场地魔法区域）搜索是否存在至少1张表侧表示的「鬼计」卡，存在则条件成立。
	return Duel.IsExistingMatchingCard(c35871958.dacfilter,e:GetHandlerPlayer(),LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 直接攻击效果的适用对象筛选：自己场上表侧表示的「鬼计」怪兽才能获得直接攻击能力。
function c35871958.datg(e,c)
	return c:IsSetCard(0x8d)
end
-- ②效果的发动条件：效果发动者不是当前回合玩家，即当前是对方回合，且对方怪兽进行了攻击宣言。
function c35871958.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前效果控制者tp与回合玩家不同，确保是在对方攻击宣言时（攻击宣言的一方为回合玩家）才能发动。
	return tp~=Duel.GetTurnPlayer()
end
-- ②效果的发动代价：将这张卡解放；chk==0时只检查这张卡是否可以解放，实际代价执行时进行解放。
function c35871958.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以解放为代价（REASON_COST）将这张卡送去墓地，完成发动所需支付的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义特殊召唤候选卡的条件：必须是「鬼计」怪兽，并且可以被当前效果以里侧守备表示特殊召唤（检查苏生限制和召唤条件）。
function c35871958.spfilter(c,e,tp)
	return c:IsSetCard(0x8d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- ②效果发动时的目标检查：确认解放这张卡后自己场上存在空余的怪兽区，且卡组中存在满足spfilter的「鬼计」怪兽，满足才可发动。
function c35871958.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查（chk==0）时，判断解放这张卡后自己场上是否仍有可用的怪兽区。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 同时确认卡组中是否存在至少1只满足spfilter条件的「鬼计」怪兽，作为特殊召唤的对象。
		and Duel.IsExistingMatchingCard(c35871958.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向系统登记操作信息：本次效果将把卡组中的1只怪兽特殊召唤，用于连锁相关检测与效果互动。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的解决处理：先确认自己场上仍有空余怪兽区，然后从卡组选择1只「鬼计」怪兽里侧守备表示特殊召唤，并向对方玩家确认该卡。
function c35871958.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查自己场上是否有可用的怪兽区，若没有则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作者显示选择提示“请选择要特殊召唤的卡”，用于选择卡片的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己卡组中选择1张满足spfilter条件的「鬼计」怪兽，作为即将特殊召唤的卡。
	local g=Duel.SelectMatchingCard(tp,c35871958.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以里侧守备表示特殊召唤到自己的怪兽区（不检查召唤条件、不限制苏生，若失败则数量为0）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 将里侧守备表示特殊召唤的卡展示给对方玩家确认，以符合规则中里侧特殊召唤需向对手公开卡片的流程。
		Duel.ConfirmCards(1-tp,g)
	end
end
