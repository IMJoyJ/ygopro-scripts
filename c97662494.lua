--紋章獣スタット・ホエール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，丢弃1张手卡才能发动。从卡组把2张「纹章」魔法·陷阱卡加入手卡。
-- ②：把墓地的这张卡除外，以自己墓地2只同名「纹章兽」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己若非以只用原本卡名包含「纹章兽」或「No.」的怪兽为素材的超量召唤则不能从额外卡组把怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果注册，包含召唤·特殊召唤时从卡组检索2张「纹章」魔陷效果，以及墓地除外特召2只同名怪兽效果的注册
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，丢弃1张手卡才能发动。从卡组把2张「纹章」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以自己墓地2只同名「纹章兽」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己若非以只用原本卡名包含「纹章兽」或「No.」的怪兽为素材的超量召唤则不能从额外卡组把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 效果Cost注册：把墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- ①效果（检索「纹章」魔陷）的Cost支付函数：检查并丢弃1张手卡
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌中是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择丢弃1张手卡作为Cost
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：卡组中的「纹章」魔法·陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0x92) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果的发动准备：检查卡组是否存在至少2张「纹章」魔法·陷阱卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少2张符合检索条件的「纹章」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,2,nil) end
	-- 设置效果处理的分类为加入手牌，目标为卡组中的2张卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组中选择2张「纹章」魔法·陷阱卡加入手牌，并向对方展示
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有符合条件的「纹章」魔法·陷阱卡
	local sg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if sg:GetCount()<2 then return end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local g=sg:Select(tp,2,2,nil)
	-- 将选择的卡片加入玩家手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 向对方展示加入手牌的卡片
	Duel.ConfirmCards(1-tp,g)
end
-- 过滤条件：墓地中可以守备表示特殊召唤的「纹章兽」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x76) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and c:IsCanBeEffectTarget(e)
end
-- 同名卡检测条件：卡片组中所有卡片的卡号相同
function s.fselect(g)
	return g:GetClassCount(Card.GetCode)==1
end
-- ②效果（特殊召唤墓地同名怪兽）的发动准备与目标选择
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	-- 获取墓地中（不含自身）所有符合条件的「纹章兽」怪兽
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,c,e,tp)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc~=c and s.spfilter(chkc,e,tp) end
	-- 获取自己场上空闲的怪兽区域格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return ft>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133) and g:CheckSubGroup(s.fselect,2,2) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local tg=g:SelectSubGroup(tp,s.fselect,false,2,2)
	-- 将选择的怪兽设置为连锁效果的对象
	Duel.SetTargetCard(tg)
	-- 设置效果处理的分类为特殊召唤，目标为所选择的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,tg:GetCount(),0,0)
end
-- ②效果的处理：注册额外卡组特殊召唤限制，并将选择的对象怪兽守备表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个效果的发动后，直到回合结束时自己若非超量召唤则不能从额外卡组把怪兽特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能特殊召唤非超量怪兽”的额外特召限制效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 若非以只用原本卡名包含「纹章兽」或「No.」的怪兽为素材的超量召唤则不能从额外卡组把怪兽特殊召唤
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(0x7f,0x7f)
	e2:SetTarget(s.tlmtg)
	e2:SetValue(s.tlmval)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将“特定怪兽不能作为超量素材”的效果注册给玩家，用来限制超量素材卡名
	Duel.RegisterEffect(e2,tp)
	-- 若非以只用原本卡名包含「纹章兽」或「No.」的怪兽为素材的超量召唤的额外召唤手续限制辅助效果
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(67120578)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册对应的超量素材过滤辅助状态
	Duel.RegisterEffect(e3,tp)
	-- 获取自己场上空闲的怪兽区域格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取当前连锁中仍与效果关联且未受王家长眠之谷影响的卡片
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if #g==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if #g>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if #g>ft then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	-- 将选择的怪兽守备表示特殊召唤
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 限制过滤条件：只能从额外卡组特殊召唤超量怪兽
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and bit.band(sumtype,SUMMON_TYPE_XYZ)~=SUMMON_TYPE_XYZ
end
-- 素材限制过滤条件：原本卡名不包含「纹章兽」且不包含「No.」的怪兽
function s.tlmtg(e,c)
	return not c:IsOriginalSetCard(0x76,0x48)
end
-- 素材限制值设定：阻止这些怪兽作为自己超量召唤的素材
function s.tlmval(e,c)
	if not c then return false end
	return c:GetControler()==e:GetOwnerPlayer()
end
