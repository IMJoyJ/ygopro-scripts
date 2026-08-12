--神光の龍
-- 效果：
-- 「裁决之龙」＋「惩戒之龙」
-- 从自己的场上以及墓地各把1只上记的卡除外的场合才能特殊召唤。
-- ①：自己·对方回合1次，支付2000基本分才能发动。这张卡以外的双方的场上·墓地的卡全部除外。
-- ②：自己结束阶段发动。从自己卡组上面把4张卡送去墓地。
-- ③：这张卡被对方破坏的场合才能发动。自己的除外状态的「裁决之龙」「惩戒之龙」各1只加入手卡。那之后，可以把那2只无视召唤条件特殊召唤。
local s,id,o=GetID()
-- 初始化效果，启用复活限制并添加融合素材代码列表
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为怪兽添加可作为融合素材的卡牌代码（裁决之龙和惩戒之龙）
	aux.AddMaterialCodeList(c,19959563,57774843)
	-- 设置特殊召唤条件为无效（必须满足其他条件才能特殊召唤）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件设为始终无效
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 设置特殊召唤_PROC效果，用于控制融合召唤过程
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 设置效果①：支付2000基本分除外双方场上和墓地的卡
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"场上·墓地的卡全部除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCost(s.recost)
	e3:SetTarget(s.retg)
	e3:SetOperation(s.reop)
	c:RegisterEffect(e3)
	-- 设置效果②：结束阶段从卡组上方丢弃4张卡
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"从卡组送去墓地"
	e4:SetCategory(CATEGORY_DECKDES)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCountLimit(1)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.tgcon)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
	-- 设置效果③：被对方破坏时回收并特殊召唤裁决之龙与惩戒之龙
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))  --"回收"
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(s.thcon)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
end
-- 过滤函数，用于筛选裁决之龙或惩戒之龙且可除外作为代价的卡
function s.fusfilter(c)
	return c:IsCode(19959563,57774843) and c:IsAbleToRemoveAsCost()
end
-- 选择函数，用于判断所选卡组是否满足特殊召唤条件（包含墓地和场上的卡）
function s.fselect(g,tp,sc)
	-- 检查所选卡组中是否包含2种不同代码的卡，并且有足够位置进行特殊召唤
	return g:GetClassCount(Card.GetCode)==2 and Duel.GetLocationCountFromEx(tp,tp,g,sc)>0
		and g:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
end
-- 特殊召唤条件函数，检查是否有符合条件的卡组可以作为融合素材
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上和墓地中所有裁决之龙或惩戒之龙的卡
	local g=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	return g:CheckSubGroup(s.fselect,2,2,tp,c)
end
-- 特殊召唤目标函数，选择满足条件的卡组并设置为效果标签对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上和墓地中所有裁决之龙或惩戒之龙的卡
	local g=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,true,2,2,tp,c)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤操作函数，将选中的卡作为素材除外并设置给怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	c:SetMaterial(sg)
	-- 将选中的卡以除外形式移除
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
	sg:DeleteGroup()
end
-- 效果①的费用支付函数，检查是否能支付2000基本分
function s.recost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付2000基本分
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 支付2000基本分
	Duel.PayLPCost(tp,2000)
end
-- 效果①的目标设定函数，检查是否有可除外的卡并设置操作信息
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上和墓地是否存在至少一张可除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,c) end
	-- 获取场上和墓地中所有可除外的卡
	local sg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,c)
	-- 设置操作信息为除外卡组
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,sg:GetCount(),0,0)
end
-- 效果①的操作函数，将符合条件的卡全部除外
function s.reop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上和墓地所有可除外的卡（排除自身）
	local sg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,aux.ExceptThisCard(e))
	-- 将卡组中的卡以除外形式移除
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
-- 效果②的条件函数，判断是否为当前回合玩家
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return tp==Duel.GetTurnPlayer()
end
-- 效果②的目标设定函数，设置丢弃4张卡的操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为丢弃4张卡
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,4)
end
-- 效果②的操作函数，从卡组上方丢弃4张卡
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组上方丢弃4张卡
	Duel.DiscardDeck(tp,4,REASON_EFFECT)
end
-- 效果③的触发条件函数，判断是否被对方破坏且原控制者为己方
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 筛选函数，用于查找可加入手牌的裁决之龙
function s.thfilter1(c,tp)
	return c:IsFaceup() and c:IsCode(19959563) and c:IsAbleToHand()
		-- 检查是否存在可加入手牌的惩戒之龙
		and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_REMOVED,0,1,c)
end
-- 筛选函数，用于查找可加入手牌的惩戒之龙
function s.thfilter2(c)
	return c:IsFaceup() and c:IsCode(57774843) and c:IsAbleToHand()
end
-- 效果③的目标设定函数，检查是否有符合条件的卡并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有符合条件的卡可以加入手牌
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置操作信息为将2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,0,LOCATION_REMOVED)
end
-- 筛选函数，用于判断是否可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsLocation(LOCATION_HAND) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果③的操作函数，选择卡加入手牌并询问是否无视条件特殊召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择一张裁决之龙加入手牌
	local g1=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_REMOVED,0,1,1,nil,tp)
	if #g1==0 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择一张惩戒之龙加入手牌
	local g2=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_REMOVED,0,1,1,g1,tp)
	g1:Merge(g2)
	-- 将选中的卡加入手牌，若成功则继续处理特殊召唤逻辑
	if Duel.SendtoHand(g1,nil,REASON_EFFECT)==2 then
		-- 获取操作后的卡组（即被加入手牌的卡）
		local tg=Duel.GetOperatedGroup()
		if tg:FilterCount(s.spfilter,nil,e,tp)==2
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 询问玩家是否无视条件特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否无视条件特殊召唤？"
			-- 中断当前效果处理流程
			Duel.BreakEffect()
			-- 遍历操作后的卡组进行特殊召唤
			for tc in aux.Next(tg) do
				-- 特殊召唤一张卡，不检查召唤条件
				Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
			end
			-- 完成所有特殊召唤步骤
			Duel.SpecialSummonComplete()
		end
	end
end
