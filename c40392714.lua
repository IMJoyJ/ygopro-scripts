--方界帝ゲイラ・ガイル
-- 效果：
-- 这张卡不能通常召唤。把自己场上1只「方界」怪兽送去墓地的场合可以特殊召唤。
-- ①：这个方法特殊召唤的这张卡的攻击力上升800。
-- ②：这张卡从手卡的特殊召唤成功的场合发动。给与对方800伤害。
-- ③：这张卡战斗的伤害步骤结束时，以自己墓地最多2只「方界胤 毗贾姆」为对象才能发动。这张卡送去墓地，作为对象的怪兽特殊召唤。那之后，可以从卡组把1只「方界帝 神火之德拉耆尼」加入手卡。
function c40392714.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文内容：这张卡不能通常召唤。把自己场上1只「方界」怪兽送去墓地的场合可以特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c40392714.spcon)
	e2:SetOperation(c40392714.spop)
	c:RegisterEffect(e2)
	-- 效果原文内容：这张卡从手卡的特殊召唤成功的场合发动。给与对方800伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c40392714.damcon)
	e3:SetTarget(c40392714.damtg)
	e3:SetOperation(c40392714.damop)
	c:RegisterEffect(e3)
	-- 效果原文内容：这张卡战斗的伤害步骤结束时，以自己墓地最多2只「方界胤 毗贾姆」为对象才能发动。这张卡送去墓地，作为对象的怪兽特殊召唤。那之后，可以从卡组把1只「方界帝 神火之德拉耆尼」加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 规则层面作用：设置效果发动条件为aux.dsercon函数，用于判断是否在伤害步骤结束时满足发动条件。
	e4:SetCondition(aux.dsercon)
	e4:SetTarget(c40392714.sptg2)
	e4:SetOperation(c40392714.spop2)
	c:RegisterEffect(e4)
end
-- 规则层面作用：定义过滤函数，用于筛选场上满足条件的「方界」怪兽（必须是表侧表示、属于「方界」卡组、可以作为cost送去墓地）。
function c40392714.filter(c,ft)
	return c:IsFaceup() and c:IsSetCard(0xe3) and c:IsAbleToGraveAsCost() and (ft>0 or c:GetSequence()<5)
end
-- 规则层面作用：定义特殊召唤条件函数，检查是否有满足条件的「方界」怪兽可以送去墓地，从而满足特殊召唤条件。
function c40392714.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 规则层面作用：获取当前玩家场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 规则层面作用：判断当前玩家场上是否有满足条件的「方界」怪兽可以送去墓地。
	return ft>-1 and Duel.IsExistingMatchingCard(c40392714.filter,tp,LOCATION_MZONE,0,1,nil,ft)
end
-- 规则层面作用：执行特殊召唤操作，选择场上1只「方界」怪兽送去墓地，并给自身攻击力增加800。
function c40392714.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 规则层面作用：获取当前玩家场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 规则层面作用：提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 规则层面作用：选择场上满足条件的「方界」怪兽作为cost。
	local g=Duel.SelectMatchingCard(tp,c40392714.filter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	-- 规则层面作用：将选中的怪兽送去墓地作为cost。
	Duel.SendtoGrave(g,REASON_COST)
	-- 效果原文内容：①：这个方法特殊召唤的这张卡的攻击力上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(800)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断该卡是否从手卡特殊召唤成功。
function c40392714.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 规则层面作用：设置伤害效果的目标玩家和伤害值。
function c40392714.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：设置伤害效果的目标玩家为对方。
	Duel.SetTargetPlayer(1-tp)
	-- 规则层面作用：设置伤害效果的伤害值为800。
	Duel.SetTargetParam(800)
	-- 规则层面作用：设置连锁操作信息，表示将对对方造成800点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 规则层面作用：执行伤害效果，给对方造成800点伤害。
function c40392714.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取连锁中设定的目标玩家和伤害值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面作用：给目标玩家造成指定伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 规则层面作用：定义过滤函数，用于筛选墓地中的「方界帝 神火之德拉耆尼」。
function c40392714.spfilter(c,e,tp)
	return c:IsCode(15610297) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：设置效果目标，选择墓地中的「方界帝 神火之德拉耆尼」作为特殊召唤对象。
function c40392714.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c40392714.spfilter(chkc,e,tp) end
	-- 规则层面作用：判断是否满足特殊召唤条件，包括场上是否有空位和该卡是否参与战斗。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler(),tp)>0 and c:IsRelateToBattle()
		-- 规则层面作用：判断是否在墓地中存在满足条件的「方界帝 神火之德拉耆尼」。
		and Duel.IsExistingTarget(c40392714.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	local ft=2
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 规则层面作用：计算可特殊召唤的最大数量，受青眼精灵龙效果影响。
	ft=math.min(ft,(Duel.GetMZoneCount(tp,e:GetHandler(),tp)))
	-- 规则层面作用：提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：选择墓地中的「方界帝 神火之德拉耆尼」作为特殊召唤对象。
	local g=Duel.SelectTarget(tp,c40392714.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 规则层面作用：设置连锁操作信息，表示将特殊召唤指定数量的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 规则层面作用：定义过滤函数，用于筛选卡组中可加入手牌的「方界帝 神火之德拉耆尼」。
function c40392714.thfilter(c)
	return c:IsCode(77387463) and c:IsAbleToHand()
end
-- 规则层面作用：执行效果操作，将自身送去墓地，特殊召唤目标怪兽，并可选择加入1张「方界帝 神火之德拉耆尼」到手牌。
function c40392714.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面作用：判断该卡是否仍与当前效果相关联，若不是则不执行效果。
	if not c:IsRelateToEffect(e) or Duel.SendtoGrave(c,REASON_EFFECT)==0 then return end
	-- 规则层面作用：获取当前玩家场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 规则层面作用：获取连锁中设定的目标卡片组，并筛选出与当前效果相关的卡片。
	local sg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if sg:GetCount()>ft then
		-- 规则层面作用：提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	-- 规则层面作用：执行特殊召唤操作，将目标怪兽特殊召唤到场上。
	if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 规则层面作用：获取卡组中满足条件的「方界帝 神火之德拉耆尼」。
		local g=Duel.GetMatchingGroup(c40392714.thfilter,tp,LOCATION_DECK,0,nil)
		-- 规则层面作用：询问玩家是否将1张「方界帝 神火之德拉耆尼」加入手牌。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(40392714,0)) then  --"是否把1只「方界帝 神火之德拉耆尼」加入手卡？"
			-- 规则层面作用：中断当前效果处理，使后续效果视为不同时处理。
			Duel.BreakEffect()
			-- 规则层面作用：提示玩家选择要加入手牌的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			g=g:Select(tp,1,1,nil)
			-- 规则层面作用：将选中的卡加入玩家手牌。
			Duel.SendtoHand(g,tp,REASON_EFFECT)
			-- 规则层面作用：向对方确认加入手牌的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
