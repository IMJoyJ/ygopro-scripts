--ソウル・リゾネーター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。除「灵魂共鸣者」外的1只4星以下的恶魔族怪兽从卡组加入手卡。这个效果的发动后，直到回合结束时自己不是暗属性同调怪兽不能从额外卡组特殊召唤。
-- ②：自己场上有着「红莲魔龙」或者有那个卡名记述的同调怪兽存在，自己场上的卡被效果破坏的场合，可以作为代替把墓地的这张卡除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含效果①（召唤/特殊召唤成功时检索恶魔族怪兽并施加额外卡组特召限制）和效果②（墓地代破效果）。
function s.initial_effect(c)
	-- 记录这张卡记述了「红莲魔龙」（卡号70902743）的卡名。
	aux.AddCodeList(c,70902743)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。除「灵魂共鸣者」外的1只4星以下的恶魔族怪兽从卡组加入手卡。这个效果的发动后，直到回合结束时自己不是暗属性同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己场上有着「红莲魔龙」或者有那个卡名记述的同调怪兽存在，自己场上的卡被效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.desreptg)
	e3:SetValue(s.desrepval)
	e3:SetOperation(s.desrepop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中除「灵魂共鸣者」以外的4星以下恶魔族怪兽且能加入手牌的卡。
function s.thfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsLevelBelow(4) and not c:IsCode(id) and c:IsAbleToHand()
end
-- 效果①的触发目标检测与操作信息注册。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的恶魔族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息为从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的执行逻辑，将卡片加入手牌并注册“不能从额外卡组特殊召唤暗属性同调怪兽以外的怪兽”的限制。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个效果的发动后，直到回合结束时自己不是暗属性同调怪兽不能从额外卡组特殊召唤。②：自己场上有着「红莲魔龙」或者有那个卡名记述的同调怪兽存在，自己场上的卡被效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 注册限制玩家特殊召唤的效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特召的过滤函数，限制从额外卡组特殊召唤非暗属性同调怪兽。
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO))
end
-- 过滤自己场上因效果被破坏的卡。
function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField()
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 过滤自己场上表侧表示的「红莲魔龙」或记述了其卡名的同调怪兽。
function s.confilter(c)
	-- 检查卡片是否为表侧表示的同调怪兽，且其自身为「红莲魔龙」或其卡名记述了「红莲魔龙」。
	return c:IsType(TYPE_SYNCHRO) and c:IsFaceup() and aux.IsCodeOrListed(c,70902743)
end
-- 代替破坏效果的触发条件检测，检查墓地的这张卡是否能除外、场上是否有卡被效果破坏，以及场上是否存在符合条件的同调怪兽。
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp)
		-- 检查自己场上是否存在「红莲魔龙」或有那个卡名记述的同调怪兽。
		and Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 询问玩家是否发动代替破坏的效果。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 确定代替破坏的适用对象（自己场上因效果被破坏的卡）。
function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的执行逻辑，将墓地的这张卡除外。
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡因效果表侧表示除外。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
