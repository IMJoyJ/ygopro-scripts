--紋章獣スタット・ホエール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，丢弃1张手卡才能发动。从卡组把2张「纹章」魔法·陷阱卡加入手卡。
-- ②：把墓地的这张卡除外，以自己墓地2只同名「纹章兽」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己若非以只用原本卡名包含「纹章兽」或「No.」的怪兽为素材的超量召唤则不能从额外卡组把怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果：注册这张卡召唤·特殊召唤成功时检索2张「纹章」魔陷的效果，以及在墓地发动特殊召唤墓地2只同名「纹章兽」的效果
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
	-- 设置效果②的发动代价为将墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 效果①的代价值：检查手牌中是否有可丢弃的卡，并丢弃1张手牌
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查手牌中是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌中选择1张卡作为发动代价丢弃到墓地
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：卡名包含「纹章」的魔法·陷阱卡且可以加入手牌
function s.thfilter(c)
	return c:IsSetCard(0x92) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果①的发动准备：检查卡组中是否存在至少2张满足条件的「纹章」魔陷，并设置检索的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查卡组中是否存在至少2张满足条件的「纹章」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,2,nil) end
	-- 设置当前连锁的操作信息为：从卡组将2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组选择2张「纹章」魔法·陷阱卡加入手牌，并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足条件的「纹章」魔法·陷阱卡
	local sg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if sg:GetCount()<2 then return end
	-- 向玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local g=sg:Select(tp,2,2,nil)
	-- 将选中的卡因效果加入手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 将加入手牌的卡给对方玩家确认
	Duel.ConfirmCards(1-tp,g)
end
-- 过滤条件：墓地中可以守备表示特殊召唤且可以作为效果对象的「纹章兽」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x76) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and c:IsCanBeEffectTarget(e)
end
-- 过滤条件：选择的卡片组中所有卡片的卡名必须相同
function s.fselect(g)
	return g:GetClassCount(Card.GetCode)==1
end
-- 效果②的发动准备：检查怪兽区域空位，选择墓地2只同名的「纹章兽」怪兽作为效果对象，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	-- 获取自己墓地中除这张卡以外所有满足特殊召唤条件的「纹章兽」怪兽
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,c,e,tp)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc~=c and s.spfilter(chkc,e,tp) end
	-- 获取自己场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return ft>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133) and g:CheckSubGroup(s.fselect,2,2) end
	-- 向玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local tg=g:SelectSubGroup(tp,s.fselect,false,2,2)
	-- 将选中的怪兽注册为当前连锁的效果对象
	Duel.SetTargetCard(tg)
	-- 设置当前连锁的操作信息为：将选中的怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,tg:GetCount(),0,0)
end
-- 效果②的效果处理：注册“非以原本卡名含「纹章兽」或「No.」的怪兽为素材的超量召唤则不能从额外卡组特殊召唤”的限制，并将作为对象的2只怪兽守备表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个效果的发动后，直到回合结束时自己若非以只用原本卡名包含「纹章兽」或「No.」的怪兽为素材的超量召唤则不能从额外卡组把怪兽特殊召唤。（限制非超量怪兽的特殊召唤）
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中为玩家注册不能从额外卡组进行非超量召唤的特殊召唤的限制效果
	Duel.RegisterEffect(e1,tp)
	-- 这个效果的发动后，直到回合结束时自己若非以只用原本卡名包含「纹章兽」或「No.」的怪兽为素材的超量召唤则不能从额外卡组把怪兽特殊召唤。（限制非特定怪兽作为超量素材）
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(0x7f,0x7f)
	e2:SetTarget(s.tlmtg)
	e2:SetValue(s.tlmval)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中为玩家注册超量素材限制效果，使得非「纹章兽」或「No.」怪兽不能作为超量素材
	Duel.RegisterEffect(e2,tp)
	-- 那些怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己若非以只用原本卡名包含「纹章兽」或「No.」的怪兽为素材的超量召唤则不能从额外卡组把怪兽特殊召唤。
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(67120578)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中为玩家注册限制标记效果（用于与其他卡片效果交互或记录状态）
	Duel.RegisterEffect(e3,tp)
	-- 获取当前自己场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取当前连锁中仍与效果相关联，且不受「王家长眠之谷」影响的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(aux.NecroValleyFilter(Card.IsRelateToEffect),nil,e)
	if #g==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if #g>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if #g>ft then
		-- 向玩家发送提示信息：请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	-- 将符合条件的怪兽以守备表示特殊召唤到自己场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 限制条件：不能从额外卡组特殊召唤非超量怪兽
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and bit.band(sumtype,SUMMON_TYPE_XYZ)~=SUMMON_TYPE_XYZ
end
-- 限制条件：原本卡名不包含「纹章兽」或「No.」的怪兽
function s.tlmtg(e,c)
	return not c:IsOriginalSetCard(0x76,0x48)
end
-- 限制条件：不能作为自己进行超量召唤时的超量素材
function s.tlmval(e,c)
	if not c then return false end
	return c:GetControler()==e:GetOwnerPlayer()
end
