--方界超帝インディオラ・デス・ボルト
-- 效果：
-- 这张卡不能通常召唤。把自己场上3只「方界」怪兽送去墓地的场合才能特殊召唤。
-- ①：这个方法特殊召唤的这张卡的攻击力上升2400。
-- ②：这张卡从手卡的特殊召唤成功的场合发动。给与对方800伤害。
-- ③：这张卡被对方送去墓地的场合，以自己墓地最多3只「方界」怪兽为对象才能发动。那些怪兽特殊召唤。那之后，可以从自己的卡组·墓地选1张「方界」卡加入手卡。
function c3775068.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文：这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 效果原文：把自己场上3只「方界」怪兽送去墓地的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c3775068.sprcon)
	e2:SetTarget(c3775068.sprtg)
	e2:SetOperation(c3775068.sprop)
	c:RegisterEffect(e2)
	-- 效果原文：②：这张卡从手卡的特殊召唤成功的场合发动。给与对方800伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(3775068,0))  --"效果伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c3775068.damcon)
	e3:SetTarget(c3775068.damtg)
	e3:SetOperation(c3775068.damop)
	c:RegisterEffect(e3)
	-- 效果原文：③：这张卡被对方送去墓地的场合，以自己墓地最多3只「方界」怪兽为对象才能发动。那些怪兽特殊召唤。那之后，可以从自己的卡组·墓地选1张「方界」卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(3775068,1))  --"特殊召唤墓地怪兽"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c3775068.spcon)
	e4:SetTarget(c3775068.sptg)
	e4:SetOperation(c3775068.spop)
	c:RegisterEffect(e4)
end
-- 规则层面：定义过滤条件，用于筛选场上满足条件的「方界」怪兽（必须正面表示、属于「方界」卡组、可以作为cost送去墓地）
function c3775068.spcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe3) and c:IsAbleToGraveAsCost()
end
-- 规则层面：检查玩家场上是否有3只满足条件的「方界」怪兽，用于判断是否满足特殊召唤条件
function c3775068.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 规则层面：获取玩家场上所有满足条件的「方界」怪兽组
	local mg=Duel.GetMatchingGroup(c3775068.spcfilter,tp,LOCATION_MZONE,0,nil)
	-- 规则层面：检查是否能从这些怪兽中选出3只满足特殊召唤条件（即怪兽区有足够空间）
	return mg:CheckSubGroup(aux.mzctcheck,3,3,tp)
end
-- 规则层面：选择3只满足条件的「方界」怪兽作为特殊召唤的cost
function c3775068.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 规则层面：获取玩家场上所有满足条件的「方界」怪兽组
	local mg=Duel.GetMatchingGroup(c3775068.spcfilter,tp,LOCATION_MZONE,0,nil)
	-- 规则层面：提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 规则层面：从满足条件的怪兽中选择3只组成子组作为特殊召唤的cost
	local sg=mg:SelectSubGroup(tp,aux.mzctcheck,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 规则层面：执行特殊召唤的cost处理，将选中的怪兽送去墓地并增加攻击力
function c3775068.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 规则层面：将选中的怪兽送去墓地作为特殊召唤的cost
	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
	-- 效果原文：①：这个方法特殊召唤的这张卡的攻击力上升2400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(2400)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 规则层面：判断该卡是否从手卡特殊召唤成功
function c3775068.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 规则层面：设置伤害效果的目标玩家和伤害值
function c3775068.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面：设置伤害效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 规则层面：设置伤害效果的伤害值为800
	Duel.SetTargetParam(800)
	-- 规则层面：设置伤害效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 规则层面：执行伤害效果，给与对方800点伤害
function c3775068.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取连锁中设定的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面：执行伤害效果，给与对方800点伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 规则层面：判断该卡是否被对方送去墓地
function c3775068.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 规则层面：定义过滤条件，用于筛选墓地中满足条件的「方界」怪兽（属于「方界」卡组、可以特殊召唤）
function c3775068.spfilter(c,e,tp)
	return c:IsSetCard(0xe3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面：设置特殊召唤墓地怪兽效果的处理逻辑
function c3775068.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c3775068.spfilter(chkc,e,tp) end
	-- 规则层面：检查玩家是否有足够的怪兽区空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面：检查玩家墓地中是否有满足条件的「方界」怪兽
		and Duel.IsExistingTarget(c3775068.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	local ft=3
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 规则层面：限制可特殊召唤的怪兽数量不超过怪兽区空位数
	ft=math.min(ft,(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	-- 规则层面：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面：选择满足条件的墓地怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c3775068.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 规则层面：设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 规则层面：定义过滤条件，用于筛选可以加入手牌的「方界」卡（属于「方界」卡组、可以加入手牌）
function c3775068.thfilter(c)
	return c:IsSetCard(0xe3) and c:IsAbleToHand()
end
-- 规则层面：执行特殊召唤墓地怪兽效果的完整处理流程
function c3775068.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取玩家当前可用的怪兽区空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 规则层面：获取连锁中设定的目标卡组并筛选出与效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if g:GetCount()>ft then
		-- 规则层面：提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	-- 规则层面：执行特殊召唤操作，若成功则继续处理后续效果
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 规则层面：获取玩家卡组和墓地中满足条件的「方界」卡组
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c3775068.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
		-- 规则层面：询问玩家是否选择将一张「方界」卡加入手牌
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(3775068,2)) then  --"是否把1张「方界」卡加入手卡？"
			-- 规则层面：提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			sg=sg:Select(tp,1,1,nil)
			-- 规则层面：中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 规则层面：将选中的卡加入手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 规则层面：确认对方看到加入手牌的卡
			Duel.ConfirmCards(1-tp,sg)
			-- 规则层面：洗切玩家的卡组
			Duel.ShuffleDeck(tp)
		end
	end
end
